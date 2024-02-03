-- FUNCTION: public.fcn_freq_serv_mes(character varying, integer, integer)

-- DROP FUNCTION IF EXISTS public.fcn_freq_serv_mes(character varying, integer, integer);

CREATE OR REPLACE FUNCTION public.fcn_freq_serv_mes(
	v_matricula character varying,
	v_mes integer,
	v_ano integer)
    RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, dia_da_semana text, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, status text) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
	
BEGIN

return query 

SELECT 
	v_matricula,
	serv."NOME",
	CALENDAR.DATE "data_ponto",
	case when calendar.is_weekend = 0 then 'DIA DE SEMANA' else 'FIM DE SEMANA' end dia_da_semana,
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
FROM public.DATE_CALENDAR CALENDAR 
left join public.fcn_frequencia_mes(v_matricula, v_mes, v_ano) FCN  on to_char(fcn.data_ponto,'DDMMYYYY') = to_char(calendar.date,'DDMMYYYY')
left join public."SERVIDOR" serv on serv."MATRICULA" = v_matricula
	where calendar.month_ = v_mes and calendar.year_ = v_ano
	order by calendar.date;

END;
$BODY$;

ALTER FUNCTION public.fcn_freq_serv_mes(character varying, integer, integer)
    OWNER TO postgres;
