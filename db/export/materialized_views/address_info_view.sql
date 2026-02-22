--
-- PostgreSQL database dump
--

\restrict 6ea1kZZoEi9FHDTbaerXuGJl9FBnGUf5PEb1GpCJDRqHa9ndHtM08UfGZRqgxsP

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
-- Name: address_info_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.address_info_view AS
 SELECT DISTINCT tx_out.address,
    tx_out.stake_address_id,
    sa.view AS stake_address,
    encode((sa.script_hash)::bytea, 'hex'::text) AS script_hash
   FROM (public.tx_out
     JOIN public.stake_address sa ON ((tx_out.stake_address_id = sa.id)))
  WITH NO DATA;


--
-- Name: address_info_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX address_info_index_1 ON public.address_info_view USING btree (address);


--
-- Name: address_info_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX address_info_index_2 ON public.address_info_view USING btree (stake_address);


--
-- PostgreSQL database dump complete
--

\unrestrict 6ea1kZZoEi9FHDTbaerXuGJl9FBnGUf5PEb1GpCJDRqHa9ndHtM08UfGZRqgxsP

