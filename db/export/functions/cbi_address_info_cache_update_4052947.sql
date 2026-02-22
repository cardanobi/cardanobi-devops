CREATE OR REPLACE PROCEDURE public.cbi_address_info_cache_update()
 LANGUAGE plpgsql
AS $procedure$
declare
  _last_tx_id bigint;
  _last_processed_tx_id bigint;
	begin
		--avoid concurrent runs
		if (
		    select
		      count(pid) > 1
		    from
		      pg_stat_activity
		    where
		      state = 'active' and query ilike '%public.cbi_address_info_cache_update%'
		      and datname = (select current_database())
		  ) then 
		    raise exception 'cbi_address_info_cache_update already running, exiting!';
		end if;
	
		--determine what needs doing, ie create or update with epoch delta 
	    select max(tx.id) into _last_tx_id from tx;
		select coalesce(last_tx_id, 0) into _last_processed_tx_id from _cbi_cache_handler_state where table_name = '_cbi_address_info_cache';
	
		if _last_processed_tx_id is null then
			truncate table _cbi_address_info_cache;
			select 0 into _last_processed_tx_id;
			raise notice 'cbi_address_info_cache_update - building cache from scratch...';
		else
			if _last_tx_id <= _last_processed_tx_id then
				raise notice 'cbi_address_info_cache_update - no new transaction to process, exiting!';
				return;
			else
				raise notice 'cbi_address_info_cache_update - updating cache - last processed tx id % - latest known tx id %.', _last_processed_tx_id, _last_tx_id;
			end if;
		end if;
	
		raise notice 'cbi_address_info_cache_update - INFO - _last_processed_tx_id: %, _last_tx_id: %', _last_processed_tx_id, _last_tx_id;
	

		insert into _cbi_address_info_cache(address,stake_address_id,stake_address,script_hash)
	    select 
            distinct tx_out.address, tx_out.stake_address_id, sa.view as stake_address, encode(sa.script_hash::bytea, 'hex') as script_hash 
        from tx_out 
        left join stake_address sa on tx_out.stake_address_id=sa.id
		where tx_out.tx_id>_last_processed_tx_id and  tx_out.tx_id<=_last_tx_id
		and length(tx_out.address)<255 --to not account for pre-shelley addresses with random lengths
		on conflict (address) do
	      update
	        set stake_address_id = excluded.stake_address_id,
	          stake_address = excluded.stake_address,
	          script_hash = excluded.script_hash;

 		--update the handler table
		if _last_processed_tx_id = 0 then
			insert into _cbi_cache_handler_state(table_name, last_tx_id) values('_cbi_address_info_cache', _last_tx_id);
		else
			update _cbi_cache_handler_state set last_tx_id = _last_tx_id
			where table_name = '_cbi_address_info_cache';
		end if;
		
		raise notice 'cbi_address_info_cache_update - COMPLETE';
	end;
$procedure$

;
