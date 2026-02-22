--
-- PostgreSQL database dump
--

\restrict pe8dv13caxdhVJi8rPppAxRifPDbdwlX8PUDfbjYykN8ByHXQZq9gEWe44ehesi

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
-- Name: _cbi_active_stake_cache_pool; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_active_stake_cache_pool (
    pool_id character varying NOT NULL,
    epoch_no bigint NOT NULL,
    amount public.lovelace NOT NULL
);


--
-- Name: _cbi_active_stake_cache_pool _cbi_active_stake_cache_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_active_stake_cache_pool
    ADD CONSTRAINT _cbi_active_stake_cache_pool_pkey PRIMARY KEY (pool_id, epoch_no);


--
-- PostgreSQL database dump complete
--

\unrestrict pe8dv13caxdhVJi8rPppAxRifPDbdwlX8PUDfbjYykN8ByHXQZq9gEWe44ehesi

