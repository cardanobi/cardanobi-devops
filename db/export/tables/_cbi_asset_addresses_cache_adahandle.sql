--
-- PostgreSQL database dump
--

\restrict FevIl8BTxanKVKBT4LxZtNr57q0xtQqVknPfQKlNxNs6eZ609yiAKwxubfww6UF

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
-- Name: _cbi_asset_addresses_cache_adahandle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_asset_addresses_cache_adahandle (
    asset_id bigint,
    name character varying,
    fingerprint character varying,
    address character varying,
    stake_address_id integer
);


--
-- Name: _cbi_asset_addresses_cache_adahandle _cbi_asset_addresses_cache_adahandle_asset_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_asset_addresses_cache_adahandle
    ADD CONSTRAINT _cbi_asset_addresses_cache_adahandle_asset_id_key UNIQUE (asset_id);


--
-- Name: idx_adahandle_address; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adahandle_address ON public._cbi_asset_addresses_cache_adahandle USING btree (address);


--
-- Name: idx_adahandle_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adahandle_fingerprint ON public._cbi_asset_addresses_cache_adahandle USING btree (fingerprint);


--
-- Name: idx_adahandle_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adahandle_name ON public._cbi_asset_addresses_cache_adahandle USING btree (name);


--
-- Name: idx_adahandle_stake_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_adahandle_stake_address_id ON public._cbi_asset_addresses_cache_adahandle USING btree (stake_address_id);


--
-- PostgreSQL database dump complete
--

\unrestrict FevIl8BTxanKVKBT4LxZtNr57q0xtQqVknPfQKlNxNs6eZ609yiAKwxubfww6UF

