-- The midnight-safe actual_dep_ts must land on the clock time the source recorded in dep_time.
select flight_key, actual_dep_ts, dep_time
from {{ ref('stg_flights') }}
where extract(hour from actual_dep_ts) * 60 + extract(minute from actual_dep_ts)
      <> {{ hhmm_to_minutes('dep_time') }}
