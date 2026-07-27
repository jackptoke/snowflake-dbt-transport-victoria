WITH bronze_trip_updates AS (
    SELECT * FROM {{ source('transport_vic_bronze', 'trip_updates') }}
)
SELECT
    t.relative_path,
    t.partition_date,
    -- Trip-level fields
    entity.value:id::STRING                                         AS entity_id,
    entity.value:trip_update.trip.trip_id::STRING                   AS trip_id,
    entity.value:trip_update.trip.route_id::STRING                  AS route_id,
    entity.value:trip_update.trip.start_date::STRING                AS start_date,
    entity.value:trip_update.trip.start_time::STRING                AS start_time,
    entity.value:trip_update.trip.schedule_relationship::STRING     AS trip_schedule_relationship,
    -- Stop-level fields (one row per stop)
    stu.value:stop_sequence::INT                                    AS stop_sequence,
    stu.value:stop_id::STRING                                       AS stop_id,
    stu.value:schedule_relationship::STRING                         AS stop_schedule_relationship,
    stu.value:arrival.delay::INT                                    AS arrival_delay_seconds,
    TO_TIMESTAMP(stu.value:arrival.time::INT)                       AS arrival_time,
    stu.value:departure.delay::INT                                  AS departure_delay_seconds,
    TO_TIMESTAMP(stu.value:departure.time::INT)                     AS departure_time
FROM bronze_trip_updates t,
    LATERAL FLATTEN(input => t.payload:entity) entity,
    LATERAL FLATTEN(input => entity.value:trip_update.stop_time_update) stu