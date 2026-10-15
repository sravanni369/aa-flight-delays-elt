{#- BTS clock times are HHMM numbers (1149 = 11:49) and midnight can be 2400.
    Returns minutes after midnight, 0..1439. -#}
{% macro hhmm_to_minutes(col) -%}
  mod(cast(floor({{ col }} / 100) * 60 + mod(cast({{ col }} as integer), 100) as integer), 1440)
{%- endmacro %}
