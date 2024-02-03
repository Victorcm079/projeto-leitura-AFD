-- FUNCTION: public.fcn_qtd_registros_serv_dia(character varying, date)

-- DROP FUNCTION IF EXISTS public.fcn_qtd_registros_serv_dia(character varying, date);

CREATE OR REPLACE FUNCTION public.fcn_qtd_registros_serv_dia(
	v_matricula character varying,
	v_data date)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	v_count integer;

BEGIN

select count(imp."MAT_PONTO") 
into v_count
from public."IMPORT_AJUSTADO" imp left join public."SERVIDOR" serv on serv."PIS" = SUBSTRING(IMP."PIS",2,12)
where  imp."DATA" = v_data
and serv."MATRICULA" = v_matricula;

RETURN v_count;
END;
$BODY$;

ALTER FUNCTION public.fcn_qtd_registros_serv_dia(character varying, date)
    OWNER TO postgres;
