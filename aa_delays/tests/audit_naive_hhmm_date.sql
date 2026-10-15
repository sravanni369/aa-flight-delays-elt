{{ config(severity='warn') }}
-- AUDIT (warn): the naive approach, flight_date + dep_time clock, disagrees with the
-- recorded delay. Each row returned is a flight that approach misdates or mis-times.
select flight_key, sched_dep_ts, dep_time, dep_delay_min
from {{ ref('stg_flights') }}
where {{ hhmm_to_minutes('dep_time') }} - {{ hhmm_to_minutes('crs_dep_time') }} <> dep_delay_min
   or dep_time >= 2400
