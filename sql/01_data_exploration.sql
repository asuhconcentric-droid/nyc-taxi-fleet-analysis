-- Step 1: Basic exploration — understand the dataset's shape
-- Note: data_file_month filters by upload month, not trip month.
-- Using pickup_datetime for accurate date filtering going forward.
-- ----------------------------------------------------------------

SELECT
  COUNT(*)                                    AS total_trips,
  MIN(pickup_datetime)                        AS earliest_trip,
  MAX(pickup_datetime)                        AS latest_trip,
  COUNT(DISTINCT vendor_id)                   AS unique_vendors,
  COUNT(DISTINCT pickup_location_id)          AS unique_pickup_zones,
  ROUND(AVG(fare_amount), 2)                  AS avg_fare,
  ROUND(AVG(trip_distance), 2)                AS avg_distance
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  data_file_month IN (1, 2, 3);


-- ----------------------------------------------------------------
-- Step 2: Proper date filtering + data quality audit
-- Finding: data_file_month ≠ trip month. Switching to
-- EXTRACT(MONTH FROM pickup_datetime) for all future queries.
-- ----------------------------------------------------------------

SELECT
  COUNT(*)                                      AS total_trips,
  MIN(pickup_datetime)                          AS earliest_trip,
  MAX(pickup_datetime)                          AS latest_trip,
  COUNT(DISTINCT vendor_id)                     AS unique_vendors,
  COUNT(DISTINCT pickup_location_id)            AS unique_pickup_zones,
  ROUND(AVG(fare_amount), 2)                    AS avg_fare,
  ROUND(AVG(trip_distance), 2)                  AS avg_distance,

  -- Data quality checks
  COUNTIF(fare_amount <= 0)                     AS zero_or_neg_fares,
  COUNTIF(trip_distance <= 0)                   AS zero_or_neg_distance,
  COUNTIF(passenger_count = 0)                  AS zero_passengers,
  COUNTIF(dropoff_datetime <= pickup_datetime)  AS bad_timestamps
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  EXTRACT(YEAR FROM pickup_datetime) = 2022
  AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3);



-- ----------------------------------------------------------------
-- Step 3: Define reusable cleaning logic for all future queries
-- Filters remove <3% of total trips — documented and justified.
--
-- Quality thresholds applied:
--   - fare_amount > 0        (removes 51,910 rows / 0.57%)
--   - trip_distance > 0      (removes 103,249 rows / 1.14%)
--   - passenger_count > 0    (removes 188,585 rows / 2.08%)
--   - dropoff > pickup       (removes 8,412 rows / 0.09%)
--
-- All subsequent queries use this WHERE clause as the baseline.
-- ----------------------------------------------------------------

-- Baseline cleaning filter (to be reused in all subsequent queries):
--
-- WHERE
--   EXTRACT(YEAR FROM pickup_datetime) = 2022
--   AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
--   AND fare_amount > 0
--   AND trip_distance > 0
--   AND passenger_count > 0
--   AND dropoff_datetime > pickup_datetime


