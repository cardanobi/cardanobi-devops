--
-- PostgreSQL database dump
--

\restrict d2yyZPCBpIVfDn9NRura2raERXBomOrVp89te4rLNUjEiGTj76Ko9EkzngImDKO

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
-- Name: _cbi_pool_stats_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_pool_stats_cache (
    epoch_no bigint NOT NULL,
    pool_hash_id bigint NOT NULL,
    delegator_count bigint DEFAULT 0,
    delegated_stakes bigint DEFAULT 0,
    tx_count bigint DEFAULT 0,
    block_count bigint DEFAULT 0
);


--
-- Name: _cbi_pool_stats_cache _cbi_pool_stats_cache_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_pool_stats_cache
    ADD CONSTRAINT _cbi_pool_stats_cache_unique PRIMARY KEY (epoch_no, pool_hash_id);


--
-- Name: idx_cbi_pool_stats_pool_hash_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cbi_pool_stats_pool_hash_id ON public._cbi_pool_stats_cache USING btree (pool_hash_id);


--
-- PostgreSQL database dump complete
--

\unrestrict d2yyZPCBpIVfDn9NRura2raERXBomOrVp89te4rLNUjEiGTj76Ko9EkzngImDKO

