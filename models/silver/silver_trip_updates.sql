WITH typed AS (
    SELECT
        b.relative_path,
        b.loaded_at,
        b.partition_date,
        TO_TIMESTAMP_LTZ(b.payload:header:timestamp::STRING::NUMBER, 0)   AS feed_ts,
        b.payload:header:incrementality::STRING                           AS incrementality,
        e.value:id::STRING                                                AS entity_id,
        e.value:trip_update:trip:trip_id::STRING                          AS trip_id,
        e.value:trip_update:trip:route_id::STRING                         AS route_id,
        TO_DATE(e.value:trip_update:trip:start_date::STRING, 'YYYYMMDD')  AS start_date,
        e.value:trip_update:trip:start_time::STRING                       AS start_time,
        COALESCE(e.value:trip_update:trip:schedule_relationship::STRING,
                 'SCHEDULED')                                             AS trip_rel,
        stu.value:stop_sequence::INT                                      AS stop_sequence,
        stu.value:stop_id::STRING                                         AS stop_id,
        TO_TIMESTAMP_LTZ(stu.value:arrival:time::STRING::NUMBER,   0)     AS arrival_time,
        stu.value:arrival:delay::INT                                      AS arrival_delay_sec,
        TO_TIMESTAMP_LTZ(stu.value:departure:time::STRING::NUMBER, 0)     AS departure_time,
        stu.value:departure:delay::INT                                    AS departure_delay_sec,
        COALESCE(stu.value:schedule_relationship::STRING, 'SCHEDULED')    AS stop_rel
    FROM {{ source('transport_vic_bronze', 'trip_updates') }} b,
         LATERAL FLATTEN(input => b.payload:entity)                        e,
         LATERAL FLATTEN(input => e.value:trip_update:stop_time_update)    stu
)
SELECT
    feed_ts,
    entity_id,
    trip_id,
    route_id,
    start_date,
    start_time,                                    -- string: GTFS allows >24:00:00
    trip_rel,
    stop_sequence,                                 -- sparse within a trip
    stop_id,
    arrival_time,
    arrival_delay_sec,
    departure_time,
    departure_delay_sec,
    stop_rel,
    COALESCE(arrival_time, departure_time)  AS event_time,
    relative_path                           AS source_file,
    loaded_at                               AS _ingest_ts,
    partition_date,
    CURRENT_TIMESTAMP()                     AS _silver_ts
FROM typed

