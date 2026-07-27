WITH bronze_trips AS (
    SELECT * FROM {{ source('transport_vic_bronze', 'trips') }}
)
SELECT 
    route_id,
    service_id,
    trip_id,
    shape_id,
    trip_headsign,
    TRY_CAST(direction_id AS INT) AS direction_id,
    TRY_CAST(block_id AS INT) AS block_id,
    TRY_CAST(wheelchair_accessible AS BOOLEAN) AS wheelchair_accessible,
    TRY_CAST(bikes_allowed AS BOOLEAN) AS bikes_allowed,
    CURRENT_TIMESTAMP() AS inserted_at
FROM bronze_trips