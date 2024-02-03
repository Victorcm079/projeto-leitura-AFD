-- PROCEDURE: public.PROC_FORMATAR_DADOS_CRUS()

-- DROP PROCEDURE IF EXISTS public."PROC_FORMATAR_DADOS_CRUS"();

CREATE OR REPLACE PROCEDURE public."PROC_FORMATAR_DADOS_CRUS"(
	)
LANGUAGE 'sql'
AS $BODY$
TRUNCATE public."IMPORT_AJUSTADO";
INSERT INTO public."IMPORT_AJUSTADO" ("MAT_PONTO", "NUM_REGISTRO", "DATA", "HORA", "PIS", "DATA_IMPORTACAO")
SELECT substring("IMPORT",1,9), 
to_number(substring("IMPORT",10,1),'9999999999') ,
to_date(substring("IMPORT",11,8),'ddmmyyyy') ,
to_timestamp(substring("IMPORT",19,4), 'HH24MI') ,
substring("IMPORT",23,13),
current_date
FROM public."IMPORT_AFD_CRU";
$BODY$;
ALTER PROCEDURE public."PROC_FORMATAR_DADOS_CRUS"()
    OWNER TO postgres;
