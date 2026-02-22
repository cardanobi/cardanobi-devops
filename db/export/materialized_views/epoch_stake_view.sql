--
-- PostgreSQL database dump
--

\restrict c0hCPAhSIoDcgaNIw0l61575WeEZCnvLz8yFFXKwkf25AVEJQQUZPGpApdZwpDO

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
-- Name: epoch_stake_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.epoch_stake_view AS
 SELECT epoch_stake.id AS epoch_stake_id,
    epoch_stake.amount AS epoch_stake_amount,
    epoch_stake.epoch_no AS epoch_stake_epoch_no,
    pool_hash.view AS pool_hash,
    stake_address.view AS stake_address,
    encode((stake_address.script_hash)::bytea, 'hex'::text) AS stake_address_script_hash_hex,
    stake_address.id AS stake_address_id
   FROM ((public.epoch_stake
     JOIN public.stake_address ON ((epoch_stake.addr_id = stake_address.id)))
     JOIN public.pool_hash ON ((epoch_stake.pool_id = pool_hash.id)))
  WITH NO DATA;


--
-- Name: epoch_stake_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX epoch_stake_index_1 ON public.epoch_stake_view USING btree (epoch_stake_id);


--
-- Name: epoch_stake_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX epoch_stake_index_2 ON public.epoch_stake_view USING btree (epoch_stake_epoch_no);


--
-- Name: epoch_stake_index_4; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX epoch_stake_index_4 ON public.epoch_stake_view USING btree (stake_address);


--
-- Name: epoch_stake_index_6; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX epoch_stake_index_6 ON public.epoch_stake_view USING btree (pool_hash);


--
-- Name: epoch_stake_index_7; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX epoch_stake_index_7 ON public.epoch_stake_view USING btree (stake_address_script_hash_hex);


--
-- PostgreSQL database dump complete
--

\unrestrict c0hCPAhSIoDcgaNIw0l61575WeEZCnvLz8yFFXKwkf25AVEJQQUZPGpApdZwpDO

