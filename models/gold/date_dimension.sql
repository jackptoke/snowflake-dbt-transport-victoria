WITH arrival_timestamps AS (
    SELECT 
        DISTINCT arrival_time
    FROM {{ ref('silver_trip_updates') }}
    WHERE arrival_time IS NOT NULL
)
SELECT 
    arrival_time AS arrival_timestamp,
    DATE(arrival_time) AS arrival_date,
    TIME(arrival_time) AS arrival_time,
    YEAR(arrival_time) AS arrival_year,
    MONTH(arrival_time) AS arrival_month,
    MONTHNAME(arrival_time) AS arrival_month_name,
    DAYOFMONTH(arrival_time) AS arrival_dayofmonth,
    DAYNAME(arrival_time) AS arrival_day_name,
    {{ get_daytype('arrival_time') }} AS day_type,
    QUARTER(arrival_time) AS arrival_quarter,
    WEEK(arrival_time) AS arrival_week,
    {{ get_season('arrival_time') }} AS arrival_season
FROM arrival_timestamps
