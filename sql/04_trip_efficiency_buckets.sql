-- ============================================================
-- Project:  NYC Taxi Fleet Analysis (Borough Cab Co.)
-- File:     04_trip_efficiency_buckets.sql
-- Purpose:  Classify trips by fare efficiency (fare per mile)
--           to identify high value vs loss leader trips
-- Author:   Angela
-- Date:     2026
-- ============================================================


-- ----------------------------------------------------------------
-- Step 1: Calculate the median fare per mile across all Q1 trips
-- 
-- PERCENTILE_CONT(0.5) means "find the value at the 50th 
-- percentile" — in other words, the median. Unlike AVG(), the 
-- median is not skewed by extreme outliers like a $200 airport 
-- trip, making it a fairer benchmark for "typical" efficiency.
--
-- We wrap this in a CTE so we can reference the median value
-- in the next step without repeating the calculation.
-- ----------------------------------------------------------------

WITH median_calc AS (
  SELECT
    PERCENTILE_CONT(fare_amount / trip_distance, 0.5)
      OVER ()                                           AS median_fare_per_mile
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE
    EXTRACT(YEAR FROM pickup_datetime) = 2022
    AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
    AND fare_amount > 0
    AND trip_distance > 0
    AND passenger_count > 0
    AND dropoff_datetime > pickup_datetime
  LIMIT 1
),


-- ----------------------------------------------------------------
-- Step 2: Calculate fare per mile for every individual trip
--
-- We compute fare_amount / trip_distance to get a standardized
-- efficiency metric. This lets us compare a 1 mile trip to a 
-- 20 mile trip on equal footing — it's not about how much the 
-- trip earned in total, but how much it earned per mile driven.
--
-- We also pull in the median from the previous CTE so every
-- row knows what the benchmark is.
-- ----------------------------------------------------------------

trip_efficiency AS (
  SELECT
    vendor_id,
    pickup_datetime,
    pickup_location_id,
    trip_distance,
    fare_amount,
    total_amount,
    tip_amount,
    ROUND(fare_amount / trip_distance, 2)               AS fare_per_mile,
    (SELECT median_fare_per_mile FROM median_calc)       AS median_fare_per_mile
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE
    EXTRACT(YEAR FROM pickup_datetime) = 2022
    AND EXTRACT(MONTH FROM pickup_datetime) IN (1, 2, 3)
    AND fare_amount > 0
    AND trip_distance > 0
    AND passenger_count > 0
    AND dropoff_datetime > pickup_datetime
),


-- ----------------------------------------------------------------
-- Step 3: Assign efficiency buckets using CASE WHEN
--
-- We classify every trip into one of three tiers based on how
-- its fare_per_mile compares to the median:
--
--   High Efficiency  — fare per mile is 25% above median
--                      these are your most profitable trips
--   Average          — fare per mile is within 25% of median
--                      solid, expected performance
--   Loss Leader      — fare per mile is 25% below median
--                      low return trips not worth prioritizing
--
-- The 25% threshold is a business decision, not a SQL rule.
-- You could adjust it — this is worth noting in your portfolio
-- as a documented assumption.
-- ----------------------------------------------------------------

efficiency_buckets AS (
  SELECT
    *,
    CASE
      WHEN fare_per_mile >= median_fare_per_mile * 1.25  THEN 'High Efficiency'
      WHEN fare_per_mile <= median_fare_per_mile * 0.75  THEN 'Loss Leader'
      ELSE                                                    'Average'
    END                                                   AS efficiency_tier
  FROM
    trip_efficiency
)


-- ----------------------------------------------------------------
-- Step 4: Summarize results by efficiency tier
--
-- Now that every trip is labeled, we roll up to see the big 
-- picture — how many trips fall into each bucket, what they
-- earn on average, and what percentage of total trips they
-- represent. This is the result set that tells Borough Cab Co.
-- exactly how much of their business is high value vs. wasteful.
-- ----------------------------------------------------------------

SELECT
  efficiency_tier,
  COUNT(*)                                              AS total_trips,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)   AS pct_of_total_trips,
  ROUND(AVG(fare_per_mile), 2)                          AS avg_fare_per_mile,
  ROUND(AVG(fare_amount), 2)                            AS avg_fare,
  ROUND(AVG(total_amount), 2)                           AS avg_total_amount,
  ROUND(AVG(tip_amount), 2)                             AS avg_tip,
  ROUND(AVG(trip_distance), 2)                          AS avg_distance_miles
FROM
  efficiency_buckets
GROUP BY
  efficiency_tier
ORDER BY
  avg_fare_per_mile DESC;
