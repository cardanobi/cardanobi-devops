--
-- PostgreSQL database dump
--

\restrict OvvHHA8SClgGHNs2ggpl98j7ajZBVt6wn589iY7TxuIdmYidPoqSQBYkUMjQYBD

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
-- Name: _cbi_active_stake_cache_epoch; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_active_stake_cache_epoch (
    epoch_no bigint NOT NULL,
    amount public.lovelace NOT NULL
);


--
-- Name: _cbi_active_stake_cache_epoch _cbi_active_stake_cache_epoch_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_active_stake_cache_epoch
    ADD CONSTRAINT _cbi_active_stake_cache_epoch_pkey PRIMARY KEY (epoch_no);


--
-- PostgreSQL database dump complete
--

\unrestrict OvvHHA8SClgGHNs2ggpl98j7ajZBVt6wn589iY7TxuIdmYidPoqSQBYkUMjQYBD

