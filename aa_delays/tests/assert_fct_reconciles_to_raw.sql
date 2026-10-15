-- Source-to-target reconciliation: row count and total arrival-delay minutes must match raw.
with s as (select count(*) n, sum(arr_delay) d from {{ source('raw', 'flights') }}),
     t as (select count(*) n, sum(arr_delay_min) d from {{ ref('fct_flights') }})
select s.n as raw_rows, t.n as fact_rows, s.d as raw_delay_min, t.d as fact_delay_min
from s cross join t
where s.n <> t.n or s.d <> t.d
