--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

-- Started on 2022-10-28 10:55:52

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
-- TOC entry 217 (class 1259 OID 16415)
-- Name: T_analyses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_analyses" (
    "CdStationMesureEauxSurface" "char" NOT NULL,
    "CdSupport" "char",
    "CdFractionAnalysee" "char",
    "CdPrelevement" "char",
    "DatePrel" date,
    "HeurePrel" time without time zone,
    "DateAna" date,
    "HeureAna" time without time zone,
    "CdParametre" "char",
    "RsAna" numeric,
    "CdInsituAna" "char",
    "ProfondeurPrel" numeric,
    "CdDifficulteAna" "char",
    "LdAna" numeric,
    "LqAna" numeric,
    "LsAna" numeric,
    "IncertAna" "char",
    "CdMetFractionnement" "char",
    "CdMethode" "char",
    "RdtExtraction" numeric,
    "CdMethodeExtraction" "char",
    "CdAccrePrel" "char",
    "CdAccreAna" "char",
    "AgreAna" boolean,
    "CdStatutAna" "char",
    "CdQualAna" "char",
    "CommentairesAna" "char",
    "ComResultatAna" "char",
    "CdProducteur" "char",
    "CdPreleveur" "char",
    "CdLaboratoire" "char",
    id_analyse bigint NOT NULL
);


ALTER TABLE public."T_analyses" OWNER TO postgres;

--
-- TOC entry 3418 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE "T_analyses"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_analyses" IS 'Table analyses de l''appli libreSQE';


--
-- TOC entry 216 (class 1259 OID 16414)
-- Name: T_analyses_id_analyse_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_analyses_id_analyse_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_analyses_id_analyse_seq" OWNER TO postgres;

--
-- TOC entry 3419 (class 0 OID 0)
-- Dependencies: 216
-- Name: T_analyses_id_analyse_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_analyses_id_analyse_seq" OWNED BY public."T_analyses".id_analyse;


--
-- TOC entry 229 (class 1259 OID 16458)
-- Name: T_bpu; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_bpu" (
    id_prestation bigint NOT NULL,
    date_debut_prix_presta date,
    date_fin_prix_presta date,
    "prix_HT" numeric,
    "prix_TTC" numeric
);


ALTER TABLE public."T_bpu" OWNER TO postgres;

--
-- TOC entry 3420 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE "T_bpu"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_bpu" IS 'Table des bordereaux de prix par prestation';


--
-- TOC entry 228 (class 1259 OID 16457)
-- Name: T_bpu_id_prestation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_bpu_id_prestation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_bpu_id_prestation_seq" OWNER TO postgres;

--
-- TOC entry 3421 (class 0 OID 0)
-- Dependencies: 228
-- Name: T_bpu_id_prestation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_bpu_id_prestation_seq" OWNED BY public."T_bpu".id_prestation;


--
-- TOC entry 213 (class 1259 OID 16404)
-- Name: T_droits_marche; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_droits_marche" (
    id_marche integer NOT NULL,
    id_utilisateur integer NOT NULL,
    droits smallint
);


ALTER TABLE public."T_droits_marche" OWNER TO postgres;

--
-- TOC entry 3422 (class 0 OID 0)
-- Dependencies: 213
-- Name: TABLE "T_droits_marche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_droits_marche" IS 'Table des droits par marché et par utilisateur pour libreSQE';


--
-- TOC entry 211 (class 1259 OID 16402)
-- Name: T_droits_marche_id_marche_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_droits_marche_id_marche_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_droits_marche_id_marche_seq" OWNER TO postgres;

--
-- TOC entry 3423 (class 0 OID 0)
-- Dependencies: 211
-- Name: T_droits_marche_id_marche_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_droits_marche_id_marche_seq" OWNED BY public."T_droits_marche".id_marche;


--
-- TOC entry 212 (class 1259 OID 16403)
-- Name: T_droits_marche_id_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_droits_marche_id_utilisateur_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_droits_marche_id_utilisateur_seq" OWNER TO postgres;

--
-- TOC entry 3424 (class 0 OID 0)
-- Dependencies: 212
-- Name: T_droits_marche_id_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_droits_marche_id_utilisateur_seq" OWNED BY public."T_droits_marche".id_utilisateur;


