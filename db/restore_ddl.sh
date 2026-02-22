#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# restore_ddl.sh — Restore DDL from an export directory to a PostgreSQL database
#
# Reads the output of export_ddl.sh and applies SQL files in dependency order:
#   1. Functions  (no dependencies)
#   2. Tables     (may be referenced by materialized views)
#   3. Materialized views (may reference tables)
#
# Usage:
#   ./restore_ddl.sh -d cardanobi -i ./ddl_export_20260222_150000
#   ./restore_ddl.sh -d cardanobi -i ./ddl_export_20260222_150000 -h remotehost -U cardanobi
#   ./restore_ddl.sh -d cardanobi -i ./ddl_export_20260222_150000 --dry-run
# =============================================================================

DB=""
INPUT_DIR=""
PG_HOST=""
PG_PORT=""
PG_USER=""
DRY_RUN=false

usage() {
    echo "Usage: $0 -d database -i input_dir [-h host] [-p port] [-U user] [--dry-run]"
    echo "  -d  Target database name  (required)"
    echo "  -i  Input directory        (required — output of export_ddl.sh)"
    echo "  -h  PostgreSQL host        (default: local socket)"
    echo "  -p  PostgreSQL port        (default: 5432)"
    echo "  -U  PostgreSQL user        (default: current user)"
    echo "  --dry-run  List files that would be applied without executing"
    exit 1
}

# Parse arguments (mix of getopts and long opts)
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d) DB="$2"; shift 2 ;;
        -i) INPUT_DIR="$2"; shift 2 ;;
        -h) PG_HOST="$2"; shift 2 ;;
        -p) PG_PORT="$2"; shift 2 ;;
        -U) PG_USER="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --help) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

[[ -n "$DB" ]]        || { echo "ERROR: -d (database) is required."; usage; }
[[ -n "$INPUT_DIR" ]] || { echo "ERROR: -i (input directory) is required."; usage; }
[[ -d "$INPUT_DIR" ]] || { echo "ERROR: Input directory not found: $INPUT_DIR"; exit 1; }

# Build psql connection flags
PSQL_CONN=(-d "$DB")
[[ -n "$PG_HOST" ]] && PSQL_CONN+=(-h "$PG_HOST")
[[ -n "$PG_PORT" ]] && PSQL_CONN+=(-p "$PG_PORT")
[[ -n "$PG_USER" ]] && PSQL_CONN+=(-U "$PG_USER")

echo "=== CardanoBI DDL Restore ==="
echo "Database:   $DB"
echo "Input:      $INPUT_DIR"
echo "Host:       ${PG_HOST:-local}"
echo "Dry run:    $DRY_RUN"
echo

apply_dir() {
    local dir="$1"
    local label="$2"
    local dir_path="$INPUT_DIR/$dir"
    local count=0
    local errors=0

    if [[ ! -d "$dir_path" ]] || [[ -z "$(ls -A "$dir_path" 2>/dev/null)" ]]; then
        echo "  (no files in $dir/)"
        return
    fi

    for sql_file in "$dir_path"/*.sql; do
        [[ -f "$sql_file" ]] || continue
        local fname
        fname=$(basename "$sql_file")

        if $DRY_RUN; then
            echo "  [dry-run] would apply: $dir/$fname"
        else
            if psql "${PSQL_CONN[@]}" --set ON_ERROR_STOP=1 -f "$sql_file" > /dev/null 2>&1; then
                echo "  [ok]    $dir/$fname"
            else
                echo "  [FAIL]  $dir/$fname"
                (( errors++ ))
            fi
        fi
        (( count++ ))
    done

    echo "  $label: $count file(s)${errors:+, $errors error(s)}"
}

# Apply in dependency order
echo "--- 1/3: Functions ---"
apply_dir "functions" "Functions"
echo

echo "--- 2/3: Tables ---"
apply_dir "tables" "Tables"
echo

echo "--- 3/3: Materialized views ---"
apply_dir "materialized_views" "Materialized views"
echo

echo "=== Restore complete ==="
