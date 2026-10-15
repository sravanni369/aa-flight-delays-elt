{#- Monday=1 .. Sunday=7 on every adapter. Dispatched because DuckDB and BigQuery disagree. -#}
{% macro iso_day_of_week(col) -%}
  {{ return(adapter.dispatch('iso_day_of_week')(col)) }}
{%- endmacro %}

{% macro default__iso_day_of_week(col) -%}
  cast(extract(isodow from {{ col }}) as integer)
{%- endmacro %}

{% macro bigquery__iso_day_of_week(col) -%}
  mod(extract(dayofweek from {{ col }}) + 5, 7) + 1
{%- endmacro %}