--
-- TOC entry 232 (class 1259 OID 16466)
-- Name: T_marche; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_marche" (
    id_prestataire integer NOT NULL,
    id_marche integer NOT NULL,
    perimetre_marche "char",
    montant_min numeric,
    montant_max numeric,
    date_debut_marche date,
    date_fin_marche date,
    statut_marche "char"
);


ALTER TABLE public."T_marche" OWNER TO postgres;

--
-- TOC entry 3425 (class 0 OID 0)
-- Dependencies: 232
-- Name: TABLE "T_marche"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_marche" IS 'Table des marchés';


--
-- TOC entry 231 (class 1259 OID 16465)
-- Name: T_marche_id_marche_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_marche_id_marche_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_marche_id_marche_seq" OWNER TO postgres;

--
-- TOC entry 3426 (class 0 OID 0)
-- Dependencies: 231
-- Name: T_marche_id_marche_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_marche_id_marche_seq" OWNED BY public."T_marche".id_marche;


--
-- TOC entry 230 (class 1259 OID 16464)
-- Name: T_marche_id_prestataire_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_marche_id_prestataire_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_marche_id_prestataire_seq" OWNER TO postgres;

--
-- TOC entry 3427 (class 0 OID 0)
-- Dependencies: 230
-- Name: T_marche_id_prestataire_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_marche_id_prestataire_seq" OWNED BY public."T_marche".id_prestataire;


--
-- TOC entry 235 (class 1259 OID 16478)
-- Name: T_marche_pgmtype; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_marche_pgmtype" (
    id_marche integer NOT NULL,
    nom_programme "char",
    id_prestation bigint NOT NULL
);


ALTER TABLE public."T_marche_pgmtype" OWNER TO postgres;

--
-- TOC entry 3428 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE "T_marche_pgmtype"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_marche_pgmtype" IS 'Table correspondance marchés / programmes types';


--
-- TOC entry 233 (class 1259 OID 16476)
-- Name: T_marche_pgmtype_id_marche_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_marche_pgmtype_id_marche_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_marche_pgmtype_id_marche_seq" OWNER TO postgres;

--
-- TOC entry 3429 (class 0 OID 0)
-- Dependencies: 233
-- Name: T_marche_pgmtype_id_marche_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_marche_pgmtype_id_marche_seq" OWNED BY public."T_marche_pgmtype".id_marche;


--
-- TOC entry 234 (class 1259 OID 16477)
-- Name: T_marche_pgmtype_id_prestation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_marche_pgmtype_id_prestation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_marche_pgmtype_id_prestation_seq" OWNER TO postgres;

--
-- TOC entry 3430 (class 0 OID 0)
-- Dependencies: 234
-- Name: T_marche_pgmtype_id_prestation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_marche_pgmtype_id_prestation_seq" OWNED BY public."T_marche_pgmtype".id_prestation;


--
-- TOC entry 224 (class 1259 OID 16444)
-- Name: T_parametres_presta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_parametres_presta" (
    id_prestation bigint NOT NULL,
    "CdParametre" "char",
    "CdSupport" "char",
    "CdFraction" "char",
    "CdUniteMesure" "char",
    "LqEngagement" numeric,
    "IncertitudeEngagement" numeric
);


ALTER TABLE public."T_parametres_presta" OWNER TO postgres;

--
-- TOC entry 3431 (class 0 OID 0)
-- Dependencies: 224
-- Name: TABLE "T_parametres_presta"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_parametres_presta" IS 'Table listant pour chaque id_prestation la liste des paramètres et les perf analytiques attendues';


--
-- TOC entry 223 (class 1259 OID 16443)
-- Name: T_parametres_presta_id_prestation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_parametres_presta_id_prestation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_parametres_presta_id_prestation_seq" OWNER TO postgres;

--
-- TOC entry 3432 (class 0 OID 0)
-- Dependencies: 223
-- Name: T_parametres_presta_id_prestation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_parametres_presta_id_prestation_seq" OWNED BY public."T_parametres_presta".id_prestation;


--
-- TOC entry 222 (class 1259 OID 16437)
-- Name: T_presta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_presta" (
    id_prestation bigint NOT NULL,
    "CdStationMesureEauxSurface" "char",
    "DateQualifPresta" date,
    "StatutPresta" "char"
);


ALTER TABLE public."T_presta" OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16436)
-- Name: T_presta_id_prestation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_presta_id_prestation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_presta_id_prestation_seq" OWNER TO postgres;

