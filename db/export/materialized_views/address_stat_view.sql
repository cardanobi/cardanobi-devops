--
-- PostgreSQL database dump
--

\restrict bYIDwHgRonvI2ehMfnYs4cSQwUbf42Qf4w8LWq7Xq5SB24cHdVUyxFy6171HZ78

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
-- Name: address_stat_view; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.address_stat_view AS
 SELECT block.epoch_no,
    sa.view AS stake_address,
    count(*) AS tx_count
   FROM (((public.tx
     JOIN public.block ON ((tx.block_id = block.id)))
     JOIN public.tx_out ON ((tx.id = tx_out.tx_id)))
     JOIN public.stake_address sa ON ((tx_out.stake_address_id = sa.id)))
  GROUP BY block.epoch_no, sa.id
  WITH NO DATA;


--
-- Name: address_stat_index_1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX address_stat_index_1 ON public.address_stat_view USING btree (epoch_no, stake_address);


--
-- Name: address_stat_index_2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX address_stat_index_2 ON public.address_stat_view USING btree (epoch_no);


--
-- Name: address_stat_index_3; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX address_stat_index_3 ON public.address_stat_view USING btree (stake_address);


--
-- PostgreSQL database dump complete
--

\unrestrict bYIDwHgRonvI2ehMfnYs4cSQwUbf42Qf4w8LWq7Xq5SB24cHdVUyxFy6171HZ78

