-- analytics.sales_new source

CREATE VIEW analytics.sales_new
(
    `date` Date,
    `id_asu` Int32,
    `id_depot` Int32,
    `version` DateTime,
    `sale` Float32,
    `is_delete` Bool,
    `id_tank` Int32,
    `plan_uuid` String
) AS
SELECT
    sales.date AS date,
    asu.id_asu AS id_asu,
    depot.id_depot AS id_depot,
    sales.version AS version,
    sales.sale AS sale,
    sales.is_delete AS is_delete,
    tank.id_tank AS id_tank,
    sales.plan_uuid AS plan_uuid
FROM analytics.sales AS sales
INNER JOIN analytics.asu AS asu ON sales.asu_uuid = asu.ext_id
INNER JOIN analytics.depot AS depot ON sales.depot_uuid = depot.ext_id
INNER JOIN analytics.tank AS tank ON sales.tank_uuid = tank.ext_id
;

-- analytics.sales_all source

CREATE VIEW analytics.sales_all
(
    `date` Date,
    `id_asu` Int32,
    `id_depot` Int32,
    `id_tank` Int32,
    `plan_uuid` String,
    `sale` Float32,
    `is_delete` Bool
) AS
SELECT
    vn.date,
    vn.id_asu,
    vn.id_depot,
    vn.id_tank,
    vn.plan_uuid,
    argMax(vn.sale, vn.version) AS sale,
    argMax(vn.is_delete, vn.version) AS is_delete
FROM
(
    SELECT sn.*
    FROM analytics.sales_new AS sn
    UNION ALL
    SELECT sf.*
    FROM analytics.sales_finalized AS sf
) AS vn
GROUP BY
    vn.date,
    vn.id_asu,
    vn.id_depot,
    vn.id_tank,
    vn.plan_uuid
;
