-- ============================================================
-- Project:  NYC Taxi Fleet Analysis (Borough Cab Co.)
-- File:     02_zone_revenue_analysis.sql
-- Purpose:  Identify highest-revenue pickup zones and boroughs
-- Author:   Angela
-- Date:     2026
-- ============================================================


-- ----------------------------------------------------------------
-- Step 1: Join yellow trips to zone lookup table
-- Goal: Replace raw location IDs with human-readable zone names
-- and boroughs for business-friendly reporting.
-- ----------------------------------------------------------------

SELECT
  z.borough,
  z.zone_name,
  COUNT(*)                                        AS total_trips,
  ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
  ROUND(AVG(t.total_amount), 2)                   AS avg_revenue_per_trip,
  ROUND(AVG(t.tip_amount), 2)                     AS avg_tip,
  ROUND(AVG(t.trip_distance), 2)                  AS avg_distance_miles
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` t
JOIN
  `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` z
  ON t.pickup_location_id = z.zone_id
WHERE
  EXTRACT(YEAR FROM t.pickup_datetime) = 2022
  AND EXTRACT(MONTH FROM t.pickup_datetime) IN (1, 2, 3)
  AND t.fare_amount > 0
  AND t.trip_distance > 0
  AND t.passenger_count > 0
  AND t.dropoff_datetime > t.pickup_datetime
GROUP BY
  z.borough,
  z.zone_name
ORDER BY
  total_revenue DESC
LIMIT 20;


-- ----------------------------------------------------------------
-- Step 2: Borough-level rollup
-- Goal: Summarize performance at the borough level for
-- executive-facing reporting and Looker Studio bar chart.
-- ----------------------------------------------------------------

SELECT
  z.borough,
  COUNT(*)                                        AS total_trips,
  ROUND(SUM(t.total_amount), 2)                   AS total_revenue,
  ROUND(AVG(t.total_amount), 2)                   AS avg_revenue_per_trip,
  ROUND(AVG(t.tip_amount / NULLIF(t.fare_amount, 0)) * 100, 2)
                                                  AS avg_tip_rate_pct,
  ROUND(AVG(t.trip_distance), 2)                  AS avg_distance_miles
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` t
JOIN
  `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` z
  ON t.pickup_location_id = z.zone_id
WHERE
  EXTRACT(YEAR FROM t.pickup_datetime) = 2022
  AND EXTRACT(MONTH FROM t.pickup_datetime) IN (1, 2, 3)
  AND t.fare_amount > 0
  AND t.trip_distance > 0
  AND t.passenger_count > 0
  AND t.dropoff_datetime > t.pickup_datetime
GROUP BY
  z.borough
ORDER BY
  total_revenue DESC;
