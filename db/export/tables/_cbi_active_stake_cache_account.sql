--
-- PostgreSQL database dump
--

\restrict aV1GKf6jnG2roG4fDihh8A1KKggp8weymQ5f7d2wXvMQa5kedhJhj9dDkHgPeGr

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
-- Name: _cbi_active_stake_cache_account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_active_stake_cache_account (
    stake_address_id bigint NOT NULL,
    pool_hash_id bigint NOT NULL,
    epoch_no bigint NOT NULL,
    amount public.lovelace DEFAULT 0
);


--
-- Name: _cbi_active_stake_cache_account _cbi_active_stake_cache_account_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_active_stake_cache_account
    ADD CONSTRAINT _cbi_active_stake_cache_account_pkey PRIMARY KEY (stake_address_id, pool_hash_id, epoch_no);


--
-- Name: _cbi_casca_idx_pool_id_epoch_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_casca_idx_pool_id_epoch_no ON public._cbi_active_stake_cache_account USING btree (pool_hash_id, epoch_no);


--
-- Name: _cbi_casca_idx_stake_address_epoch_no; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_casca_idx_stake_address_epoch_no ON public._cbi_active_stake_cache_account USING btree (stake_address_id, epoch_no);


--
-- PostgreSQL database dump complete
--

\unrestrict aV1GKf6jnG2roG4fDihh8A1KKggp8weymQ5f7d2wXvMQa5kedhJhj9dDkHgPeGr

