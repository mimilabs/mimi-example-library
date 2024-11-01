-- Title: CBSA Annual Air Quality Success Stories
-- 
-- Business Purpose:
-- - Identify CBSAs that have shown significant air quality improvements over time
-- - Highlight effective environmental policies and interventions
-- - Support best practice sharing between metropolitan areas
-- - Generate positive environmental success stories for stakeholders

WITH yearly_metrics AS (
    -- Calculate key improvement metrics for each CBSA per year
    SELECT 
        cbsa,
        year,
        days_with_aqi,
        ROUND(good_days * 100.0 / days_with_aqi, 1) as good_days_pct,
        ROUND((unhealthy_days + very_unhealthy_days + hazardous_days) * 100.0 / days_with_aqi, 1) as poor_air_pct,
        median_aqi
    FROM mimi_ws_1.epa.airdata_yearly_cbsa
    WHERE days_with_aqi >= 300  -- Ensure sufficient data coverage
),

improvement_calc AS (
    -- Compare recent years to historical baseline
    SELECT 
        a.cbsa,
        AVG(CASE WHEN a.year >= 2019 THEN a.good_days_pct END) as recent_good_pct,
        AVG(CASE WHEN a.year <= 2015 THEN a.good_days_pct END) as baseline_good_pct,
        AVG(CASE WHEN a.year >= 2019 THEN a.poor_air_pct END) as recent_poor_pct,
        AVG(CASE WHEN a.year <= 2015 THEN a.poor_air_pct END) as baseline_poor_pct,
        COUNT(DISTINCT a.year) as years_of_data
    FROM yearly_metrics a
    GROUP BY a.cbsa
    HAVING years_of_data >= 7  -- Ensure multi-year trends
)

SELECT 
    cbsa,
    ROUND(recent_good_pct, 1) as recent_good_days_pct,
    ROUND(baseline_good_pct, 1) as baseline_good_days_pct,
    ROUND(recent_good_pct - baseline_good_pct, 1) as good_days_improvement,
    ROUND(baseline_poor_pct - recent_poor_pct, 1) as poor_days_reduction,
    years_of_data
FROM improvement_calc
WHERE (recent_good_pct - baseline_good_pct) > 5  -- Show meaningful improvements
   OR (baseline_poor_pct - recent_poor_pct) > 2
ORDER BY (recent_good_pct - baseline_good_pct) DESC
LIMIT 20;

-- How it works:
-- 1. First CTE calculates yearly percentage metrics for good and poor air quality days
-- 2. Second CTE compares recent years (2019+) to baseline years (2015 and earlier)
-- 3. Final query identifies CBSAs with meaningful improvements
-- 4. Results show top 20 most improved areas

-- Assumptions and Limitations:
-- - Requires at least 300 days of AQI data per year for reliable metrics
-- - Assumes 2019+ represents "recent" period and 2015 and earlier as "baseline"
-- - Focuses on percentage improvements rather than absolute values
-- - May not capture seasonal variations or specific pollution events

-- Possible Extensions:
-- 1. Add population data to weight improvements by population impact
-- 2. Include specific pollutant trends (PM2.5, ozone, etc.)
-- 3. Correlate improvements with known policy implementations
-- 4. Add geographic region analysis to identify regional success patterns
-- 5. Create year-over-year improvement velocity metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:27:35.408872
    - Additional Notes: Query identifies metropolitan areas showing sustained air quality improvements by comparing recent (2019+) metrics against historical baseline (pre-2015). Includes both good air day increases and poor air day reductions. Minimum 300 days of data per year and 7 years of history required for inclusion.
    
    */