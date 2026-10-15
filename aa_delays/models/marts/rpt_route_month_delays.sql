-- Reporting dataset for a BI tool: one row per route per month.
select
    {{ dbt.date_trunc('month', 'f.flight_date') }}         as month_start,
    r.origin_airport,
    r.dest_airport,
    r.distance_mi,
    count(*)                                               as flights,
    sum(case when f.is_arr_delayed_15 then 1 else 0 end)   as flights_delayed_15,
    round(avg(case when f.is_arr_delayed_15 then 1.0 else 0.0 end), 4) as pct_delayed_15,
    round(avg(f.arr_delay_min), 2)                         as avg_arr_delay_min,
    sum(f.carrier_delay_min)                               as carrier_delay_min,
    sum(f.weather_delay_min)                               as weather_delay_min,
    sum(f.nas_delay_min)                                   as nas_delay_min,
    sum(f.security_delay_min)                              as security_delay_min,
    sum(f.late_aircraft_delay_min)                         as late_aircraft_delay_min
from {{ ref('fct_flights') }} f
join {{ ref('dim_route') }} r on f.route_key = r.route_key
group by 1, 2, 3, 4
