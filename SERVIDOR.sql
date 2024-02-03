-- Table: public.SERVIDOR

-- DROP TABLE IF EXISTS public."SERVIDOR";

CREATE TABLE IF NOT EXISTS public."SERVIDOR"
(
    "ID" integer NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 2147483647 CACHE 1 ),
    "MATRICULA" character varying COLLATE pg_catalog."default" NOT NULL,
    "NOME" character varying COLLATE pg_catalog."default" NOT NULL,
    "PIS" character varying COLLATE pg_catalog."default",
    "CARGA_HORARIA" time without time zone,
    CONSTRAINT servidor_pkey PRIMARY KEY ("ID"),
    CONSTRAINT "Unique PIS" UNIQUE ("PIS")
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."SERVIDOR"
    OWNER to postgres;