-- FUNCTION: public.fcn_calc_tempo_trabalhado(character varying, date)

-- DROP FUNCTION IF EXISTS public.fcn_calc_tempo_trabalhado(character varying, date);

CREATE OR REPLACE FUNCTION public.fcn_calc_tempo_trabalhado(
	v_matricula character varying,
	v_data date)
    RETURNS interval
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	v_tempo_trabalhado interval;
BEGIN

select 
(fcn_hora_saida(v_matricula, v_data) -  --fcn_hora_entrada(v_matricula, v_data))
 case 
 when fcn_hora_entrada(v_matricula, v_data) between '08:00:00' and '08:10:00'  then '08:00:00' 
 else fcn_hora_entrada(v_matricula, v_data) 
 end )
into  v_tempo_trabalhado
from public."SERVIDOR" serv where serv."MATRICULA" = v_matricula;

RETURN v_tempo_trabalhado;
END;
$BODY$;

ALTER FUNCTION public.fcn_calc_tempo_trabalhado(character varying, date)
    OWNER TO postgres;
