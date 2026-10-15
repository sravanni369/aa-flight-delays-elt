with codes as (
    select origin_airport as airport_code from {{ ref('stg_flights') }}
    union all
    select dest_airport from {{ ref('stg_flights') }}
)
select
    airport_code,
    airport_code = 'DFW' as is_dfw_hub,
    count(*)             as flight_legs_2018
from codes
group by airport_code
