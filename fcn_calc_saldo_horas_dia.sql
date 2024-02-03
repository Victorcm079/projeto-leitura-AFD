-- FUNCTION: public.fcn_calc_saldo_horas_dia(character varying, date)

-- DROP FUNCTION IF EXISTS public.fcn_calc_saldo_horas_dia(character varying, date);

CREATE OR REPLACE FUNCTION public.fcn_calc_saldo_horas_dia(
	v_matricula character varying,
	v_data date)
    RETURNS interval
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE 
	v_diferenca interval;

BEGIN

select 

FCN_CALC_TEMPO_TRABALHADO(v_matricula, v_data) - serv."CARGA_HORARIA" 
from public."SERVIDOR" serv where serv."MATRICULA" = v_matricula
into   v_diferenca;

RETURN v_diferenca;
END;
$BODY$;

ALTER FUNCTION public.fcn_calc_saldo_horas_dia(character varying, date)
    OWNER TO postgres;
