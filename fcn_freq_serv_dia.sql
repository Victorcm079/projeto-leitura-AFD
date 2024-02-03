-- FUNCTION: public.fcn_freq_serv_dia(date)

-- DROP FUNCTION IF EXISTS public.fcn_freq_serv_dia(date);

CREATE OR REPLACE FUNCTION public.fcn_freq_serv_dia(
	v_data date)
    RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, status text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE

BEGIN

return query

SELECT SERV."MATRICULA",
	SERV."NOME",
	COALESCE(FCN.DATA_PONTO, v_data) data_ponto,
	FCN.HORA_ENTRADA,
	FCN.HORA_SAIDA,
	FCN.TEMPO_TRABALHADO,
	serv."CARGA_HORARIA",
	FCN.SALDO_HORAS,
	CASE
	when FCN.QTD_REGISTROS = 1 then 'APENAS UM REGISTRO'
	when FCN.QTD_REGISTROS > 2 then 'MAIS DE DOIS REGISTROS'
	when FCN.SALDO_HORAS is null then 'SEM REGISTROS'
	when FCN.SALDO_HORAS >= '00:00' then 'SALDO POSITIVO'
	when FCN.SALDO_HORAS < '00:00' then 'SALDO NEGATIVO'
	END status
FROM FCN_FREQUENCIA_DIA (v_data) FCN
right join public."SERVIDOR" serv on fcn.matricula = serv."MATRICULA";

END;
$BODY$;

ALTER FUNCTION public.fcn_freq_serv_dia(date)
    OWNER TO postgres;
