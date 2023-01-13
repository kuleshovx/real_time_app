CREATE TABLE queue (
  date Int32,
  asu_uuid String,
  depot_uuid String,
  version Int64,
  sale Float32,
  is_delete Bool,
  tank_uuid String,
  plan_uuid String,
  ext_id String
) ENGINE = Kafka('130.193.40.81:9092', 'postgres.public.sales', 'ch', 'JSONEachRow');


CREATE MATERIALIZED VIEW consumer TO sales AS 
SELECT 
date_add(day, date, toDate('1970-01-01')) AS date,
asu_uuid AS asu_uuid,
depot_uuid AS depot_uuid,
toDateTime(version/1000000) AS version,
sale AS sale,
is_delete AS is_delete,
tank_uuid AS tank_uuid,
plan_uuid AS plan_uuid
FROM queue;