--
-- PostgreSQL database dump
--

\restrict jO5mHk3iQjuUJB0eTb5BDRo2MsTBSmMYWNIimZs9j68kyUQozYUm5ADocqdyoL7

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
-- Name: _cbi_address_info_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_address_info_cache (
    address character varying,
    stake_address_id bigint,
    stake_address character varying,
    script_hash text
);


--
-- Name: _cbi_address_info_cache_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX _cbi_address_info_cache_1 ON public._cbi_address_info_cache USING btree (address);


--
-- Name: _cbi_address_info_cache_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_info_cache_2 ON public._cbi_address_info_cache USING btree (stake_address);


--
-- Name: _cbi_address_info_cache_3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_address_info_cache_3 ON public._cbi_address_info_cache USING btree (stake_address_id);


--
-- PostgreSQL database dump complete
--

\unrestrict jO5mHk3iQjuUJB0eTb5BDRo2MsTBSmMYWNIimZs9j68kyUQozYUm5ADocqdyoL7