--
-- TOC entry 3433 (class 0 OID 0)
-- Dependencies: 221
-- Name: T_presta_id_prestation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_presta_id_prestation_seq" OWNED BY public."T_presta".id_prestation;


--
-- TOC entry 219 (class 1259 OID 16424)
-- Name: T_prestataires; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_prestataires" (
    id_prestataire integer NOT NULL,
    nom_court_prestataire "char" NOT NULL,
    adresse_prestataire "char",
    siret_prestataire "char",
    nom_complet_prestataire "char"
);


ALTER TABLE public."T_prestataires" OWNER TO postgres;

--
-- TOC entry 3434 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE "T_prestataires"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_prestataires" IS 'Prestataires';


--
-- TOC entry 218 (class 1259 OID 16423)
-- Name: T_prestataires_id_prestataire_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_prestataires_id_prestataire_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_prestataires_id_prestataire_seq" OWNER TO postgres;

--
-- TOC entry 3435 (class 0 OID 0)
-- Dependencies: 218
-- Name: T_prestataires_id_prestataire_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_prestataires_id_prestataire_seq" OWNED BY public."T_prestataires".id_prestataire;


--
-- TOC entry 227 (class 1259 OID 16452)
-- Name: T_prog_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_prog_types" (
    id_programme bigint NOT NULL,
    id_prestation bigint NOT NULL,
    nom_prestation "char"
);


ALTER TABLE public."T_prog_types" OWNER TO postgres;

--
-- TOC entry 3436 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE "T_prog_types"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_prog_types" IS 'Table des programmes types';


--
-- TOC entry 226 (class 1259 OID 16451)
-- Name: T_prog_types_id_prestation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_prog_types_id_prestation_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_prog_types_id_prestation_seq" OWNER TO postgres;

--
-- TOC entry 3437 (class 0 OID 0)
-- Dependencies: 226
-- Name: T_prog_types_id_prestation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_prog_types_id_prestation_seq" OWNED BY public."T_prog_types".id_prestation;


--
-- TOC entry 225 (class 1259 OID 16450)
-- Name: T_prog_types_id_programme_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_prog_types_id_programme_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_prog_types_id_programme_seq" OWNER TO postgres;

--
-- TOC entry 3438 (class 0 OID 0)
-- Dependencies: 225
-- Name: T_prog_types_id_programme_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_prog_types_id_programme_seq" OWNED BY public."T_prog_types".id_programme;


--
-- TOC entry 215 (class 1259 OID 16410)
-- Name: T_rsx_analyses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_rsx_analyses" (
    id_analyse bigint NOT NULL,
    "CdRdd" "char" NOT NULL
);


ALTER TABLE public."T_rsx_analyses" OWNER TO postgres;

--
-- TOC entry 3439 (class 0 OID 0)
-- Dependencies: 215
-- Name: TABLE "T_rsx_analyses"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_rsx_analyses" IS 'Table de libreSQE qui fait le lien entre le(s) réseaux et l''analyse d''eau';


--
-- TOC entry 214 (class 1259 OID 16409)
-- Name: T_rsx_analyses_id_analyse_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_rsx_analyses_id_analyse_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_rsx_analyses_id_analyse_seq" OWNER TO postgres;

--
-- TOC entry 3440 (class 0 OID 0)
-- Dependencies: 214
-- Name: T_rsx_analyses_id_analyse_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_rsx_analyses_id_analyse_seq" OWNED BY public."T_rsx_analyses".id_analyse;


--
-- TOC entry 210 (class 1259 OID 16396)
-- Name: T_utilisateurs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."T_utilisateurs" (
    id_utilisateur integer NOT NULL,
    nom_utilisateur "char",
    prenom_utilisateur "char",
    mail_utilisateur "char",
    password "char",
    id_prestataire integer NOT NULL
);


ALTER TABLE public."T_utilisateurs" OWNER TO postgres;

--
-- TOC entry 3441 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE "T_utilisateurs"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public."T_utilisateurs" IS 'table des utilisateurs de libreSQE';


--
-- TOC entry 220 (class 1259 OID 16430)
-- Name: T_utilisateurs_id_prestataire_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_utilisateurs_id_prestataire_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_utilisateurs_id_prestataire_seq" OWNER TO postgres;

--
-- TOC entry 3442 (class 0 OID 0)
-- Dependencies: 220
-- Name: T_utilisateurs_id_prestataire_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_utilisateurs_id_prestataire_seq" OWNED BY public."T_utilisateurs".id_prestataire;


