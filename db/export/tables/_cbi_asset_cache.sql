--
-- PostgreSQL database dump
--

\restrict 6EmtzGycSEtfc1rHYMasWZUco1rgbHCjyPuijvE1VSNxwwJN6thnJGfdKZpMNj8

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
-- Name: _cbi_asset_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_asset_cache (
    asset_id bigint NOT NULL,
    creation_time timestamp without time zone,
    total_supply numeric,
    mint_cnt bigint,
    burn_cnt bigint,
    first_mint_tx_id bigint,
    first_mint_tx_hash text,
    first_mint_keys text[],
    last_mint_tx_id bigint,
    last_mint_tx_hash text,
    last_mint_keys text[]
);


--
-- Name: _cbi_asset_cache _cbi_asset_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_asset_cache
    ADD CONSTRAINT _cbi_asset_cache_pkey PRIMARY KEY (asset_id);


--
-- Name: _cbi_ac_idx_first_mint_tx_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_ac_idx_first_mint_tx_id ON public._cbi_asset_cache USING btree (first_mint_tx_id);


--
-- Name: _cbi_ac_idx_last_mint_tx_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_ac_idx_last_mint_tx_id ON public._cbi_asset_cache USING btree (last_mint_tx_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 6EmtzGycSEtfc1rHYMasWZUco1rgbHCjyPuijvE1VSNxwwJN6thnJGfdKZpMNj8

