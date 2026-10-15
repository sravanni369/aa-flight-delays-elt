-- One row per scheduled flight leg. Grain: fl_num + origin + scheduled departure.
-- Actual departure is scheduled departure + dep_delay. Combining the flight date with the
-- dep_time clock (HHMM) is wrong for flights that left after midnight; see
-- tests/audit_naive_hhmm_date.sql.
select
    {{ surrogate_key(['fl_num', 'origin', 'planned_dep_datetime']) }}       as flight_key,
    {{ surrogate_key(['origin', 'dest']) }}                                as route_key,
    fl_num,
    origin                                                                 as origin_airport,
    dest                                                                   as dest_airport,
    cast(planned_dep_datetime as date)                                     as flight_date,
    planned_dep_datetime                                                   as sched_dep_ts,
    {{ dbt.dateadd('minute', 'cast(dep_delay as integer)', 'planned_dep_datetime') }} as actual_dep_ts,
    crs_dep_time,
    dep_time,
    cast(dep_delay as integer)                                             as dep_delay_min,
    cast(arr_delay as integer)                                             as arr_delay_min,
    cast(taxi_out as integer)                                              as taxi_out_min,
    cast(crs_elapsed_time as integer)                                      as sched_elapsed_min,
    cast(distance as integer)                                              as distance_mi,
    cast(carrier_delay as integer)                                         as carrier_delay_min,
    cast(weather_delay as integer)                                         as weather_delay_min,
    cast(nas_delay as integer)                                             as nas_delay_min,
    cast(security_delay as integer)                                        as security_delay_min,
    cast(late_aircraft_delay as integer)                                   as late_aircraft_delay_min,
    arr_delay >= 15                                                        as is_arr_delayed_15,
    _load_month,
    _loaded_at
from {{ source('raw', 'flights') }}
