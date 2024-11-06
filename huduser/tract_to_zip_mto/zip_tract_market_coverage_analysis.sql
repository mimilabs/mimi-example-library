-- tract_to_zip_market_penetration_analysis.sql
-- Business Purpose: Analyze Market Coverage and Geographic Expansion Potential for Multi-Location Businesses
-- Provides insights into geographic market distribution and concentration across different ZIP codes and Census Tracts

WITH tract_zip_market_summary AS (
    -- Aggregate geographic distribution metrics for market analysis
    SELECT 
        usps_zip_pref_state,
        usps_zip_pref_city,
        COUNT(DISTINCT tract) AS unique_tracts_per_zip,
        COUNT(DISTINCT zip) AS unique_zips_per_tract,
        ROUND(AVG(res_ratio), 4) AS avg_residential_coverage,
        ROUND(AVG(bus_ratio), 4) AS avg_business_coverage,
        ROUND(SUM(res_ratio), 2) AS total_residential_penetration,
        ROUND(MAX(score) / MAX(score_max), 4) AS normalized_matching_score
    FROM mimi_ws_1.huduser.tract_to_zip_mto
    GROUP BY usps_zip_pref_state, usps_zip_pref_city
)

SELECT 
    usps_zip_pref_state,
    usps_zip_pref_city,
    unique_tracts_per_zip,
    unique_zips_per_tract,
    avg_residential_coverage,
    avg_business_coverage,
    total_residential_penetration,
    normalized_matching_score,
    CASE 
        WHEN unique_tracts_per_zip > 5 THEN 'High Diversity'
        WHEN unique_tracts_per_zip BETWEEN 2 AND 5 THEN 'Moderate Diversity'
        ELSE 'Low Diversity'
    END AS market_complexity_tier
FROM tract_zip_market_summary
WHERE total_residential_penetration > 0.5
ORDER BY total_residential_penetration DESC, unique_tracts_per_zip DESC
LIMIT 100;

-- Query Mechanics:
-- 1. Aggregates geographic distribution metrics
-- 2. Calculates residential and business coverage ratios
-- 3. Normalizes matching scores
-- 4. Categorizes market complexity
-- 5. Filters and ranks markets with significant residential penetration

-- Assumptions:
-- - Uses latest source file dated 2024-03-20
-- - Focuses on markets with >50% residential penetration
-- - Provides snapshot of geographic market distribution

-- Potential Extensions:
-- 1. Incorporate demographic data for deeper market insights
-- 2. Add time-series analysis to track geographic market changes
-- 3. Integrate with business location strategy planning
-- 4. Enhance with additional geospatial filtering

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:08:10.703634
    - Additional Notes: Provides geographic market distribution insights by aggregating Census Tract and ZIP code relationships, focusing on residential and business coverage metrics across different locations
    
    */