CREATE OR REPLACE PROCEDURE public.cbi_address_stats_cache_update()
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
		      state = 'active' and query ilike '%public.cbi_address_stats_cache_update%'
		      and datname = (select current_database())
		  ) then 
		    raise exception 'cbi_address_stats_cache_update already running, exiting!';
		end if;
	
		--determine what needs doing, ie create or update with epoch delta 
	    select max(tx.id) into _last_tx_id from tx;
		select coalesce(last_tx_id, 0) into _last_processed_tx_id from _cbi_cache_handler_state where table_name = '_cbi_address_stats_cache';
	
		if _last_processed_tx_id is null then
			truncate table _cbi_address_stats_cache;
			select 0 into _last_processed_tx_id;
			raise notice 'cbi_address_stats_cache_update - building cache from scratch...';
		else
			if _last_tx_id <= _last_processed_tx_id then
				raise notice 'cbi_address_stats_cache_update - no new transaction to process, exiting!';
				return;
			else
				raise notice 'cbi_address_stats_cache_update - updating cache - last processed tx id % - latest known tx id %.', _last_processed_tx_id, _last_tx_id;
			end if;
		end if;
	
		raise notice 'cbi_address_stats_cache_update - INFO - _last_processed_tx_id: %, _last_tx_id: %', _last_processed_tx_id, _last_tx_id;
	
        insert into _cbi_address_stats_cache(epoch_no,address,stake_address_id,tx_count)
        select block.epoch_no, tx_out.address, coalesce(sa.id,0) as stake_address_id, count(*) as tx_count
        from tx
        inner join block on tx.block_id = block.id
        inner join tx_out on tx.id = tx_out.tx_id
        left join stake_address sa on tx_out.stake_address_id = sa.id 
        where tx.id > _last_processed_tx_id and tx.id <= _last_tx_id
		and length(tx_out.address)<255 --to not account for pre-shelley addresses with random lengths
        group by block.epoch_no, tx_out.address, sa.id
        on conflict on constraint _cbi_address_stats_cache_unique do
            update
                set tx_count = _cbi_address_stats_cache.tx_count + excluded.tx_count;


 		--update the handler table
		if _last_processed_tx_id = 0 then
			insert into _cbi_cache_handler_state(table_name, last_tx_id) values('_cbi_address_stats_cache', _last_tx_id);
		else
			update _cbi_cache_handler_state set last_tx_id = _last_tx_id
			where table_name = '_cbi_address_stats_cache';
		end if;
		
		raise notice 'cbi_address_stats_cache_update - COMPLETE';
	end;
$procedure$

;
