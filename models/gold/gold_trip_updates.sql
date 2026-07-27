{{ 
    config(
        materialized='dynamic_table',
        snowflake_warehouse='LARGE_WH'
    ) 
}}

WITH ordered AS (
  SELECT *,
    LAG(arrival_time)
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS p_arr,
    LAG(arrival_delay_sec)
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS p_arr_d,
    LAG(departure_time)
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS p_dep,
    LAG(departure_delay_sec)
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS p_dep_d,
    LAG(stop_rel)
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS p_rel,
    ROW_NUMBER()
      OVER (PARTITION BY entity_id, stop_sequence ORDER BY feed_ts, source_file) AS rn
  FROM {{ ref('silver_trip_updates') }}
),
updates AS (
    SELECT * EXCLUDE (p_arr, p_arr_d, p_dep, p_dep_d, p_rel, rn)
  FROM ordered
  WHERE rn = 1
     OR arrival_time        IS DISTINCT FROM p_arr
     OR arrival_delay_sec   IS DISTINCT FROM p_arr_d
     OR departure_time      IS DISTINCT FROM p_dep
     OR departure_delay_sec IS DISTINCT FROM p_dep_d
     OR stop_rel            IS DISTINCT FROM p_rel
)
SELECT
    u.feed_ts,
    entity_id,
    trip_id,
    route_id,
    start_date,
    start_time,               -- keep as string: GTFS allows >24:00:00
    trip_rel,
    stop_sequence,                  -- sparse / non-contiguous within a trip
    u.stop_id,
    s.stop_name,
    s.stop_lat,
    s.stop_lon,
    arrival_time,
    arrival_delay_sec,
    departure_time,
    departure_delay_sec,
    stop_rel,
    event_time,            -- coalesce(arrival, departure) for sorting/clustering
    source_file,
    _ingest_ts,
    _silver_ts
    -- current_timestamp() AS _gold_ts -- this triggers FULL REFRESH thus needs to be removed
FROM updates u
LEFT JOIN {{ ref('silver_stops') }} s
ON u.stop_id = s.stop_id