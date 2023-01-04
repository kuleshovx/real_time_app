-- Table: public.asu

-- DROP TABLE IF EXISTS public.asu;

CREATE TABLE IF NOT EXISTS public.asu
(
    ext_id uuid NOT NULL,
    id_asu integer NOT NULL,
    CONSTRAINT asu_pkey PRIMARY KEY (ext_id)
)

TABLESPACE pg_default;

-- Table: public.depot

-- DROP TABLE IF EXISTS public.depot;

CREATE TABLE IF NOT EXISTS public.depot
(
    ext_id uuid NOT NULL,
    id_depot integer NOT NULL,
    CONSTRAINT depot_pkey PRIMARY KEY (ext_id)
)

TABLESPACE pg_default;

-- Table: public.plan

-- DROP TABLE IF EXISTS public.plan;

CREATE TABLE IF NOT EXISTS public.plan
(
    ext_id uuid NOT NULL,
    date timestamp without time zone NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    description character varying(255) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT plan_pkey PRIMARY KEY (ext_id)
)

TABLESPACE pg_default;

-- Table: public.tank

-- DROP TABLE IF EXISTS public.tank;

CREATE TABLE IF NOT EXISTS public.tank
(
    ext_id uuid NOT NULL,
    asu_uuid uuid NOT NULL,
    id_tank integer NOT NULL,
    CONSTRAINT tank_pkey PRIMARY KEY (ext_id)
)

TABLESPACE pg_default;

-- Table: public.sales

-- DROP TABLE IF EXISTS public.sales;

CREATE TABLE IF NOT EXISTS public.sales
(
    ext_id uuid NOT NULL,
    date date NOT NULL,
    asu_uuid uuid NOT NULL,
    depot_uuid uuid NOT NULL,
    version timestamp without time zone NOT NULL,
    sale real NOT NULL,
    is_delete boolean NOT NULL,
    tank_uuid uuid NOT NULL,
    plan_uuid uuid NOT NULL,
    CONSTRAINT sales_pkey PRIMARY KEY (ext_id),
    CONSTRAINT asu_fkey FOREIGN KEY (asu_uuid)
        REFERENCES public.asu (ext_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT depot_fkey FOREIGN KEY (depot_uuid)
        REFERENCES public.depot (ext_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT plan_fkey FOREIGN KEY (plan_uuid)
        REFERENCES public.plan (ext_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT tank_fkey FOREIGN KEY (tank_uuid)
        REFERENCES public.tank (ext_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

-- Index: asu_idx

-- DROP INDEX IF EXISTS public.asu_idx;

CREATE INDEX IF NOT EXISTS asu_idx
    ON public.sales USING btree
    (asu_uuid ASC NULLS LAST, tank_uuid ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: depot_idx

-- DROP INDEX IF EXISTS public.depot_idx;

CREATE INDEX IF NOT EXISTS depot_idx
    ON public.sales USING btree
    (depot_uuid ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: version_idx

-- DROP INDEX IF EXISTS public.version_idx;

CREATE INDEX IF NOT EXISTS version_idx
    ON public.sales USING btree
    (version ASC NULLS LAST)
    TABLESPACE pg_default;