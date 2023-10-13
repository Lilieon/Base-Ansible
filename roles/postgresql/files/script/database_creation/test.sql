--
-- PostgreSQL database dump
--

-- Dumped from database version 13.12 (Debian 13.12-1.pgdg120+1)
-- Dumped by pg_dump version 13.12 (Debian 13.12-1.pgdg120+1)

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
-- Name: testb; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.testb (
    id integer NOT NULL,
    name character varying(100)
);


ALTER TABLE public.testb OWNER TO postgres;

--
-- Name: testb_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.testb_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.testb_id_seq OWNER TO postgres;

--
-- Name: testb_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.testb_id_seq OWNED BY public.testb.id;


--
-- Name: testb id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testb ALTER COLUMN id SET DEFAULT nextval('public.testb_id_seq'::regclass);


--
-- Data for Name: testb; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.testb (id, name) FROM stdin;
\.


--
-- Name: testb_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.testb_id_seq', 1, false);


--
-- Name: testb testb_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.testb
    ADD CONSTRAINT testb_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--
