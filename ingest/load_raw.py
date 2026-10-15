"""Load the AA 2018 domestic flights CSV into DuckDB raw.flights, one month at a time.

Re-running a month replaces that month only (delete + insert), so the load is idempotent
and the downstream dbt fact can be built incrementally.

Usage:
    python ingest/load_raw.py --csv data/aa-domestic-delays-2018.csv --month 2018-01
    python ingest/load_raw.py --csv data/aa-domestic-delays-2018.csv --all
"""
import argparse
import os
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[1]
DB = Path(os.environ.get("AA_DUCKDB_PATH", ROOT / "warehouse" / "aa.duckdb"))

DDL = """
create schema if not exists raw;
create table if not exists raw.flights (
    fl_num integer, origin varchar, dest varchar, planned_dep_datetime timestamp,
    crs_dep_time integer, dep_time double, dep_delay double, dep_afph double, dep_rfph double,
    taxi_out double, wheels_off double, crs_elapsed_time double, pct_elapsed_time double,
    distance double, crs_arr_time integer, arr_afph double, arr_rfph double, arr_delay double,
    carrier_delay double, weather_delay double, nas_delay double, security_delay double,
    late_aircraft_delay double,
    _load_month varchar, _loaded_at timestamp
);
"""


def load(csv: Path, month: str | None) -> int:
    con = duckdb.connect(str(DB))
    con.execute(DDL)
    src = f"read_csv('{csv.as_posix()}', header=true, timestampformat='%Y-%m-%d %H:%M:%S')"
    months = ([month] if month else
              [r[0] for r in con.execute(
                  f"select distinct strftime(PLANNED_DEP_DATETIME, '%Y-%m') m from {src} order by m"
              ).fetchall()])
    total = 0
    for m in months:
        con.execute("delete from raw.flights where _load_month = ?", [m])
        con.execute(f"""
            insert into raw.flights
            select *, ? as _load_month, current_timestamp as _loaded_at
            from {src}
            where strftime(PLANNED_DEP_DATETIME, '%Y-%m') = ?""", [m, m])
        n = con.execute("select count(*) from raw.flights where _load_month = ?", [m]).fetchone()[0]
        print(f"loaded {m}: {n:,} rows")
        total += n
    print(f"raw.flights total: {con.execute('select count(*) from raw.flights').fetchone()[0]:,}")
    con.close()
    return total


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--csv", type=Path, default=ROOT / "data" / "aa-domestic-delays-2018.csv")
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--month")
    g.add_argument("--all", action="store_true")
    a = ap.parse_args()
    DB.parent.mkdir(exist_ok=True)
    load(a.csv, None if a.all else a.month)
