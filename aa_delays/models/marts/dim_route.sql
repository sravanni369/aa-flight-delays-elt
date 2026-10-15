select
    route_key,
    origin_airport,
    dest_airport,
    max(distance_mi) as distance_mi,
    count(*)         as flights_2018
from {{ ref('stg_flights') }}
group by route_key, origin_airport, dest_airport
