-- FUNCTION: public.fcn_hora_saida(character varying, date)

-- DROP FUNCTION IF EXISTS public.fcn_hora_saida(character varying, date);

CREATE OR REPLACE FUNCTION public.fcn_hora_saida(
	v_matricula character varying,
	v_data date)
    RETURNS time without time zone
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_hora_saida time;
BEGIN
select max(imp."HORA") into v_hora_saida from public."SERVIDOR" serv
left join public."IMPORT_AJUSTADO" imp on serv."PIS" = imp."PIS"
where imp."DATA" = v_data and serv."MATRICULA" = v_matricula;
RETURN v_hora_saida;
END;
$BODY$;

ALTER FUNCTION public.fcn_hora_saida(character varying, date)
    OWNER TO postgres;
