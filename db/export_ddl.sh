#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# export_ddl.sh — Export DDL from the CardanoBI PostgreSQL database
#
# Exports:
#   1. Tables prefixed "cbi_"          (DDL + indexes + constraints)
#   2. All materialized views           (DDL + indexes)
#   3. Functions prefixed "cbi_"        (full CREATE OR REPLACE FUNCTION)
#
# Usage:
#   ./export_ddl.sh                          # defaults: db=cardanobi, output=./ddl_export_<ts>
#   ./export_ddl.sh -d mydb -o /tmp/export
# =============================================================================

DB="cardanobi"
OUT_DIR=""

usage() {
    echo "Usage: $0 [-d database] [-o output_dir]"
    echo "  -d  Database name       (default: cardanobi)"
    echo "  -o  Output directory    (default: ./ddl_export_YYYYMMDD_HHMMSS)"
    exit 1
}

while getopts "d:o:h" opt; do
    case "$opt" in
        d) DB="$OPTARG" ;;
        o) OUT_DIR="$OPTARG" ;;
        h) usage ;;
        *) usage ;;
    esac
done

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="${OUT_DIR:-./ddl_export_${TIMESTAMP}}"

mkdir -p "$OUT_DIR/tables"
mkdir -p "$OUT_DIR/materialized_views"
mkdir -p "$OUT_DIR/functions"

MANIFEST="$OUT_DIR/manifest.txt"
: > "$MANIFEST"

echo "=== CardanoBI DDL Export ==="
echo "Database:  $DB"
echo "Output:    $OUT_DIR"
echo

# ---------------------------------------------------------------------------
# 1. Tables prefixed "cbi_"
# ---------------------------------------------------------------------------
echo "--- Exporting cbi_* tables ---"

TABLE_LIST=$(psql -d "$DB" -t -A -c \
    "SELECT tablename FROM pg_tables
     WHERE schemaname = 'public' AND tablename LIKE 'cbi_%'
     ORDER BY tablename;")

TABLE_COUNT=0
for TBL in $TABLE_LIST; do
    FILE="$OUT_DIR/tables/${TBL}.sql"
    pg_dump -d "$DB" --schema-only --no-owner --no-privileges -t "public.${TBL}" > "$FILE"
    echo "  [table] $TBL"
    echo "table  $TBL" >> "$MANIFEST"
    (( TABLE_COUNT++ ))
done

echo "  Exported $TABLE_COUNT table(s)."
echo

# ---------------------------------------------------------------------------
# 2. All materialized views
# ---------------------------------------------------------------------------
echo "--- Exporting materialized views ---"

MATVIEW_LIST=$(psql -d "$DB" -t -A -c \
    "SELECT matviewname FROM pg_matviews
     WHERE schemaname = 'public'
     ORDER BY matviewname;")

MV_COUNT=0
for MV in $MATVIEW_LIST; do
    FILE="$OUT_DIR/materialized_views/${MV}.sql"

    # pg_dump can export materialized views with -t
    pg_dump -d "$DB" --schema-only --no-owner --no-privileges -t "public.${MV}" > "$FILE"

    echo "  [matview] $MV"
    echo "matview  $MV" >> "$MANIFEST"
    (( MV_COUNT++ ))
done

echo "  Exported $MV_COUNT materialized view(s)."
echo

# ---------------------------------------------------------------------------
# 3. Functions prefixed "cbi_"
# ---------------------------------------------------------------------------
echo "--- Exporting cbi_* functions ---"

# Get oid + function name (with arg signature for the filename)
FUNC_LIST=$(psql -d "$DB" -t -A -c \
    "SELECT p.oid, p.proname
     FROM pg_proc p
     JOIN pg_namespace n ON p.pronamespace = n.oid
     WHERE n.nspname = 'public' AND p.proname LIKE 'cbi_%'
     ORDER BY p.proname;")

FUNC_COUNT=0
for ROW in $FUNC_LIST; do
    OID="${ROW%%|*}"
    FNAME="${ROW##*|}"
    FILE="$OUT_DIR/functions/${FNAME}_${OID}.sql"

    psql -d "$DB" -t -A -c "SELECT pg_get_functiondef(${OID});" > "$FILE"

    # Add a trailing semicolon if not present
    if [[ -s "$FILE" ]] && ! tail -c 2 "$FILE" | grep -q ';'; then
        echo ";" >> "$FILE"
    fi

    echo "  [function] $FNAME (oid=$OID)"
    echo "function  $FNAME  oid=$OID" >> "$MANIFEST"
    (( FUNC_COUNT++ ))
done

echo "  Exported $FUNC_COUNT function(s)."
echo

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
TOTAL=$((TABLE_COUNT + MV_COUNT + FUNC_COUNT))
echo "=== Export complete ==="
echo "  Tables:             $TABLE_COUNT"
echo "  Materialized views: $MV_COUNT"
echo "  Functions:          $FUNC_COUNT"
echo "  Total:              $TOTAL"
echo "  Output directory:   $OUT_DIR"
echo "  Manifest:           $MANIFEST"
