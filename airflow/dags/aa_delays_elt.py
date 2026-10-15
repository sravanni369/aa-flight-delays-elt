"""Airflow DAG: load raw flights -> dbt run -> dbt test -> dbt docs.

dbt runs from its own virtualenv (DBT_BIN), the usual way to keep dbt and Airflow
dependencies apart. Trigger with conf {"month": "2018-12"} to reload one month;
fct_flights then picks up only that month incrementally.

Environment:
    AA_PROJECT_DIR   repo root
    AA_PYTHON        python of the dbt/duckdb virtualenv
    AA_DBT_BIN       dbt executable in that virtualenv
    AA_DUCKDB_PATH   DuckDB file used by both the loader and dbt
"""
import os
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT = os.environ.get("AA_PROJECT_DIR", os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
PY = os.environ.get("AA_PYTHON", "python")
DBT = os.environ.get("AA_DBT_BIN", "dbt")
DBT_DIR = f'"{PROJECT}/aa_delays"'
DBT_ARGS = f"--project-dir {DBT_DIR} --profiles-dir {DBT_DIR} --no-use-colors"

with DAG(
    dag_id="aa_delays_elt",
    start_date=datetime(2026, 10, 1),
    schedule="@daily",
    catchup=False,
    max_active_runs=1,
    default_args={"retries": 1, "retry_delay": timedelta(minutes=2)},
    tags=["dbt", "duckdb", "elt"],
) as dag:
    load_raw = BashOperator(
        task_id="load_raw",
        bash_command=(
            f'{PY} "{PROJECT}/ingest/load_raw.py" '
            "{% if dag_run.conf.get('month') %}--month {{ dag_run.conf['month'] }}"
            "{% else %}--all{% endif %}"
        ),
    )
    dbt_run = BashOperator(task_id="dbt_run", bash_command=f"{DBT} run {DBT_ARGS}")
    dbt_test = BashOperator(task_id="dbt_test", bash_command=f"{DBT} test {DBT_ARGS}")
    dbt_docs = BashOperator(task_id="dbt_docs", bash_command=f"{DBT} docs generate {DBT_ARGS}")

    load_raw >> dbt_run >> dbt_test >> dbt_docs
