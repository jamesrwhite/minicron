--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE alerts (
    id integer NOT NULL,
    job_id integer NOT NULL,
    execution_id integer,
    schedule_id integer,
    kind character varying(4) DEFAULT ''::character varying NOT NULL,
    expected_at timestamp without time zone,
    medium character varying(9) DEFAULT ''::character varying NOT NULL,
    sent_at timestamp without time zone NOT NULL
);


--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE alerts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE alerts_id_seq OWNED BY alerts.id;


--
-- Name: executions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE executions (
    id integer NOT NULL,
    job_id integer NOT NULL,
    number integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    exit_status integer
);


--
-- Name: executions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE executions_id_seq                                                                                                                                                                                                                                                               [398/1845]
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: executions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE executions_id_seq OWNED BY executions.id;


--
-- Name: hosts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE hosts (
    id integer NOT NULL,
    name character varying,
    fqdn character varying DEFAULT ''::character varying NOT NULL,
    "user" character varying(32) DEFAULT ''::character varying NOT NULL,
    host character varying DEFAULT ''::character varying NOT NULL,
    port integer NOT NULL,
    public_key text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: hosts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hosts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hosts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hosts_id_seq OWNED BY hosts.id;


--
-- Name: job_execution_outputs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE job_execution_outputs (
    id integer NOT NULL,
    execution_id integer NOT NULL,
    seq integer NOT NULL,
    output text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL
);


--
-- Name: job_execution_outputs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE job_execution_outputs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_execution_outputs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE job_execution_outputs_id_seq OWNED BY job_execution_outputs.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jobs (
    id integer NOT NULL,
    host_id integer NOT NULL,
    job_hash character varying(32) DEFAULT ''::character varying NOT NULL,
    name character varying,
    "user" character varying(32) NOT NULL,
    command text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: schedules; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schedules (
    id integer NOT NULL,
    job_id integer NOT NULL,
    minute character varying(169),
    hour character varying(61),
    day_of_the_month character varying(83),
    month character varying(26),
    day_of_the_week character varying(13),
    special character varying(9),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

--
-- Name: schedules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE schedules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schedules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE schedules_id_seq OWNED BY schedules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts ALTER COLUMN id SET DEFAULT nextval('alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY executions ALTER COLUMN id SET DEFAULT nextval('executions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts ALTER COLUMN id SET DEFAULT nextval('hosts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY job_execution_outputs ALTER COLUMN id SET DEFAULT nextval('job_execution_outputs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY schedules ALTER COLUMN id SET DEFAULT nextval('schedules_id_seq'::regclass);


--
-- Name: alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('alerts_id_seq', 1, false);


--
-- Name: executions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('executions_id_seq', 1, false);


--
-- Name: hosts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('hosts_id_seq', 1, false);


--
-- Name: job_execution_outputs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('job_execution_outputs_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('jobs_id_seq', 1, false);


--
-- Name: schedules_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('schedules_id_seq', 1, false);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY schema_migrations (version) FROM stdin;
0
\.


--
-- Name: alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: executions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY executions
    ADD CONSTRAINT executions_pkey PRIMARY KEY (id);


--
-- Name: hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT hosts_pkey PRIMARY KEY (id);


--
-- Name: job_execution_outputs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY job_execution_outputs
    ADD CONSTRAINT job_execution_outputs_pkey PRIMARY KEY (id);


--
-- Name: jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (id);


--
-- Name: alerts_execution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX alerts_execution_id ON alerts USING btree (execution_id);


--
-- Name: alerts_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX alerts_job_id ON alerts USING btree (job_id);


--
-- Name: day_of_the_month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX day_of_the_month ON schedules USING btree (day_of_the_month);


--
-- Name: day_of_the_week; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX day_of_the_week ON schedules USING btree (day_of_the_week);


--
-- Name: executions_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX executions_created_at ON executions USING btree (created_at);


--
-- Name: executions_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX executions_job_id ON executions USING btree (job_id);


--
-- Name: expected_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX expected_at ON alerts USING btree (expected_at);


--
-- Name: finished_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX finished_at ON executions USING btree (finished_at);


--
-- Name: host_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX host_id ON jobs USING btree (host_id);


--
-- Name: hostname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hostname ON hosts USING btree (fqdn);


--
-- Name: hour; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hour ON schedules USING btree (hour);


--
-- Name: job_execution_outputs_execution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX job_execution_outputs_execution_id ON job_execution_outputs USING btree (execution_id);


--
-- Name: job_hash; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX job_hash ON jobs USING btree (job_hash);


--
-- Name: jobs_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX jobs_created_at ON jobs USING btree (created_at);


--
-- Name: kind; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX kind ON alerts USING btree (kind);


--
-- Name: medium; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX medium ON alerts USING btree (medium);


--
-- Name: minute; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX minute ON schedules USING btree (minute);


--
-- Name: month; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX month ON schedules USING btree (month);


--
-- Name: schedule_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX schedule_id ON alerts USING btree (schedule_id);


--
-- Name: schedules_job_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX schedules_job_id ON schedules USING btree (job_id);


--
-- Name: seq; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX seq ON job_execution_outputs USING btree (seq);


--
-- Name: special; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX special ON schedules USING btree (special);


--
-- Name: started_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX started_at ON executions USING btree (started_at);


--
-- Name: unique_number_per_job; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_number_per_job ON executions USING btree (job_id, number);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--
