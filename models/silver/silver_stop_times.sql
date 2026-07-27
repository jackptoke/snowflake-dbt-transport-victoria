WITH bronze_stop_times AS (
    SELECT 
        *
    FROM {{ source('transport_vic_bronze', 'stop_times') }}
)
SELECT 
    trip_id,
    TRY_CAST(arrival_time AS TIME) arrival_time,
    TRY_CAST(departure_time AS TIME) departure_time,
    TRY_CAST(stop_id AS INT) stop_id,
    TRY_CAST(stop_sequence AS INT) stop_sequence,
    stop_headsign,
    TRY_CAST(pickup_type AS BOOLEAN) pickup_type,
    TRY_CAST(drop_off_type AS BOOLEAN) drop_off_type,
    TRY_CAST(shape_dist_traveled AS FLOAT) shape_dist_traveled,
    CURRENT_TIMESTAMP() AS inserted_at
FROM bronze_stop_times