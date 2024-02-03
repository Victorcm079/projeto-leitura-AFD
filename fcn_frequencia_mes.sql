-- FUNCTION: public.fcn_frequencia_mes(character varying, integer, integer)

-- DROP FUNCTION IF EXISTS public.fcn_frequencia_mes(character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.fcn_frequencia_mes(
	v_matricula character varying,
	v_mes integer,
	v_ano integer)
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
	fcn_hora_entrada(v_matricula, imp."DATA") hora_entrada,
	fcn_hora_saida(v_matricula, imp."DATA") hora_saÃ­da,
	FCN_CALC_TEMPO_TRABALHADO(v_matricula, imp."DATA") tempo_trabalhado,
	serv."CARGA_HORARIA",
	fcn_calc_saldo_horas_dia(v_matricula, imp."DATA") diferenca,
	fcn_qtd_registros_serv_dia(v_matricula, imp."DATA") qtd_registros
	
FROM PUBLIC."SERVIDOR" SERV
LEFT JOIN PUBLIC."IMPORT_AJUSTADO" IMP ON SERV."PIS" = IMP."PIS"
WHERE extract('MONTH' from imp."DATA") = v_mes and extract('YEAR' from imp."DATA") = v_ano  AND serv."MATRICULA" =v_matricula
group by SERV."ID", SERV."MATRICULA", SERV."NOME",
	SERV."PIS", IMP."DATA"
ORDER BY IMP."DATA";

END;
$BODY$;

ALTER FUNCTION public.fcn_frequencia_mes(character varying, integer, integer)
    OWNER TO postgres;
