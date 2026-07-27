{% macro get_season(tstmp) %}
CASE
    WHEN MONTH({{tstmp}}) IN (12, 1, 2) THEN 'SUMMER'
    WHEN MONTH({{tstmp}}) IN (3, 4, 5) THEN 'AUTUMN'
    WHEN MONTH({{tstmp}}) IN (6, 7, 8) THEN 'WINTER'
    ELSE 'SPRING'
END
{% endmacro %}

{% macro get_daytype(tstmp) %}
    CASE
        WHEN DAYNAME({{tstmp}}) IN ('Sat', 'Sun') THEN 'WEEKEND'
        ELSE 'BUSINESSDAY'
    END
{% endmacro %}