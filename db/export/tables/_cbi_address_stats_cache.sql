--
-- PostgreSQL database dump
--

\restrict KomKRbpUPyctkvhyMHIeMYfFe08jibRGRt4dCNdOUqh7uY0dNHOpC6a2dDF7Mal

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
-- Name: _cbi_address_stats_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_address_stats_cache (
    epoch_no public.word31type,
    address character varying,
    stake_address_id bigint DEFAULT 0,
    tx_count bigint
);


--
-- Name: _cbi_address_stats_cache _cbi_address_stats_cache_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_address_stats_cache
    ADD CONSTRAINT _cbi_address_stats_cache_unique UNIQUE (epoch_no, address, stake_address_id);


--
-- Name: _cbi_address_stats_cache_1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_stats_cache_1 ON public._cbi_address_stats_cache USING btree (address);


--
-- Name: _cbi_address_stats_cache_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_stats_cache_2 ON public._cbi_address_stats_cache USING btree (stake_address_id);


--
-- Name: _cbi_address_stats_cache_3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_stats_cache_3 ON public._cbi_address_stats_cache USING btree (epoch_no, address);


--
-- Name: _cbi_address_stats_cache_4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_stats_cache_4 ON public._cbi_address_stats_cache USING btree (epoch_no, stake_address_id);


--
-- PostgreSQL database dump complete
--

\unrestrict KomKRbpUPyctkvhyMHIeMYfFe08jibRGRt4dCNdOUqh7uY0dNHOpC6a2dDF7Mal

