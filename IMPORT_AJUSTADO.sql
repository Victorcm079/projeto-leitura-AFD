-- Table: public.IMPORT_AJUSTADO

-- DROP TABLE IF EXISTS public."IMPORT_AJUSTADO";

CREATE TABLE IF NOT EXISTS public."IMPORT_AJUSTADO"
(
    "MAT_PONTO" character varying COLLATE pg_catalog."default" NOT NULL,
    "NUM_REGISTRO" numeric NOT NULL,
    "DATA" date,
    "HORA" time without time zone NOT NULL,
    "PIS" character varying COLLATE pg_catalog."default" NOT NULL,
    "DATA_IMPORTACAO" date,
    CONSTRAINT "IMPORT_AJUSTADO_pkey" PRIMARY KEY ("MAT_PONTO"),
    CONSTRAINT "FK_SERVIDOR" FOREIGN KEY ("PIS")
        REFERENCES public."SERVIDOR" ("PIS") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        NOT VALID
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public."IMPORT_AJUSTADO"
    OWNER to postgres;