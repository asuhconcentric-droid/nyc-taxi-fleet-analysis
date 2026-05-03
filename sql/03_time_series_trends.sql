-- ============================================================
-- Project:  NYC Taxi Fleet Analysis (Borough Cab Co.)
-- File:     03_time_series_trends.sql
-- Purpose:  Analyze trip volume and fare trends across Q1 2022
--           by month and day of week to inform driver scheduling
-- Author:   Angela
-- Date:     2026
-- ============================================================


-- ----------------------------------------------------------------
-- Step 1: Monthly trend analysis with month-over-month comparison
-- Goal: Understand how trip volume and revenue shift across
-- January, February, and March using LAG() window function.
-- ----------------------------------------------------------------

WITH monthly_stats AS (
  SELECT
    EXTRACT(MONTH FROM pickup_datetime)                 AS month_num,
    FORMAT_TIMESTAMP('%B', pickup_datetime)             AS month_name,
    COUNT(*)                                            AS total_trips,
    ROUND(SUM(total_amount), 2)                         AS total_revenue,
    ROUND(AVG(total_amount), 2)                         AS avg_revenue_per_trip,
    ROUND(AVG(fare_amount), 2)                          AS avg_fare,
    ROUND(AVG(tip_amount), 2)                           AS avg_tip
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE
    EXTRACT(YEAR FROM pickup_datetime) = 2022
    AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
    AND fare_amount > 0
    AND trip_distance > 0
    AND passenger_count > 0
    AND dropoff_datetime > pickup_datetime
  GROUP BY
    month_num,
    month_name
)

SELECT
  month_num,
  month_name,
  total_trips,
  total_revenue,
  avg_revenue_per_trip,
  avg_fare,
  avg_tip,

  -- Month-over-month changes using LAG()
  LAG(total_trips) OVER (ORDER BY month_num)            AS prev_month_trips,
  total_trips - LAG(total_trips) OVER (
    ORDER BY month_num)                                 AS trip_volume_change,
  ROUND(total_revenue - LAG(total_revenue) OVER (
    ORDER BY month_num), 2)                             AS revenue_change

FROM monthly_stats
ORDER BY month_num;

-- ----------------------------------------------------------------
-- Step 2: Day of week analysis
-- Goal: Identify which days drive the most trips and revenue
-- to inform Borough Cab Co. driver scheduling decisions.
-- ----------------------------------------------------------------

SELECT
  EXTRACT(DAYOFWEEK FROM pickup_datetime)               AS day_num,
  FORMAT_TIMESTAMP('%A', pickup_datetime)               AS day_name,
  COUNT(*)                                              AS total_trips,
  ROUND(SUM(total_amount), 2)                           AS total_revenue,
  ROUND(AVG(total_amount), 2)                           AS avg_revenue_per_trip,
  ROUND(AVG(tip_amount), 2)                             AS avg_tip,
  ROUND(AVG(trip_distance), 2)                          AS avg_distance_miles
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  EXTRACT(YEAR FROM pickup_datetime) = 2022
  AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
  AND fare_amount > 0
  AND trip_distance > 0
  AND passenger_count > 0
  AND dropoff_datetime > pickup_datetime
GROUP BY
  day_num,
  day_name
ORDER BY
  day_num;


-- ----------------------------------------------------------------
-- Step 3: Hour of day analysis
-- Goal: Identify peak hours for trip demand across Q1 2022
-- This will feed the heatmap visualization in Python/Colab.
-- ----------------------------------------------------------------

SELECT
  EXTRACT(HOUR FROM pickup_datetime)                    AS hour_of_day,
  COUNT(*)                                              AS total_trips,
  ROUND(SUM(total_amount), 2)                           AS total_revenue,
  ROUND(AVG(total_amount), 2)                           AS avg_revenue_per_trip,
  ROUND(AVG(tip_amount), 2)                             AS avg_tip
FROM
  `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE
  EXTRACT(YEAR FROM pickup_datetime) = 2022
  AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
  AND fare_amount > 0
  AND trip_distance > 0
  AND passenger_count > 0
  AND dropoff_datetime > pickup_datetime
GROUP BY
  hour_of_day
ORDER BY
  hour_of_day;
