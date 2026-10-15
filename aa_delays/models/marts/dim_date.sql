select distinct
    flight_date                                  as date_day,
    extract(year from flight_date)               as year,
    extract(quarter from flight_date)            as quarter,
    extract(month from flight_date)              as month,
    extract(day from flight_date)                as day_of_month,
    {{ iso_day_of_week('flight_date') }}         as iso_day_of_week,
    {{ iso_day_of_week('flight_date') }} >= 6    as is_weekend
from {{ ref('stg_flights') }}
