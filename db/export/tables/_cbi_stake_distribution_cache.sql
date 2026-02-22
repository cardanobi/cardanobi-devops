--
-- PostgreSQL database dump
--

\restrict 8CzQIt2aUuo00uwtiK7aPLTCCGifZ7WlrISzKbT7esujakUzNfslO0eyBXu8L0P

-- Dumped from database version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.20 (Ubuntu 14.20-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _cbi_stake_distribution_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_stake_distribution_cache (
    stake_address_id bigint NOT NULL,
    is_registered boolean,
    last_reg_dereg_tx character varying,
    last_reg_dereg_epoch_no numeric,
    pool_hash_id bigint,
    delegated_since_epoch_no numeric,
    last_deleg_tx character varying,
    total_balance numeric,
    utxo numeric,
    rewards numeric,
    withdrawals numeric,
    rewards_available numeric
);


--
-- Name: _cbi_stake_distribution_cache _cbi_stake_distribution_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_stake_distribution_cache
    ADD CONSTRAINT _cbi_stake_distribution_cache_pkey PRIMARY KEY (stake_address_id);


--
-- Name: _cbi_casca_idx_pool_hash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_casca_idx_pool_hash_id ON public._cbi_stake_distribution_cache USING btree (pool_hash_id);


--
-- Name: _cbi_casca_idx_stake_address_id_pool_hash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_casca_idx_stake_address_id_pool_hash_id ON public._cbi_stake_distribution_cache USING btree (stake_address_id, pool_hash_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 8CzQIt2aUuo00uwtiK7aPLTCCGifZ7WlrISzKbT7esujakUzNfslO0eyBXu8L0P

