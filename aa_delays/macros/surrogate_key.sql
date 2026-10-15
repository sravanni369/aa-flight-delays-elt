{#- md5 of the pipe-joined, string-cast columns. Cross-database via dbt.hash / dbt.concat. -#}
{% macro surrogate_key(cols) -%}
  {%- set parts = [] -%}
  {%- for c in cols -%}
    {%- do parts.append("coalesce(cast(" ~ c ~ " as " ~ dbt.type_string() ~ "), '~')") -%}
    {%- if not loop.last %}{%- do parts.append("'|'") -%}{% endif -%}
  {%- endfor -%}
  {{ dbt.hash(dbt.concat(parts)) }}
{%- endmacro %}
