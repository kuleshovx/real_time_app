-- analytics.asu definition

CREATE TABLE analytics.asu
(
    `ext_id` String,
    `id_asu` Int32
)
ENGINE = ReplacingMergeTree
ORDER BY ext_id
SETTINGS index_granularity = 8192
;

-- analytics.depot definition

CREATE TABLE analytics.depot
(
    `ext_id` String,
    `id_depot` Int32
)
ENGINE = ReplacingMergeTree
ORDER BY ext_id
SETTINGS index_granularity = 8192
;

-- analytics.plan definition

CREATE TABLE analytics.plan
(
    `ext_id` String,
    `date` DateTime,
    `start_date` Date,
    `end_date` Date,
    `description` String
)
ENGINE = ReplacingMergeTree
ORDER BY ext_id
SETTINGS index_granularity = 8192
;

-- analytics.sales definition

CREATE TABLE analytics.sales
(
    `date` Date,
    `asu_uuid` String,
    `depot_uuid` String,
    `version` DateTime,
    `sale` Float32,
    `is_delete` Bool,
    `tank_uuid` String,
    `plan_uuid` String
)
ENGINE = ReplacingMergeTree
ORDER BY (plan_uuid,
 asu_uuid,
 tank_uuid,
 depot_uuid,
 date,
 version)
SETTINGS index_granularity = 8192
;

-- analytics.sales_finalized definition

CREATE TABLE analytics.sales_finalized
(
    `date` Date,
    `id_asu` Int32,
    `id_depot` Int32,
    `version` DateTime,
    `sale` Float32,
    `is_delete` Bool,
    `id_tank` Int32,
    `plan_uuid` String
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(date)
ORDER BY (plan_uuid,
 id_asu,
 id_tank,
 id_depot,
 date,
 version)
SETTINGS index_granularity = 8192
;

-- analytics.tank definition

CREATE TABLE analytics.tank
(
    `ext_id` String,
    `asu_uuid` String,
    `id_tank` Int32
)
ENGINE = ReplacingMergeTree
ORDER BY ext_id
SETTINGS index_granularity = 8192
;
