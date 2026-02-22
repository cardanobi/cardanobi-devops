CREATE OR REPLACE PROCEDURE public.cbi_cache_handler_remove()
 LANGUAGE plpgsql
AS $procedure$
	begin
		drop table _cbi_cache_handler_state;
		drop table _cbi_asset_cache;
		drop table _cbi_asset_addresses_cache;
		drop table _cbi_active_stake_cache_pool;
		drop table _cbi_active_stake_cache_epoch;
		drop table _cbi_active_stake_cache_account;
		drop table _cbi_stake_distribution_cache;
	end;
$procedure$

;
