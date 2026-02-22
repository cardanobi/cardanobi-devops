--
-- PostgreSQL database dump
--

\restrict K9ow5m7z3E7zF6NHH72awYAZsUIMpif8qkSad6dSf1iNUB8pn7CLLTimjYSmdql

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
-- Name: _cbi_asset_addresses_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_asset_addresses_cache (
    asset_id bigint NOT NULL,
    address character varying NOT NULL,
    quantity numeric NOT NULL
);


--
-- Name: _cbi_asset_addresses_cache _cbi_asset_addresses_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_asset_addresses_cache
    ADD CONSTRAINT _cbi_asset_addresses_cache_pkey PRIMARY KEY (asset_id, address);


--
-- Name: _cbi_aac_idx_1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX _cbi_aac_idx_1 ON public._cbi_asset_addresses_cache USING btree (asset_id);


--
-- PostgreSQL database dump complete
--

\unrestrict K9ow5m7z3E7zF6NHH72awYAZsUIMpif8qkSad6dSf1iNUB8pn7CLLTimjYSmdql

