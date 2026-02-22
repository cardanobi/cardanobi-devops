--
-- PostgreSQL database dump
--

\restrict dPkvzkBuBPgS0NtOkGUrCaEf14UBKvv8Feh1zGLsavcq9GSo0mdpvjqP0t4ubEs

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
-- Name: pool_stat_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.pool_stat_view AS
 SELECT block.epoch_no,
    pool_hash.view AS pool_hash,
    count(*) AS tx_count
   FROM (((public.tx
     JOIN public.block ON ((tx.block_id = block.id)))
     JOIN public.slot_leader ON ((block.slot_leader_id = slot_leader.id)))
     JOIN public.pool_hash ON ((pool_hash.id = slot_leader.pool_hash_id)))
  GROUP BY block.epoch_no, pool_hash.view
  WITH NO DATA;


--
-- Name: pool_stat_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX pool_stat_index_1 ON public.pool_stat_view USING btree (epoch_no, pool_hash);


--
-- Name: pool_stat_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX pool_stat_index_2 ON public.pool_stat_view USING btree (epoch_no);


--
-- PostgreSQL database dump complete
--

\unrestrict dPkvzkBuBPgS0NtOkGUrCaEf14UBKvv8Feh1zGLsavcq9GSo0mdpvjqP0t4ubEs

