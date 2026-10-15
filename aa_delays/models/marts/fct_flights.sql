{{ config(materialized='incremental', unique_key='flight_key', on_schema_change='fail') }}

-- Incremental on _loaded_at: re-loading a month in raw gives its rows a newer _loaded_at,
-- so they are picked up here and upserted on flight_key.
select
    flight_key,
    route_key,
    flight_date,
    origin_airport,
    dest_airport,
    fl_num,
    sched_dep_ts,
    actual_dep_ts,
    dep_delay_min,
    arr_delay_min,
    taxi_out_min,
    sched_elapsed_min,
    distance_mi,
    carrier_delay_min,
    weather_delay_min,
    nas_delay_min,
    security_delay_min,
    late_aircraft_delay_min,
    is_arr_delayed_15,
    _loaded_at
from {{ ref('stg_flights') }}
{% if is_incremental() %}
where _loaded_at > (select max(_loaded_at) from {{ this }})
{% endif %}