--
-- TOC entry 209 (class 1259 OID 16395)
-- Name: T_utilisateurs_id_utilisateur_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."T_utilisateurs_id_utilisateur_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."T_utilisateurs_id_utilisateur_seq" OWNER TO postgres;

--
-- TOC entry 3443 (class 0 OID 0)
-- Dependencies: 209
-- Name: T_utilisateurs_id_utilisateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."T_utilisateurs_id_utilisateur_seq" OWNED BY public."T_utilisateurs".id_utilisateur;


--
-- TOC entry 3224 (class 2604 OID 16418)
-- Name: T_analyses id_analyse; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_analyses" ALTER COLUMN id_analyse SET DEFAULT nextval('public."T_analyses_id_analyse_seq"'::regclass);


--
-- TOC entry 3230 (class 2604 OID 16461)
-- Name: T_bpu id_prestation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_bpu" ALTER COLUMN id_prestation SET DEFAULT nextval('public."T_bpu_id_prestation_seq"'::regclass);


--
-- TOC entry 3221 (class 2604 OID 16407)
-- Name: T_droits_marche id_marche; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_droits_marche" ALTER COLUMN id_marche SET DEFAULT nextval('public."T_droits_marche_id_marche_seq"'::regclass);


--
-- TOC entry 3222 (class 2604 OID 16408)
-- Name: T_droits_marche id_utilisateur; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_droits_marche" ALTER COLUMN id_utilisateur SET DEFAULT nextval('public."T_droits_marche_id_utilisateur_seq"'::regclass);


--
-- TOC entry 3231 (class 2604 OID 16469)
-- Name: T_marche id_prestataire; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche" ALTER COLUMN id_prestataire SET DEFAULT nextval('public."T_marche_id_prestataire_seq"'::regclass);


--
-- TOC entry 3232 (class 2604 OID 16470)
-- Name: T_marche id_marche; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche" ALTER COLUMN id_marche SET DEFAULT nextval('public."T_marche_id_marche_seq"'::regclass);


--
-- TOC entry 3233 (class 2604 OID 16481)
-- Name: T_marche_pgmtype id_marche; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche_pgmtype" ALTER COLUMN id_marche SET DEFAULT nextval('public."T_marche_pgmtype_id_marche_seq"'::regclass);


--
-- TOC entry 3234 (class 2604 OID 16482)
-- Name: T_marche_pgmtype id_prestation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche_pgmtype" ALTER COLUMN id_prestation SET DEFAULT nextval('public."T_marche_pgmtype_id_prestation_seq"'::regclass);


--
-- TOC entry 3227 (class 2604 OID 16447)
-- Name: T_parametres_presta id_prestation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_parametres_presta" ALTER COLUMN id_prestation SET DEFAULT nextval('public."T_parametres_presta_id_prestation_seq"'::regclass);


--
-- TOC entry 3226 (class 2604 OID 16440)
-- Name: T_presta id_prestation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_presta" ALTER COLUMN id_prestation SET DEFAULT nextval('public."T_presta_id_prestation_seq"'::regclass);


--
-- TOC entry 3225 (class 2604 OID 16427)
-- Name: T_prestataires id_prestataire; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_prestataires" ALTER COLUMN id_prestataire SET DEFAULT nextval('public."T_prestataires_id_prestataire_seq"'::regclass);


--
-- TOC entry 3228 (class 2604 OID 16455)
-- Name: T_prog_types id_programme; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_prog_types" ALTER COLUMN id_programme SET DEFAULT nextval('public."T_prog_types_id_programme_seq"'::regclass);


--
-- TOC entry 3229 (class 2604 OID 16456)
-- Name: T_prog_types id_prestation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_prog_types" ALTER COLUMN id_prestation SET DEFAULT nextval('public."T_prog_types_id_prestation_seq"'::regclass);


--
-- TOC entry 3223 (class 2604 OID 16413)
-- Name: T_rsx_analyses id_analyse; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_rsx_analyses" ALTER COLUMN id_analyse SET DEFAULT nextval('public."T_rsx_analyses_id_analyse_seq"'::regclass);


--
-- TOC entry 3219 (class 2604 OID 16399)
-- Name: T_utilisateurs id_utilisateur; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_utilisateurs" ALTER COLUMN id_utilisateur SET DEFAULT nextval('public."T_utilisateurs_id_utilisateur_seq"'::regclass);


