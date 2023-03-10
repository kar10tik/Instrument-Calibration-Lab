--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1

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

--
-- Name: order_link(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.order_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.ORDER_ID LIKE 'S%' THEN
INSERT INTO SHIPMENT_ORDER
VALUES(NEW.ORG_ID, NEW.ORDER_ID, NEW.ORDER_DATE);
END IF;
IF NEW.ORDER_ID LIKE 'V%' THEN
INSERT INTO VISIT_ORDER
VALUES (NEW.ORG_ID, NEW.ORDER_ID, NEW.ORDER_DATE);
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.order_link() OWNER TO postgres;

--
-- Name: ship_check(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ship_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF EXTRACT(DAY FROM AGE(NEW.calibration_date, shipment_order.order_date)) < 3
THEN RAISE EXCEPTION 'Instrument not received yet';
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.ship_check() OWNER TO postgres;

--
-- Name: shipment_order_link(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.shipment_order_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.ORDER_ID LIKE 'S%' THEN
INSERT INTO SHIPMENT_ORDER
VALUES(NEW.ORG_ID, NEW.ORDER_ID, NEW.ORDER_DATE, SHIPMENT_FEE, PICKUP_LOCATION);
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.shipment_order_link() OWNER TO postgres;

--
-- Name: visit_order_link(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.visit_order_link() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
IF NEW.ORDER_ID LIKE 'V%' THEN
INSERT INTO VISIT_ORDER
VALUES (NEW.ORG_ID, NEW.ORDER_ID, NEW.ORDER_DATE, LOCATION, VISIT_DATE, VISIT_FEE);
END IF;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.visit_order_link() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: calibration_engg; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibration_engg (
    ce_id character varying(20) NOT NULL,
    name character varying(80) NOT NULL,
    dob date NOT NULL,
    type character varying(40) NOT NULL
);


ALTER TABLE public.calibration_engg OWNER TO postgres;

--
-- Name: calibration_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibration_log (
    log_id integer NOT NULL,
    calibration_date date NOT NULL,
    temperature_c real NOT NULL,
    "%_HUMIDITY" real NOT NULL,
    units character varying(40) NOT NULL,
    calibrator_id integer NOT NULL,
    ce_id character varying(20) NOT NULL,
    instrument_id integer NOT NULL,
    standards_used character varying(80) NOT NULL,
    CONSTRAINT calibration_log_log_id_check CHECK ((log_id > 0))
);


ALTER TABLE public.calibration_log OWNER TO postgres;

--
-- Name: calibrator; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.calibrator (
    calibrator_id integer NOT NULL,
    vendor_id integer NOT NULL,
    model character varying(40) NOT NULL,
    type character varying(50) NOT NULL,
    CONSTRAINT calibrator_calibrator_id_check CHECK ((calibrator_id > 0)),
    CONSTRAINT calibrator_vendor_id_check CHECK ((vendor_id > 0))
);


ALTER TABLE public.calibrator OWNER TO postgres;

--
-- Name: ce_contact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ce_contact (
    ce_id character varying(40) NOT NULL,
    contact_no character varying(15) NOT NULL
);


ALTER TABLE public.ce_contact OWNER TO postgres;

--
-- Name: ext_organization; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ext_organization (
    org_id integer NOT NULL,
    org_name character varying(50) NOT NULL,
    type character varying(25) NOT NULL,
    CONSTRAINT ext_organization_org_id_check CHECK ((org_id > 0))
);


ALTER TABLE public.ext_organization OWNER TO postgres;

--
-- Name: new_joinee_no_calibration; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.new_joinee_no_calibration AS
 SELECT calibration_engg.ce_id,
    calibration_engg.name,
    calibration_engg.dob,
    calibration_engg.type
   FROM public.calibration_engg
  WHERE (NOT ((calibration_engg.ce_id)::text IN ( SELECT calibration_log.ce_id
           FROM public.calibration_log)))
  WITH LOCAL CHECK OPTION;


ALTER TABLE public.new_joinee_no_calibration OWNER TO postgres;

--
-- Name: order_instrument; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_instrument (
    instrument_id integer NOT NULL,
    accuracy real NOT NULL,
    range character varying(40) NOT NULL,
    calibration_cost real NOT NULL,
    manufacturer character varying(40) NOT NULL,
    model character varying(40) NOT NULL,
    order_id character varying(20) NOT NULL,
    units character varying(40) NOT NULL,
    ce_id character varying(20) NOT NULL,
    class character varying(50) NOT NULL,
    type character varying(50) NOT NULL,
    subtype character varying(50) NOT NULL,
    CONSTRAINT order_instrument_accuracy_check CHECK ((accuracy > (0)::double precision)),
    CONSTRAINT order_instrument_calibration_cost_check CHECK ((calibration_cost > (0)::double precision)),
    CONSTRAINT order_instrument_instrument_id_check CHECK ((instrument_id > 0))
);


ALTER TABLE public.order_instrument OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    org_id integer NOT NULL,
    order_id character varying(20) NOT NULL,
    order_date date NOT NULL,
    CONSTRAINT orders_order_date_check CHECK ((order_date < CURRENT_DATE)),
    CONSTRAINT orders_org_id_check CHECK ((org_id > 0))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: repair; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.repair (
    repair_id character varying(20) NOT NULL,
    repair_date date NOT NULL,
    calibrator_id integer NOT NULL,
    vendor_id integer NOT NULL
);


ALTER TABLE public.repair OWNER TO postgres;

--
-- Name: shipment_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipment_order (
    org_id integer NOT NULL,
    order_id character varying(20) NOT NULL,
    order_date date NOT NULL,
    shipment_fee real NOT NULL,
    pickup_location character varying(150) NOT NULL,
    CONSTRAINT shipment_order_order_date_check CHECK ((order_date < CURRENT_DATE)),
    CONSTRAINT shipment_order_org_id_check CHECK ((org_id > 0)),
    CONSTRAINT shipment_order_shipment_fee_check CHECK ((shipment_fee > (0)::double precision))
);


ALTER TABLE public.shipment_order OWNER TO postgres;

--
-- Name: vendor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendor (
    vendor_id integer NOT NULL,
    vendor_name character varying(40) NOT NULL,
    CONSTRAINT vendor_vendor_id_check CHECK ((vendor_id > 0))
);


ALTER TABLE public.vendor OWNER TO postgres;

--
-- Name: visit_order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.visit_order (
    org_id integer NOT NULL,
    order_id character varying(20) NOT NULL,
    order_date date NOT NULL,
    visit_fee real NOT NULL,
    location character varying(150) NOT NULL,
    visit_date date NOT NULL,
    CONSTRAINT site_visit_order_order_date_check CHECK ((order_date < CURRENT_DATE)),
    CONSTRAINT site_visit_order_org_id_check CHECK ((org_id > 0)),
    CONSTRAINT site_visit_order_visit_fee_check CHECK ((visit_fee > (0)::double precision))
);


ALTER TABLE public.visit_order OWNER TO postgres;

--
-- Name: work_schedule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.work_schedule (
    days_worked integer NOT NULL,
    ce_id character varying(20) NOT NULL,
    year integer NOT NULL,
    week_no integer NOT NULL,
    schedule_id integer NOT NULL,
    CONSTRAINT valid_schedule CHECK (((year <= (EXTRACT(year FROM CURRENT_DATE))::integer) AND (0 < week_no) AND (week_no < 53))),
    CONSTRAINT work_schedule_days_worked_check CHECK ((days_worked < 7))
);


ALTER TABLE public.work_schedule OWNER TO postgres;

--
-- Data for Name: calibration_engg; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calibration_engg (ce_id, name, dob, type) FROM stdin;
T001	Sonu	1982-03-07	Thermal
ME001	Mayank	1986-05-09	Mechanical
T002	Sonarika	1990-10-29	Thermal
EE001	Sonal	1991-11-19	Electrical
ME002	Vishnu	1986-03-30	Mechanical
EE002	Ankit	1991-06-30	Electrical
T003	Nakul	1990-05-20	Thermal
EE003	Preeti	1986-07-06	Electrical
ME003	Yamuna	1986-03-30	Mechanical
\.


--
-- Data for Name: calibration_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calibration_log (log_id, calibration_date, temperature_c, "%_HUMIDITY", units, calibrator_id, ce_id, instrument_id, standards_used) FROM stdin;
10	2022-01-07	28	28.8	celsius	30006	T003	1010	ISO_Temp_Analog
7	2021-06-09	33	20	kg	30004	ME003	1006	ISO_Weights
2	2021-07-08	35	25.6	volt	30005	EE003	1003	ISO_Voltage_Analog
3	2019-05-05	33	27.6	rpm	30005	EE001	1002	ISO_Speed_Digial
4	2018-07-09	30	28.7	volt	30008	EE003	1007	ISO_Voltage_Digial
6	2021-06-09	36	20.9	microliters	30002	ME001	1005	ISO_Micropipette
5	2021-09-04	28	25.7	celsius	30006	T001	1004	ISO_Temp_Analog
8	2015-05-05	33	20	pH	30008	EE003	1008	ISO_pH
9	2017-01-05	29	29.6	millimeter	30004	ME003	1009	ISO_length
1	2020-03-12	33	25.7	milliamp	30005	EE001	1001	Current_Analog
\.


--
-- Data for Name: calibrator; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.calibrator (calibrator_id, vendor_id, model, type) FROM stdin;
30003	3003	SA166	Electrical
30005	3005	PI314	Electrical
30008	3008	EDX00	Electrical
30001	3001	725XE	Electrical
30002	3002	PC507	Mechanical
30004	3004	TR453	Mechanical
30007	3007	AM101	Thermal
30006	3006	SK256	Thermal
\.


--
-- Data for Name: ce_contact; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ce_contact (ce_id, contact_no) FROM stdin;
T002	9800608777
ME002	9805558777
EE002	9805677777
ME003	9803337777
EE003	9803337667
T003	9803335567
T001	9999998888
ME001	9979998788
EE001	9979608788
T002	3777444880
ME002	3777094880
\.


--
-- Data for Name: ext_organization; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ext_organization (org_id, org_name, type) FROM stdin;
1	TI	Industrial
2	CASIO	Industrial
3	SAMSUNG	Industrial
4	BOSCH	Industrial
5	NSUT	Academic
6	DTU	Academic
7	IITD	Academic
8	IITM	Academic
\.


--
-- Data for Name: order_instrument; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_instrument (instrument_id, accuracy, range, calibration_cost, manufacturer, model, order_id, units, ce_id, class, type, subtype) FROM stdin;
1001	0.1	0-10	650	Technometer	Ammeter-01	S0001	milliamp	EE001	Analog	Electrical	Ammeter
1003	0.4	0-50	150	Circutor	Voltmeter-01	V0001	volt	EE003	Analog	Electrical	Voltmeter
1002	0.25	0-3000	1650	Crompton	Tachometer-01	S0004	rpm	EE001	Digital	Electrical	Tachometer
1007	0.2	0-100	450	Tektronix	DSO-1G-01	S0002	volt	EE003	Digital	Electrical	DSO
1004	0.25	-100-1000	850	Intek	Thermocouple-E01	S0003	celsius	T001	Analog	Thermal	Thermocouple
1005	0.25	1-1000	550	Merck	Micropipette-E01	S0005	microliters	ME001	Analog	Mechanical	Micropipette
1006	0.35	0-500	850	Suntech	Load Cell-01	S0005	kg	ME003	Analog	Mechanical	Load Cell
1008	0.2	0-14	1050	Merck	pH-meter-01	V0002	pH	EE003	Analog	Electrical	pH meter
1009	0.01	0-1828	750	Scitools	Vernier-Caliper-01	V0004	millimeter	ME003	Analog	Mechanical	Vernier
1010	0.3	-55-155	650	Kelvin	Thermistor-PTC-01	V0003	celsius	T003	Analog	Thermal	Thermistor_PTC
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (org_id, order_id, order_date) FROM stdin;
1	S0001	2020-03-09
3	S0003	2021-09-01
5	V0001	2021-07-04
7	V0003	2022-01-03
1	V0005	2020-09-05
7	S0005	2021-06-06
2	S0002	2018-07-06
4	S0004	2019-05-02
6	V0002	2015-05-02
8	V0004	2017-01-03
\.


--
-- Data for Name: repair; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.repair (repair_id, repair_date, calibrator_id, vendor_id) FROM stdin;
R0001	2021-01-01	30001	3001
R0002	2021-02-03	30002	3002
R0003	2018-01-01	30001	3001
R0004	2019-01-01	30003	3003
R0005	2020-06-01	30004	3004
R0006	2021-12-09	30005	3005
R0007	2020-11-11	30006	3006
R0008	2020-02-11	30007	3007
R0009	2021-01-01	30008	3008
R0010	2022-02-01	30003	3003
\.


--
-- Data for Name: shipment_order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipment_order (org_id, order_id, order_date, shipment_fee, pickup_location) FROM stdin;
7	S0005	2021-06-06	150	Delhi
1	S0001	2020-03-09	200	Bengaluru
3	S0003	2021-09-01	200	Noida
2	S0002	2018-07-06	200	Chennai
4	S0004	2019-05-02	200	Kolkata
\.


--
-- Data for Name: vendor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendor (vendor_id, vendor_name) FROM stdin;
3001	Fluke
3002	Presys
3003	Sansel
3004	Transmille
3005	Piecal
3006	Sika
3007	Ametek
3008	Edxrf
\.


--
-- Data for Name: visit_order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.visit_order (org_id, order_id, order_date, visit_fee, location, visit_date) FROM stdin;
7	V0003	2022-01-03	250	Delhi	2022-01-07
5	V0001	2021-07-04	250	Delhi	2021-07-08
1	V0005	2020-09-05	300	Bengaluru	2020-09-07
6	V0002	2015-05-02	250	Delhi	2015-05-05
8	V0004	2017-01-03	300	Chennai	2017-01-05
\.


--
-- Data for Name: work_schedule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.work_schedule (days_worked, ce_id, year, week_no, schedule_id) FROM stdin;
4	T001	2022	5	1
0	T002	2022	5	2
5	ME001	2022	5	3
2	ME002	2022	5	4
5	ME003	2022	5	5
5	EE001	2022	5	6
4	EE002	2022	5	7
1	EE003	2022	5	8
\.


--
-- Name: calibration_engg calibration_engg_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibration_engg
    ADD CONSTRAINT calibration_engg_pkey PRIMARY KEY (ce_id);


--
-- Name: calibration_log calibration_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibration_log
    ADD CONSTRAINT calibration_log_pkey PRIMARY KEY (log_id);


--
-- Name: calibrator calibrator_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibrator
    ADD CONSTRAINT calibrator_pkey PRIMARY KEY (calibrator_id);


--
-- Name: ext_organization ext_organization_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ext_organization
    ADD CONSTRAINT ext_organization_pkey PRIMARY KEY (org_id);


--
-- Name: order_instrument instr_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_instrument
    ADD CONSTRAINT instr_pk PRIMARY KEY (instrument_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (order_id);


--
-- Name: ce_contact prim_1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ce_contact
    ADD CONSTRAINT prim_1 PRIMARY KEY (ce_id, contact_no);


--
-- Name: work_schedule prim_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedule
    ADD CONSTRAINT prim_key PRIMARY KEY (schedule_id, ce_id);


--
-- Name: repair repair_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repair
    ADD CONSTRAINT repair_pkey PRIMARY KEY (repair_id);


--
-- Name: shipment_order shipment_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_order
    ADD CONSTRAINT shipment_order_pkey PRIMARY KEY (order_id);


--
-- Name: visit_order site_visit_order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visit_order
    ADD CONSTRAINT site_visit_order_pkey PRIMARY KEY (order_id);


--
-- Name: vendor vendor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendor
    ADD CONSTRAINT vendor_pkey PRIMARY KEY (vendor_id);


--
-- Name: calibration_log ship_receive_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ship_receive_check BEFORE INSERT ON public.calibration_log FOR EACH ROW EXECUTE FUNCTION public.ship_check();


--
-- Name: shipment_order ship_receive_check; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ship_receive_check BEFORE INSERT ON public.shipment_order FOR EACH ROW EXECUTE FUNCTION public.ship_check();


--
-- Name: orders shipment_inserts; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER shipment_inserts AFTER INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.shipment_order_link('shipment_fee', 'pickup_location');


--
-- Name: orders visit_order_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER visit_order_insert AFTER INSERT ON public.orders FOR EACH ROW EXECUTE FUNCTION public.visit_order_link('location', 'visit_date', 'visit_fee');


--
-- Name: calibration_log calibration_log_calibrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibration_log
    ADD CONSTRAINT calibration_log_calibrator_id_fkey FOREIGN KEY (calibrator_id) REFERENCES public.calibrator(calibrator_id) ON UPDATE CASCADE;


--
-- Name: calibration_log calibration_log_ce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibration_log
    ADD CONSTRAINT calibration_log_ce_id_fkey FOREIGN KEY (ce_id) REFERENCES public.calibration_engg(ce_id) ON UPDATE CASCADE;


--
-- Name: calibration_log calibration_log_instrument_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibration_log
    ADD CONSTRAINT calibration_log_instrument_id_fkey FOREIGN KEY (instrument_id) REFERENCES public.order_instrument(instrument_id) ON UPDATE CASCADE;


--
-- Name: calibrator calibrator_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.calibrator
    ADD CONSTRAINT calibrator_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendor(vendor_id);


--
-- Name: ce_contact ce_contact_ce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ce_contact
    ADD CONSTRAINT ce_contact_ce_id_fkey FOREIGN KEY (ce_id) REFERENCES public.calibration_engg(ce_id) ON UPDATE CASCADE;


--
-- Name: order_instrument order_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_instrument
    ADD CONSTRAINT order_fk FOREIGN KEY (order_id) REFERENCES public.orders(order_id) ON UPDATE CASCADE;


--
-- Name: orders orders_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_fk FOREIGN KEY (org_id) REFERENCES public.ext_organization(org_id) ON UPDATE CASCADE;


--
-- Name: repair repair_calibrator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repair
    ADD CONSTRAINT repair_calibrator_id_fkey FOREIGN KEY (calibrator_id) REFERENCES public.calibrator(calibrator_id) ON UPDATE CASCADE;


--
-- Name: shipment_order shipment_order_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_order
    ADD CONSTRAINT shipment_order_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.ext_organization(org_id);


--
-- Name: visit_order site_visit_order_org_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.visit_order
    ADD CONSTRAINT site_visit_order_org_id_fkey FOREIGN KEY (org_id) REFERENCES public.ext_organization(org_id);


--
-- Name: repair vendor_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.repair
    ADD CONSTRAINT vendor_fk FOREIGN KEY (vendor_id) REFERENCES public.vendor(vendor_id) ON UPDATE CASCADE;


--
-- Name: work_schedule work_schedule_ce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.work_schedule
    ADD CONSTRAINT work_schedule_ce_id_fkey FOREIGN KEY (ce_id) REFERENCES public.calibration_engg(ce_id);


--
-- PostgreSQL database dump complete
--

