-- county_climate_policy_impact.sql
--
-- Business Purpose:
-- This query analyzes the effectiveness of air quality policies by measuring year-over-year 
-- improvements in county-level air quality metrics. It helps policymakers and environmental 
-- agencies identify:
-- 1. Counties showing consistent improvement in air quality
-- 2. The most impactful pollutant reductions
-- 3. Areas that may need additional policy interventions
--
-- The results can inform policy decisions, resource allocation, and best practice sharing
-- across jurisdictions.

WITH yearly_metrics AS (
  -- Calculate key metrics for each county and year
  SELECT 
    state,
    county,
    year,
    days_with_aqi,
    good_days,
    -- Calculate percentage of good air quality days
    ROUND(good_days * 100.0 / NULLIF(days_with_aqi, 0), 1) as good_days_pct,
    -- Sum up all problematic days
    (unhealthy_for_sensitive_groups_days + unhealthy_days + 
     very_unhealthy_days + hazardous_days) as total_unhealthy_days,
    -- Track main pollutant contributors
    days_ozone,
    days_pm25,
    days_pm10
  FROM mimi_ws_1.epa.airdata_yearly_county
  WHERE year >= 2018  -- Focus on recent years for current policy relevance
),

year_over_year AS (
  -- Calculate year-over-year changes
  SELECT 
    curr.state,
    curr.county,
    curr.year,
    curr.good_days_pct,
    curr.good_days_pct - prev.good_days_pct as good_days_pct_change,
    curr.total_unhealthy_days - prev.total_unhealthy_days as unhealthy_days_change,
    curr.days_with_aqi
  FROM yearly_metrics curr
  LEFT JOIN yearly_metrics prev 
    ON curr.state = prev.state 
    AND curr.county = prev.county 
    AND curr.year = prev.year + 1
)

SELECT 
  state,
  county,
  year,
  good_days_pct,
  good_days_pct_change,
  unhealthy_days_change,
  -- Flag significant improvements
  CASE 
    WHEN good_days_pct_change > 5 THEN 'Significant Improvement'
    WHEN good_days_pct_change < -5 THEN 'Significant Decline'
    ELSE 'Stable'
  END as trend_category
FROM year_over_year
WHERE days_with_aqi >= 300  -- Ensure sufficient data coverage
ORDER BY year DESC, good_days_pct_change DESC;

-- How this query works:
-- 1. Creates a base set of yearly metrics including good days percentage and total unhealthy days
-- 2. Calculates year-over-year changes to identify trends
-- 3. Categorizes changes to highlight significant improvements or declines
-- 4. Filters for counties with sufficient data coverage
--
-- Assumptions and limitations:
-- - Requires at least 300 days of AQI data per year for reliable analysis
-- - Assumes year-over-year changes of >5% in good days are significant
-- - Does not account for seasonal variations or extreme weather events
-- - Limited to recent years (2018+) for current policy relevance
--
-- Possible extensions:
-- 1. Add seasonal analysis to account for weather patterns
-- 2. Include demographic data to analyze environmental justice aspects
-- 3. Incorporate economic indicators to assess policy cost-effectiveness
-- 4. Add specific pollutant trend analysis for targeted interventions
-- 5. Create regional groupings for policy coordination
--
-- Tags: policy, environmental, air-quality, trends, improvement-analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:07:34.521759
    - Additional Notes: The query focuses on measuring air quality improvements at county level with a 5% threshold for significant change detection. Best used for long-term policy impact analysis rather than short-term fluctuations. Requires minimum 300 days of data per year for reliable results.
    
    */