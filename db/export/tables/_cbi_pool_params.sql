--
-- PostgreSQL database dump
--

\restrict sx80lvN3ee6aMz60gdbS6DcyEGO2MDlVZUgH2U4rv9Ajvwbhtcb4tgtDTBoZEhP

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
-- Name: _cbi_pool_params; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_pool_params (
    id integer NOT NULL,
    pool_id character varying(64) NOT NULL,
    cold_vkey character varying(64) NOT NULL,
    vrf_key character varying(64) NOT NULL
);


--
-- Name: _cbi_pool_params_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._cbi_pool_params_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _cbi_pool_params_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._cbi_pool_params_id_seq OWNED BY public._cbi_pool_params.id;


--
-- Name: _cbi_pool_params id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_pool_params ALTER COLUMN id SET DEFAULT nextval('public._cbi_pool_params_id_seq'::regclass);


--
-- Name: _cbi_pool_params _cbi_pool_params_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_pool_params
    ADD CONSTRAINT _cbi_pool_params_pkey PRIMARY KEY (id);


--
-- Name: _cbi_pool_params _cbi_pool_params_pool_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_pool_params
    ADD CONSTRAINT _cbi_pool_params_pool_id_key UNIQUE (pool_id);


--
-- PostgreSQL database dump complete
--

\unrestrict sx80lvN3ee6aMz60gdbS6DcyEGO2MDlVZUgH2U4rv9Ajvwbhtcb4tgtDTBoZEhP

