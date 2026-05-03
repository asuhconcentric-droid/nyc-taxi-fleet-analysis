-- ============================================================
-- Project:  NYC Taxi Fleet Analysis (Borough Cab Co.)
-- File:     05_payment_type_by_borough.sql
-- Purpose:  Analyze payment type preferences by borough and
--           their impact on revenue and tipping behavior
-- Author:   Angela
-- Date:     2026
-- ============================================================


-- ----------------------------------------------------------------
-- Step 1: Decode payment types and join to borough names
--
-- The payment_type column stores numeric codes, not labels.
-- We use CASE WHEN to translate them into readable names:
--   1 = Credit Card
--   2 = Cash
--   3 = No Charge
--   4 = Dispute
--
-- We also JOIN to taxi_zone_geom to get borough names,
-- the same pattern we established in query 02.
-- ----------------------------------------------------------------

WITH payment_decoded AS (
  SELECT
    t.vendor_id,
    t.pickup_datetime,
    t.fare_amount,
    t.tip_amount,
    t.total_amount,
    t.trip_distance,
    z.borough,
    CASE t.payment_type
      WHEN '1' THEN 'Credit Card'
      WHEN '2' THEN 'Cash'
      WHEN '3' THEN 'No Charge'
      WHEN '4' THEN 'Dispute'
      ELSE           'Unknown'
    END                                                   AS payment_label
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
),


-- ----------------------------------------------------------------
-- Step 2: Aggregate by borough and payment type
--
-- For each borough + payment type combination we calculate
-- trip counts, revenue, and tipping metrics.
-- This gives us the raw numbers before we calculate
-- percentages in the final SELECT.
-- ----------------------------------------------------------------

borough_payment_stats AS (
  SELECT
    borough,
    payment_label,
    COUNT(*)                                              AS total_trips,
    ROUND(SUM(total_amount), 2)                           AS total_revenue,
    ROUND(AVG(total_amount), 2)                           AS avg_revenue_per_trip,
    ROUND(AVG(tip_amount), 2)                             AS avg_tip,
    ROUND(AVG(fare_amount), 2)                            AS avg_fare,
    ROUND(AVG(trip_distance), 2)                          AS avg_distance_miles
  FROM
    payment_decoded
  GROUP BY
    borough,
    payment_label
)


-- ----------------------------------------------------------------
-- Step 3: Final summary with percentage of trips per borough
--
-- SUM(total_trips) OVER (PARTITION BY borough) gives us the
-- total trips for each borough specifically — not the grand
-- total. This lets us calculate what percentage of each
-- borough's trips used each payment type.
--
-- PARTITION BY is the key difference from OVER () alone —
-- instead of looking at all rows together, it looks at each
-- borough as its own separate group.
-- ----------------------------------------------------------------

SELECT
  borough,
  payment_label,
  total_trips,
  ROUND(total_trips * 100.0 / SUM(total_trips)
    OVER (PARTITION BY borough), 2)                       AS pct_of_borough_trips,
  total_revenue,
  avg_revenue_per_trip,
  avg_tip,
  avg_fare,
  avg_distance_miles
FROM
  borough_payment_stats
WHERE
  payment_label IN ('Credit Card', 'Cash')                -- Focus on main payment types
ORDER BY
  borough,
  total_revenue DESC;
