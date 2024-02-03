-- Table: public.date_calendar

-- DROP TABLE IF EXISTS public.date_calendar;

CREATE TABLE IF NOT EXISTS public.date_calendar
(
    date_id integer NOT NULL,
    date date NOT NULL,
    month_ integer NOT NULL,
    year_ integer NOT NULL,
    is_weekend smallint NOT NULL,
    CONSTRAINT date_calendar_date_pk PRIMARY KEY (date_id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.date_calendar
    OWNER to postgres;
-- Index: date_calendar_date_ac_idx

-- DROP INDEX IF EXISTS public.date_calendar_date_ac_idx;

CREATE INDEX IF NOT EXISTS date_calendar_date_ac_idx
    ON public.date_calendar USING btree
    (date ASC NULLS LAST)
    TABLESPACE pg_default;