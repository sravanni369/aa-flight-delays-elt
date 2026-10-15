-- BTS reports cause minutes only for arrivals 15+ minutes late, and they must add up to arr_delay.
select flight_key, arr_delay_min,
       carrier_delay_min + weather_delay_min + nas_delay_min + security_delay_min + late_aircraft_delay_min as cause_total
from {{ ref('fct_flights') }}
where (arr_delay_min >= 15 and carrier_delay_min + weather_delay_min + nas_delay_min
                               + security_delay_min + late_aircraft_delay_min <> arr_delay_min)
   or (arr_delay_min < 15 and carrier_delay_min + weather_delay_min + nas_delay_min
                              + security_delay_min + late_aircraft_delay_min <> 0)