--
-- TOC entry 3220 (class 2604 OID 16431)
-- Name: T_utilisateurs id_prestataire; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_utilisateurs" ALTER COLUMN id_prestataire SET DEFAULT nextval('public."T_utilisateurs_id_prestataire_seq"'::regclass);


--
-- TOC entry 3394 (class 0 OID 16415)
-- Dependencies: 217
-- Data for Name: T_analyses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_analyses" ("CdStationMesureEauxSurface", "CdSupport", "CdFractionAnalysee", "CdPrelevement", "DatePrel", "HeurePrel", "DateAna", "HeureAna", "CdParametre", "RsAna", "CdInsituAna", "ProfondeurPrel", "CdDifficulteAna", "LdAna", "LqAna", "LsAna", "IncertAna", "CdMetFractionnement", "CdMethode", "RdtExtraction", "CdMethodeExtraction", "CdAccrePrel", "CdAccreAna", "AgreAna", "CdStatutAna", "CdQualAna", "CommentairesAna", "ComResultatAna", "CdProducteur", "CdPreleveur", "CdLaboratoire", id_analyse) FROM stdin;
\.


--
-- TOC entry 3406 (class 0 OID 16458)
-- Dependencies: 229
-- Data for Name: T_bpu; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_bpu" (id_prestation, date_debut_prix_presta, date_fin_prix_presta, "prix_HT", "prix_TTC") FROM stdin;
\.


--
-- TOC entry 3390 (class 0 OID 16404)
-- Dependencies: 213
-- Data for Name: T_droits_marche; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_droits_marche" (id_marche, id_utilisateur, droits) FROM stdin;
\.


--
-- TOC entry 3409 (class 0 OID 16466)
-- Dependencies: 232
-- Data for Name: T_marche; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_marche" (id_prestataire, id_marche, perimetre_marche, montant_min, montant_max, date_debut_marche, date_fin_marche, statut_marche) FROM stdin;
\.


--
-- TOC entry 3412 (class 0 OID 16478)
-- Dependencies: 235
-- Data for Name: T_marche_pgmtype; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_marche_pgmtype" (id_marche, nom_programme, id_prestation) FROM stdin;
\.


--
-- TOC entry 3401 (class 0 OID 16444)
-- Dependencies: 224
-- Data for Name: T_parametres_presta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_parametres_presta" (id_prestation, "CdParametre", "CdSupport", "CdFraction", "CdUniteMesure", "LqEngagement", "IncertitudeEngagement") FROM stdin;
\.


--
-- TOC entry 3399 (class 0 OID 16437)
-- Dependencies: 222
-- Data for Name: T_presta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_presta" (id_prestation, "CdStationMesureEauxSurface", "DateQualifPresta", "StatutPresta") FROM stdin;
\.


--
-- TOC entry 3396 (class 0 OID 16424)
-- Dependencies: 219
-- Data for Name: T_prestataires; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_prestataires" (id_prestataire, nom_court_prestataire, adresse_prestataire, siret_prestataire, nom_complet_prestataire) FROM stdin;
\.


--
-- TOC entry 3404 (class 0 OID 16452)
-- Dependencies: 227
-- Data for Name: T_prog_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_prog_types" (id_programme, id_prestation, nom_prestation) FROM stdin;
\.


--
-- TOC entry 3392 (class 0 OID 16410)
-- Dependencies: 215
-- Data for Name: T_rsx_analyses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_rsx_analyses" (id_analyse, "CdRdd") FROM stdin;
\.


--
-- TOC entry 3387 (class 0 OID 16396)
-- Dependencies: 210
-- Data for Name: T_utilisateurs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."T_utilisateurs" (id_utilisateur, nom_utilisateur, prenom_utilisateur, mail_utilisateur, password, id_prestataire) FROM stdin;
\.


--
-- TOC entry 3444 (class 0 OID 0)
-- Dependencies: 216
-- Name: T_analyses_id_analyse_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_analyses_id_analyse_seq"', 1, false);


--
-- TOC entry 3445 (class 0 OID 0)
-- Dependencies: 228
-- Name: T_bpu_id_prestation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_bpu_id_prestation_seq"', 1, false);


--
-- TOC entry 3446 (class 0 OID 0)
-- Dependencies: 211
-- Name: T_droits_marche_id_marche_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_droits_marche_id_marche_seq"', 1, false);


