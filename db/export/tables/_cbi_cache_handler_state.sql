--
-- PostgreSQL database dump
--

\restrict wVjSvRjgdsotW2itJ4FtX7nWCsCFDp5FD1S9etPSimQQMqxm1lNSo87RnUMdQWB

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
-- Name: _cbi_cache_handler_state; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_cache_handler_state (
    id integer NOT NULL,
    table_name text,
    last_tx_id bigint,
    last_processed_epoch_no bigint,
    last_processed_block_no bigint
);


--
-- Name: _cbi_cache_handler_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._cbi_cache_handler_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _cbi_cache_handler_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._cbi_cache_handler_state_id_seq OWNED BY public._cbi_cache_handler_state.id;


--
-- Name: _cbi_cache_handler_state id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_cache_handler_state ALTER COLUMN id SET DEFAULT nextval('public._cbi_cache_handler_state_id_seq'::regclass);


--
-- Name: _cbi_cache_handler_state _cbi_cache_handler_state_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_cache_handler_state
    ADD CONSTRAINT _cbi_cache_handler_state_pkey PRIMARY KEY (id);


--
-- Name: _cbi_cache_handler_state _cbi_cache_handler_state_table_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_cache_handler_state
    ADD CONSTRAINT _cbi_cache_handler_state_table_name_key UNIQUE (table_name);


--
-- PostgreSQL database dump complete
--

\unrestrict wVjSvRjgdsotW2itJ4FtX7nWCsCFDp5FD1S9etPSimQQMqxm1lNSo87RnUMdQWB

