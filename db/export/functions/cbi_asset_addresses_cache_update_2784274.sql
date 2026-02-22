CREATE OR REPLACE PROCEDURE public.cbi_asset_addresses_cache_update()
 LANGUAGE plpgsql
AS $procedure$
declare
  _last_tx_id bigint;
  _handler_last_tx_id bigint;
  _tx_id_list bigint[];
  _changed_pairs_count int;
  _recalculated_balances_count int;
	begin
		--avoid concurrent runs
		if (
		    select
		      count(pid) > 1
		    from
		      pg_stat_activity
		    where
		      state = 'active' and query ilike '%public.cbi_asset_addresses_cache_update%'
		      and datname = (select current_database())
		  ) then 
		    raise exception 'cbi_asset_addresses_cache_update already running, exiting!';
		end if;
	
		--determinie what needs doing, ie create or update with transaction delta 
		select max(id) into _last_tx_id from tx;

		select coalesce(last_tx_id, 0) into _handler_last_tx_id from _cbi_cache_handler_state where table_name = '_cbi_asset_addresses_cache';
		
		raise notice 'cbi_asset_addresses_cache_update - info - _last_tx_id: %, _handler_last_tx_id: %', _last_tx_id, _handler_last_tx_id;
	
		if _handler_last_tx_id is null then
			truncate table _cbi_asset_addresses_cache;
            select 0 into _handler_last_tx_id;
			raise notice 'cbi_asset_addresses_cache_update - building cache from scratch, _handler_last_tx_id: %...', _handler_last_tx_id;
		else
			select array_agg(distinct id) into _tx_id_list from tx where id > _handler_last_tx_id and id <= _last_tx_id;
			if _tx_id_list is null then
				raise notice 'cbi_asset_addresses_cache_update - no new multi-asset transactions to process, exiting!';
				return;
			else
				raise notice 'cbi_asset_addresses_cache_update - updating cache with % new multi-asset transactions.', array_length(_tx_id_list, 1);
			end if;
		end if;
	
	
		if _handler_last_tx_id = 0 then
			--building cache from scratch (use cbi_asset_addresses_cache_initial_load process for mainnet as unpartitioned calcs would take too long)
			INSERT INTO _cbi_asset_addresses_cache (asset_id, address, quantity)
			SELECT
				ma.id AS asset_id,
				txo.address,
				SUM(mto.quantity) AS quantity
			FROM
				ma_tx_out mto
				INNER JOIN multi_asset ma ON ma.id = mto.ident 
				INNER JOIN tx_out txo ON txo.id = mto.tx_out_id
				LEFT JOIN tx_in ON txo.tx_id = tx_in.tx_out_id
					AND txo.index::smallint = tx_in.tx_out_index::smallint
			WHERE
				tx_in.tx_out_id IS NULL
				AND txo.tx_id <= _last_tx_id
			GROUP BY
				ma.id, txo.address;

		else
			--updating the cache by recomputing the (ma.id, txo.address) that got new unspent utxos
			WITH changed_pairs AS (
				SELECT DISTINCT
					ma.id AS asset_id,
					txo.address
				FROM
					ma_tx_out mto
					INNER JOIN multi_asset ma ON ma.id = mto.ident
					INNER JOIN tx_out txo ON txo.id = mto.tx_out_id
					left join tx_in on txo.tx_id = tx_in.tx_out_id
					and txo.index::smallint = tx_in.tx_out_index::smallint
				WHERE
					tx_in.tx_out_id is null
					AND txo.tx_id > _handler_last_tx_id
					AND txo.tx_id <= _last_tx_id
			),
			recalculated_balances AS (
				SELECT
					cp.asset_id,
					cp.address,
					COALESCE(SUM(mto.quantity), 0) AS new_quantity
				FROM
					changed_pairs cp
					INNER JOIN ma_tx_out mto ON cp.asset_id = mto.ident
					INNER JOIN tx_out txo ON mto.tx_out_id = txo.id AND txo.address = cp.address
					LEFT JOIN tx_in ON txo.tx_id = tx_in.tx_out_id AND txo.index::smallint = tx_in.tx_out_index::smallint
				WHERE
					tx_in.tx_out_id IS NULL
					AND txo.tx_id <= _last_tx_id
				GROUP BY
					cp.asset_id, cp.address
			),
			update_quantities AS (
				INSERT INTO _cbi_asset_addresses_cache (asset_id, address, quantity)
				SELECT
					rb.asset_id,
					rb.address,
					rb.new_quantity
				FROM
					recalculated_balances rb
				ON CONFLICT (asset_id, address)
				DO UPDATE SET
					quantity = EXCLUDED.quantity
			)
			SELECT COUNT(*) INTO _changed_pairs_count FROM changed_pairs;
        	SELECT COUNT(*) INTO _recalculated_balances_count FROM recalculated_balances;
        
			-- Then, set quantities to 0 for pairs not in recalculated_balances but present in _cbi_asset_addresses_cache
			UPDATE _cbi_asset_addresses_cache cac
			SET quantity = 0
			WHERE
				(cac.asset_id, cac.address) NOT IN (SELECT asset_id, address FROM recalculated_balances)
				AND (cac.asset_id, cac.address) IN (SELECT asset_id, address FROM changed_pairs);
		end if;

		-- Log the counts
		RAISE NOTICE 'cbi_asset_addresses_cache_update - Number of entries in changed_pairs: %', _changed_pairs_count;
		RAISE NOTICE 'cbi_asset_addresses_cache_update - Number of entries in recalculated_balances: %', _recalculated_balances_count;

	   --update the handler table
		if _handler_last_tx_id is null or _handler_last_tx_id = 0 then
			insert into _cbi_cache_handler_state(table_name, last_tx_id) values('_cbi_asset_addresses_cache', _last_tx_id);
		else
			update _cbi_cache_handler_state set last_tx_id = _last_tx_id
			where table_name = '_cbi_asset_addresses_cache';
		end if;

		raise notice 'cbi_asset_addresses_cache_update - complete';
	end;
$procedure$

;
