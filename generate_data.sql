
DROP TABLE IF EXISTS plan_data;

SELECT gen_random_uuid() AS uuid
INTO TEMP TABLE plan_data;

INSERT INTO plan
SELECT
pd.uuid,
now(),
'2022-01-01',
'2022-01-31',
''
FROM plan_data pd;

INSERT INTO sales
SELECT
t.day::date,
asu.ext_id,
depot.ext_id,
now(),
random() * 10000,
false,
tank.ext_id,
pd.uuid
FROM generate_series(timestamp '2022-01-01', timestamp '2022-01-31', interval '1 day') AS t(day)
CROSS JOIN asu asu
CROSS JOIN depot depot
JOIN tank tank ON asu.ext_id = tank.asu_uuid
CROSS JOIN plan_data pd
;