-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION pg_database_owner;

-- DROP SEQUENCE public."SERVIDOR_ID_seq";

CREATE SEQUENCE public."SERVIDOR_ID_seq"
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;
-- DROP SEQUENCE public."servidor_ID_seq";

CREATE SEQUENCE public."servidor_ID_seq"
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 2147483647
	START 1
	CACHE 1
	NO CYCLE;-- public."IMPORT_AFD_CRU" definition

-- Drop table

-- DROP TABLE public."IMPORT_AFD_CRU";

CREATE TABLE public."IMPORT_AFD_CRU" (
	"IMPORT" varchar NULL
);


-- public."SERVIDOR" definition

-- Drop table

-- DROP TABLE public."SERVIDOR";

CREATE TABLE public."SERVIDOR" (
	"ID" int4 NOT NULL GENERATED ALWAYS AS IDENTITY( INCREMENT BY 1 MINVALUE 1 MAXVALUE 2147483647 START 1 CACHE 1 NO CYCLE),
	"MATRICULA" varchar NOT NULL,
	"NOME" varchar NOT NULL,
	"PIS" varchar NULL,
	"CARGA_HORARIA" time NULL,
	CONSTRAINT "Unique PIS" UNIQUE ("PIS"),
	CONSTRAINT servidor_pkey PRIMARY KEY ("ID")
);


-- public.date_calendar definition

-- Drop table

-- DROP TABLE public.date_calendar;

CREATE TABLE public.date_calendar (
	date_id int4 NOT NULL,
	"date" date NOT NULL,
	month_ int4 NOT NULL,
	year_ int4 NOT NULL,
	is_weekend int2 NOT NULL,
	CONSTRAINT date_calendar_date_pk PRIMARY KEY (date_id)
);
CREATE INDEX date_calendar_date_ac_idx ON public.date_calendar USING btree (date);


-- public."IMPORT_AJUSTADO" definition

-- Drop table

-- DROP TABLE public."IMPORT_AJUSTADO";

CREATE TABLE public."IMPORT_AJUSTADO" (
	"MAT_PONTO" varchar NOT NULL,
	"NUM_REGISTRO" numeric NOT NULL,
	"DATA" date NULL,
	"HORA" time NOT NULL,
	"PIS" varchar NOT NULL,
	"DATA_IMPORTACAO" date NULL,
	CONSTRAINT "IMPORT_AJUSTADO_pkey" PRIMARY KEY ("MAT_PONTO"),
	CONSTRAINT "FK_SERVIDOR" FOREIGN KEY ("PIS") REFERENCES public."SERVIDOR"("PIS")
);



-- DROP PROCEDURE public."PROC_FORMATAR_DADOS_CRUS"();

CREATE OR REPLACE PROCEDURE public."PROC_FORMATAR_DADOS_CRUS"()
 LANGUAGE sql
AS $procedure$
TRUNCATE public."IMPORT_AJUSTADO";
INSERT INTO public."IMPORT_AJUSTADO" ("MAT_PONTO", "NUM_REGISTRO", "DATA", "HORA", "PIS", "DATA_IMPORTACAO")
SELECT substring("IMPORT",1,9), 
to_number(substring("IMPORT",10,1),'9999999999') ,
to_date(substring("IMPORT",11,8),'ddmmyyyy') ,
to_timestamp(substring("IMPORT",19,4), 'HH24MI') ,
substring("IMPORT",23,13),
current_date
FROM public."IMPORT_AFD_CRU";
$procedure$
;

-- DROP FUNCTION public.fcn_calc_saldo_horas_dia(varchar, date);

CREATE OR REPLACE FUNCTION public.fcn_calc_saldo_horas_dia(v_matricula character varying, v_data date)
 RETURNS interval
 LANGUAGE plpgsql
AS $function$
DECLARE 
	v_diferenca interval;

BEGIN

select 

FCN_CALC_TEMPO_TRABALHADO(v_matricula, v_data) - serv."CARGA_HORARIA" 
from public."SERVIDOR" serv where serv."MATRICULA" = v_matricula
into   v_diferenca;

RETURN v_diferenca;
END;
$function$
;

-- DROP FUNCTION public.fcn_calc_tempo_trabalhado(varchar, date);

CREATE OR REPLACE FUNCTION public.fcn_calc_tempo_trabalhado(v_matricula character varying, v_data date)
 RETURNS interval
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- DROP FUNCTION public.fcn_freq_serv_dia(date);

CREATE OR REPLACE FUNCTION public.fcn_freq_serv_dia(v_data date)
 RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, status text)
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- DROP FUNCTION public.fcn_freq_serv_mes(varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.fcn_freq_serv_mes(v_matricula character varying, v_mes integer, v_ano integer)
 RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, dia_da_semana text, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, status text)
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- DROP FUNCTION public.fcn_frequencia_dia(date);

CREATE OR REPLACE FUNCTION public.fcn_frequencia_dia(v_data date)
 RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, qtd_registros integer)
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- DROP FUNCTION public.fcn_frequencia_mes(varchar, int4, int4);

CREATE OR REPLACE FUNCTION public.fcn_frequencia_mes(v_matricula character varying, v_mes integer, v_ano integer)
 RETURNS TABLE(matricula character varying, nome character varying, data_ponto date, hora_entrada time without time zone, hora_saida time without time zone, tempo_trabalhado interval, carga_horaria time without time zone, saldo_horas interval, qtd_registros integer)
 LANGUAGE plpgsql
AS $function$
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
$function$
;

-- DROP FUNCTION public.fcn_hora_entrada(varchar, date);

CREATE OR REPLACE FUNCTION public.fcn_hora_entrada(v_matricula character varying, v_data date)
 RETURNS time without time zone
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_hora_entrada time;
BEGIN
select min(imp."HORA") into v_hora_entrada from public."SERVIDOR" serv
left join public."IMPORT_AJUSTADO" imp on serv."PIS" = imp."PIS"
where imp."DATA" = v_data and serv."MATRICULA" = v_matricula;
RETURN v_hora_entrada;
END;
$function$
;

-- DROP FUNCTION public.fcn_hora_saida(varchar, date);

CREATE OR REPLACE FUNCTION public.fcn_hora_saida(v_matricula character varying, v_data date)
 RETURNS time without time zone
 LANGUAGE plpgsql
AS $function$
DECLARE
	v_hora_saida time;
BEGIN
select max(imp."HORA") into v_hora_saida from public."SERVIDOR" serv
left join public."IMPORT_AJUSTADO" imp on serv."PIS" = imp."PIS"
where imp."DATA" = v_data and serv."MATRICULA" = v_matricula;
RETURN v_hora_saida;
END;
$function$
;

-- DROP FUNCTION public.fcn_qtd_registros_serv_dia(varchar, date);

CREATE OR REPLACE FUNCTION public.fcn_qtd_registros_serv_dia(v_matricula character varying, v_data date)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
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
$function$
;