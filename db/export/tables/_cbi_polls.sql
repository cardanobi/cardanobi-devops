--
-- PostgreSQL database dump
--

\restrict 2LQtHYvHSnjxLOZYgxmLMHq4ifZf3xQzZxvG7R9dqgx7XwXsXQAEwpdh0OfCoHu

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
-- Name: _cbi_polls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cbi_polls (
    id integer NOT NULL,
    tx_id bigint NOT NULL,
    start_epoch_no public.word31type NOT NULL,
    end_epoch_no public.word31type NOT NULL,
    question_hash public.hash32type NOT NULL
);


--
-- Name: _cbi_polls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._cbi_polls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _cbi_polls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._cbi_polls_id_seq OWNED BY public._cbi_polls.id;


--
-- Name: _cbi_polls_tx_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._cbi_polls_tx_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _cbi_polls_tx_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._cbi_polls_tx_id_seq OWNED BY public._cbi_polls.tx_id;


--
-- Name: _cbi_polls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_polls ALTER COLUMN id SET DEFAULT nextval('public._cbi_polls_id_seq'::regclass);


--
-- Name: _cbi_polls tx_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_polls ALTER COLUMN tx_id SET DEFAULT nextval('public._cbi_polls_tx_id_seq'::regclass);


--
-- Name: _cbi_polls _cbi_polls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_polls
    ADD CONSTRAINT _cbi_polls_pkey PRIMARY KEY (id);


--
-- Name: _cbi_polls _cbi_polls_question_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_polls
    ADD CONSTRAINT _cbi_polls_question_hash_key UNIQUE (question_hash);


--
-- Name: _cbi_polls _cbi_polls_tx_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cbi_polls
    ADD CONSTRAINT _cbi_polls_tx_id_key UNIQUE (tx_id);


--
-- Name: idx_cbi_polls_question_hash; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cbi_polls_question_hash ON public._cbi_polls USING btree (question_hash);


--
-- Name: idx_cbi_polls_tx_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cbi_polls_tx_id ON public._cbi_polls USING btree (tx_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 2LQtHYvHSnjxLOZYgxmLMHq4ifZf3xQzZxvG7R9dqgx7XwXsXQAEwpdh0OfCoHu

