# NYC Taxi Fleet Analysis — Borough Cab Co.
### Q1 2022 Yellow Taxi Trip Analysis | BigQuery • Python • Excel • Looker Studio

---

## Project Overview

This project analyzes 8.45 million NYC yellow taxi trips from Q1 2022 (January–March)
on behalf of a fictional fleet operator, Borough Cab Co. The goal is to identify
revenue optimization opportunities, understand demand patterns, and provide
actionable scheduling and operational recommendations.

This is Project 2 in my data analytics portfolio, demonstrating an end-to-end
analytical workflow across four tools: Excel, SQL, Python, and Looker Studio.

---

## Business Questions

| # | Question |
|---|----------|
| BQ1 | Which pickup zones and time windows generate the highest revenue per trip? |
| BQ2 | How do trip volumes and average fares shift across Q1 — and are there weekly patterns? |
| BQ3 | Which payment types dominate by borough, and what is the revenue implication? |
| BQ4 | What percentage of trips are efficient vs loss leaders by fare per mile? |
| BQ5 | How does tipping behavior vary by trip distance and payment type? |

---

## Key Findings

**1. Strong Q1 Recovery**

Trip volume grew 47% and revenue grew 57% from January to March 2022,
reflecting NYC's post-Omicron rebound.

![Monthly Revenue Trend](https://raw.githubusercontent.com/asuhconcentric-droid/nyc-taxi-fleet-analysis/main/visualizations/monthly_revenue_trend.png)

**2. Airport Zones Dominate Value**

JFK Airport averages $60.68 per trip vs $15-17 for typical Manhattan zones.
Queens credit card trips are the single most valuable regular trip type
at $56.35 avg revenue and $8.47 avg tip.

**3. Manhattan Drives Volume, Queens Drives Value**

Manhattan accounts for 7.6M trips at $16.94 avg per trip. Queens generates
635K trips at $52.39 avg — the core operational tension for Borough Cab Co.

![Borough Performance](https://raw.githubusercontent.com/asuhconcentric-droid/nyc-taxi-fleet-analysis/main/visualizations/borough_performance.png)

**4. Peak Demand Window is Thursday-Friday 3pm-6pm**

Thursday 18:00 is the single busiest hour across Q1 with 101,401 trips.
5am is the highest value hour at $26.79 avg revenue per trip — likely
early airport runs with low competition.

![Demand Heatmap](https://raw.githubusercontent.com/asuhconcentric-droid/nyc-taxi-fleet-analysis/main/visualizations/demand_heatmap.png)

**5. Credit Card Dominates but Cash Usage Varies**

Credit card accounts for 80%+ of trips in every borough. Cash tips are
not recorded electronically — all tip analysis reflects credit card
behavior only.

![Distance vs Tip Scatter](https://raw.githubusercontent.com/asuhconcentric-droid/nyc-taxi-fleet-analysis/main/visualizations/distance_vs_tip_scatter.png)

**6. EWR is the Highest Value Trip Type**

Newark Airport credit card trips average $107.55 per trip with $15.35
avg tip — the highest of any borough and payment type combination.

**7. Efficiency Metric Reveals Counterintuitive Finding**

Fare per mile labels airport runs as Loss Leaders despite earning 3x
more per trip than High Efficiency short trips. Per mile metrics
require business context to interpret correctly.

![Fare Distribution](https://raw.githubusercontent.com/asuhconcentric-droid/nyc-taxi-fleet-analysis/main/visualizations/fare_distribution.png)

---

## Dashboard

[View Live Dashboard — Borough Cab Co. Q1 2022](https://datastudio.google.com/reporting/8572e231-84f0-4708-ad63-23d83de439c4)

---

## Tool Workflow

**Excel — Data Dictionary & Results Documentation**

Initial schema exploration, data dictionary covering all 20 columns,
and query results logged across tabs throughout the analysis.

**SQL (BigQuery) — Core Analysis Engine**

Five structured query files covering data exploration, zone revenue
analysis, time series trends, trip efficiency bucketing, and payment
type breakdown. Demonstrates JOINs, window functions (LAG, PERCENTILE_CONT,
PARTITION BY), CTEs, and data quality auditing on 8.45M rows.

**Python (Google Colab) — Visualization & Validation**

BigQuery connection via google-cloud-bigquery library. Five visualizations
built with Matplotlib and Seaborn. Validation report cross-checking Python
results against SQL findings.

**Looker Studio — Interactive Stakeholder Dashboard**

Live dashboard connected directly to BigQuery via custom query.
Two pages: Overview and Demand Heatmap. Includes KPI scorecards,
revenue charts, payment type breakdown, and interactive pivot heatmap.

---

## Dataset

- **Source:** BigQuery Public Datasets
- **Table:** `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
- **Scope:** Q1 2022 (January-March), Yellow Taxi trips only
- **Raw rows:** 9,071,205
- **Cleaned rows:** 8,454,149 (removed 6.8% with zero fares, zero distance, zero passengers, or invalid timestamps)
- **Zone lookup:** `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom`

---

## Repository Structure
