-- FUNCTION: public.fcn_hora_entrada(character varying, date)

-- DROP FUNCTION IF EXISTS public.fcn_hora_entrada(character varying, date);

CREATE OR REPLACE FUNCTION public.fcn_hora_entrada(
	v_matricula character varying,
	v_data date)
    RETURNS time without time zone
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	v_hora_entrada time;
BEGIN
select min(imp."HORA") into v_hora_entrada from public."SERVIDOR" serv
left join public."IMPORT_AJUSTADO" imp on serv."PIS" = imp."PIS"
where imp."DATA" = v_data and serv."MATRICULA" = v_matricula;
RETURN v_hora_entrada;
END;
$BODY$;

ALTER FUNCTION public.fcn_hora_entrada(character varying, date)
    OWNER TO postgres;
