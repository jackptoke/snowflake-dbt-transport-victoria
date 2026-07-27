WITH bronze_routes AS (
    SELECT * FROM {{ source('transport_vic_bronze', 'routes') }}
)
SELECT 
    route_id,
    agency_id,
    route_short_name,
    route_long_name,
    route_type,
    route_color,
    route_text_color,
    CURRENT_TIMESTAMP() AS inserted_at
FROM 
    bronze_routes