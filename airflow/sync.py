import datetime
import logging

from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from airflow_clickhouse_plugin.hooks.clickhouse_hook import ClickHouseHook
from airflow_clickhouse_plugin.operators.clickhouse_operator import ClickHouseOperator
from airflow.providers.postgres.operators.postgres import PostgresHook

logger = logging.getLogger(__name__)

PG_CONN = "postgres"
CLICK_CONN = "clickhouse"

ASU_SELECT_QUERY = "SELECT ext_id, id_asu FROM public.asu;"
ASU_CH_TABLE = "asu"

DEPOT_SELECT_QUERY = "SELECT ext_id, id_depot FROM public.depot;"
DEPOT_CH_TABLE = "depot"

PLAN_SELECT_QUERY = "SELECT ext_id, date, start_date, end_date, description FROM public.plan;"
PLAN_CH_TABLE = "plan"

SALES_SELECT_QUERY = "SELECT date, asu_uuid, depot_uuid, version, sale, is_delete, tank_uuid, plan_uuid FROM public.sales WHERE version between '%s' and '%s';"
SALES_CH_TABLE = "sales"

TANK_SELECT_QUERY = "SELECT ext_id, asu_uuid, id_tank FROM public.tank;"
TANK_CH_TABLE = "tank"

UPDATE_MARTS = (
    "INSERT INTO sales_finalized SELECT * FROM sales_new",
    "DELETE FROM sales WHERE version < '{{data_interval_end}}'"
)

SQL_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

def _load_data(sql, table):
    postgres_hook = PostgresHook(postgres_conn_id=PG_CONN)
    ch_hook = ClickHouseHook(clickhouse_conn_id=CLICK_CONN)
    logger.info(f"Executing SQL: {sql}")
    records = postgres_hook.get_records(sql)
    logger.info(f"Selected rows: {len(records)}")
    ch_hook.run(f"INSERT INTO {table} VALUES", records)


def load_asu():
    _load_data(ASU_SELECT_QUERY, ASU_CH_TABLE)


def load_depot():
    _load_data(DEPOT_SELECT_QUERY, DEPOT_CH_TABLE)
    

def load_plan():
    _load_data(PLAN_SELECT_QUERY, PLAN_CH_TABLE)


def load_sales(prev_data_interval_end_success, data_interval_end):
    date_start = prev_data_interval_end_success if prev_data_interval_end_success else datetime.datetime(1970, 1, 1)
    date_end = data_interval_end
    logger.info(f"Select sale changes between {date_start} and {date_end}")
    query = SALES_SELECT_QUERY % (
        date_start.strftime(SQL_TIME_FORMAT), 
        date_end.strftime(SQL_TIME_FORMAT)
    )
    _load_data(query, SALES_CH_TABLE)
    

def load_tank():
    _load_data(TANK_SELECT_QUERY, TANK_CH_TABLE)


with DAG(
    dag_id="sync",
    schedule_interval=datetime.timedelta(minutes=30),
    start_date=datetime.datetime(2020, 1, 1),
    catchup=False,
    max_active_runs=1,
    dagrun_timeout=datetime.timedelta(minutes=60),
) as dag:
    load_asu_task = PythonOperator(
        task_id="load_asu",
        python_callable=load_asu,
    )
    load_depot_task = PythonOperator(
        task_id="load_depot",
        python_callable=load_depot,
    )
    load_plan_task = PythonOperator(
        task_id="load_plan",
        python_callable=load_plan,
    )
    load_tank_task = PythonOperator(
        task_id="load_tank",
        python_callable=load_tank,
    )
    load_sales_task = PythonOperator(
        task_id="load_sales",
        python_callable=load_sales,
        provide_context=True,
    )
    update_mart_task = ClickHouseOperator(
        task_id="update_mart",
        sql=UPDATE_MARTS,
        clickhouse_conn_id=CLICK_CONN,
    )
    
    load_asu_task >> load_depot_task >> load_plan_task >> load_tank_task >> load_sales_task >> update_mart_task
