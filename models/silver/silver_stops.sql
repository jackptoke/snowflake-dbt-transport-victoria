WITH bronze_stops AS (
    SELECT *
    FROM {{ source('transport_vic_bronze', 'stops') }}
)
SELECT 
    TRY_CAST(stop_id AS INT) stop_id,
    stop_name,
    TRY_CAST(stop_lat AS DOUBLE) stop_lat,
    TRY_CAST(stop_lon AS DOUBLE) stop_lon,
    stop_url,
    location_type,
    parent_station,
    TRY_CAST(wheelchair_boarding AS BOOLEAN) wheelchair_boarding,
    level_id,
    TRY_CAST(platform_code AS INT) platform_code,
    CURRENT_TIMESTAMP() AS inserted_at
FROM bronze_stops