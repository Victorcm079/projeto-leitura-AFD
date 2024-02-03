-- FUNCTION: public.fcn_frequencia_dia(date)

-- DROP FUNCTION IF EXISTS public.fcn_frequencia_dia(date);

CREATE OR REPLACE FUNCTION public.fcn_frequencia_dia(
	v_data date)
    RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, qtd_registros integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
	
BEGIN

return query 

SELECT
	SERV."MATRICULA",
	SERV."NOME",
	IMP."DATA",
	fcn_hora_entrada(SERV."MATRICULA", v_data) hora_entrada,
	fcn_hora_saida(SERV."MATRICULA", v_data) hora_saÃ­da,
	FCN_CALC_TEMPO_TRABALHADO(SERV."MATRICULA", v_data) tempo_trabalhado,
	serv."CARGA_HORARIA",
	fcn_calc_saldo_horas_dia(SERV."MATRICULA", v_data) diferenca,
	fcn_qtd_registros_serv_dia(SERV."MATRICULA", v_data) qtd_registros
	
FROM PUBLIC."SERVIDOR" SERV
LEFT JOIN PUBLIC."IMPORT_AJUSTADO" IMP ON SERV."PIS" = IMP."PIS"
WHERE IMP."DATA" = v_data
group by SERV."ID", SERV."MATRICULA", SERV."NOME",
	SERV."PIS", IMP."DATA"
ORDER BY SERV."NOME";

END;
$BODY$;

ALTER FUNCTION public.fcn_frequencia_dia(date)
    OWNER TO postgres;
