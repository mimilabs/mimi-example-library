-- Title: CBSA Air Quality Severity Index Analysis

-- Business Purpose:
-- - Create a severity index to quantify overall air quality burden across CBSAs
-- - Enable quick identification of areas requiring immediate intervention
-- - Support resource allocation decisions for air quality management
-- - Provide a single metric for year-over-year performance tracking

WITH yearly_severity AS (
    -- Calculate weighted severity scores for each CBSA and year
    SELECT 
        cbsa,
        year,
        days_with_aqi,
        -- Weight different severity levels based on EPA guidelines
        -- Higher weights for more severe categories
        (moderate_days * 1 + 
         unhealthy_for_sensitive_groups_days * 2 + 
         unhealthy_days * 3 + 
         very_unhealthy_days * 4 + 
         hazardous_days * 5) AS weighted_severity_score,
        -- Calculate percentage of days with any air quality concerns
        ROUND(100.0 * (moderate_days + unhealthy_for_sensitive_groups_days + 
              unhealthy_days + very_unhealthy_days + hazardous_days) / 
              NULLIF(days_with_aqi, 0), 1) AS pct_concerning_days
    FROM mimi_ws_1.epa.airdata_yearly_cbsa
    WHERE year >= 2018  -- Focus on recent years
)

SELECT 
    cbsa,
    year,
    days_with_aqi AS monitored_days,
    weighted_severity_score,
    pct_concerning_days,
    -- Create severity tiers for easy categorization
    CASE 
        WHEN weighted_severity_score >= 500 THEN 'Critical'
        WHEN weighted_severity_score >= 300 THEN 'High'
        WHEN weighted_severity_score >= 100 THEN 'Moderate'
        ELSE 'Low'
    END AS severity_tier
FROM yearly_severity
WHERE days_with_aqi >= 300  -- Filter for CBSAs with substantial monitoring
ORDER BY weighted_severity_score DESC, year DESC
LIMIT 20;

-- How this works:
-- 1. Creates weighted severity scores based on the number of days in each air quality category
-- 2. Calculates percentage of days with any air quality concerns
-- 3. Assigns severity tiers based on the weighted scores
-- 4. Returns top 20 CBSA-years ranked by severity

-- Assumptions and limitations:
-- - Requires at least 300 days of monitoring data for reliable assessment
-- - Weights are simplified interpretations of EPA health impact guidelines
-- - Recent data (2018+) prioritized for current relevance
-- - Does not account for population exposure or sensitive populations
-- - Severity scoring may need adjustment based on specific use cases

-- Possible extensions:
-- 1. Add year-over-year severity trend analysis
-- 2. Incorporate population data to calculate population-weighted severity
-- 3. Add seasonal severity patterns
-- 4. Compare severity scores across geographic regions
-- 5. Include economic cost estimates based on severity levels
-- 6. Add comparison to national or regional averages

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:20:43.179757
    - Additional Notes: Severity index calculation uses a weighted scoring system (1-5x) that may need calibration based on specific organizational needs. The 300-day monitoring threshold and focus on post-2018 data should be adjusted if analyzing areas with less frequent monitoring or requiring longer historical trends.
    
    */