--
-- TOC entry 3447 (class 0 OID 0)
-- Dependencies: 212
-- Name: T_droits_marche_id_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_droits_marche_id_utilisateur_seq"', 1, false);


--
-- TOC entry 3448 (class 0 OID 0)
-- Dependencies: 231
-- Name: T_marche_id_marche_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_marche_id_marche_seq"', 1, false);


--
-- TOC entry 3449 (class 0 OID 0)
-- Dependencies: 230
-- Name: T_marche_id_prestataire_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_marche_id_prestataire_seq"', 1, false);


--
-- TOC entry 3450 (class 0 OID 0)
-- Dependencies: 233
-- Name: T_marche_pgmtype_id_marche_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_marche_pgmtype_id_marche_seq"', 1, false);


--
-- TOC entry 3451 (class 0 OID 0)
-- Dependencies: 234
-- Name: T_marche_pgmtype_id_prestation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_marche_pgmtype_id_prestation_seq"', 1, false);


--
-- TOC entry 3452 (class 0 OID 0)
-- Dependencies: 223
-- Name: T_parametres_presta_id_prestation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_parametres_presta_id_prestation_seq"', 1, false);


--
-- TOC entry 3453 (class 0 OID 0)
-- Dependencies: 221
-- Name: T_presta_id_prestation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_presta_id_prestation_seq"', 1, false);


--
-- TOC entry 3454 (class 0 OID 0)
-- Dependencies: 218
-- Name: T_prestataires_id_prestataire_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_prestataires_id_prestataire_seq"', 1, false);


--
-- TOC entry 3455 (class 0 OID 0)
-- Dependencies: 226
-- Name: T_prog_types_id_prestation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_prog_types_id_prestation_seq"', 1, false);


--
-- TOC entry 3456 (class 0 OID 0)
-- Dependencies: 225
-- Name: T_prog_types_id_programme_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_prog_types_id_programme_seq"', 1, false);


--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 214
-- Name: T_rsx_analyses_id_analyse_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_rsx_analyses_id_analyse_seq"', 1, false);


--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 220
-- Name: T_utilisateurs_id_prestataire_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_utilisateurs_id_prestataire_seq"', 1, false);


--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 209
-- Name: T_utilisateurs_id_utilisateur_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."T_utilisateurs_id_utilisateur_seq"', 1, false);


--
-- TOC entry 3238 (class 2606 OID 16422)
-- Name: T_analyses T_analyses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_analyses"
    ADD CONSTRAINT "T_analyses_pkey" PRIMARY KEY (id_analyse);


--
-- TOC entry 3246 (class 2606 OID 16484)
-- Name: T_marche_pgmtype T_marche_pgmtype_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche_pgmtype"
    ADD CONSTRAINT "T_marche_pgmtype_pkey" PRIMARY KEY (id_prestation);


--
-- TOC entry 3244 (class 2606 OID 16474)
-- Name: T_marche T_marche_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_marche"
    ADD CONSTRAINT "T_marche_pkey" PRIMARY KEY (id_marche);


--
-- TOC entry 3242 (class 2606 OID 16442)
-- Name: T_presta T_presta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_presta"
    ADD CONSTRAINT "T_presta_pkey" PRIMARY KEY (id_prestation);


--
-- TOC entry 3240 (class 2606 OID 16429)
-- Name: T_prestataires T_prestataires_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_prestataires"
    ADD CONSTRAINT "T_prestataires_pkey" PRIMARY KEY (id_prestataire);


--
-- TOC entry 3236 (class 2606 OID 16401)
-- Name: T_utilisateurs T_utilisateurs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."T_utilisateurs"
    ADD CONSTRAINT "T_utilisateurs_pkey" PRIMARY KEY (id_utilisateur);


/* ==============================
 *             VIEWS 
 */   
   
CREATE OR REPLACE VIEW sqe.view_runanalytiques
AS SELECT * 
FROM sqe.t_prixunitairerunanalytique_prr 
INNER JOIN sqe.t_runanalytique_run 
ON prr_run_id = run_id;
   
CREATE OR REPLACE VIEW sqe.view_bpu
AS SELECT * 
FROM sqe.t_prestation_prs 
INNER JOIN sqe.t_prixunitaireprestation_prp 
ON prs_id = prp_prs_id;   
   
-- Completed on 2022-10-28 10:55:57

--
-- PostgreSQL database dump complete
--

