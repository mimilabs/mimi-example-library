-- healthcare_access_vulnerability_2000.sql

-- Business Purpose: 
-- Analyze census tracts with high proportions of elderly populations, disability rates,
-- and limited transportation access to identify areas that may face healthcare access challenges.
-- This information helps healthcare organizations optimize facility locations, plan mobile
-- health services, and develop targeted outreach programs.

WITH healthcare_access_metrics AS (
    SELECT 
        state_name,
        county,
        -- Calculate key healthcare access vulnerability indicators
        ROUND(AVG(g2v1r * 100), 2) as pct_elderly,
        ROUND(AVG(g2v3r * 100), 2) as pct_disabled,
        ROUND(AVG(g4v4r * 100), 2) as pct_no_vehicle,
        COUNT(*) as tract_count,
        -- Count highly vulnerable tracts
        SUM(CASE WHEN usg2v1f = 1 AND usg2v3f = 1 AND usg4v4f = 1 THEN 1 ELSE 0 END) as high_risk_tracts,
        -- Calculate total population metrics
        SUM(totpop2000) as total_population,
        SUM(g2v1n) as elderly_count,
        SUM(g2v3n) as disabled_count,
        SUM(g4v4n) as no_vehicle_count
    FROM mimi_ws_1.cdc.svi_censustract_y2000
    GROUP BY state_name, county
)

SELECT 
    state_name,
    county,
    tract_count,
    total_population,
    pct_elderly,
    pct_disabled,
    pct_no_vehicle,
    high_risk_tracts,
    -- Calculate vulnerability scores
    ROUND((pct_elderly + pct_disabled + pct_no_vehicle) / 3, 2) as composite_vulnerability_score,
    -- Calculate impacted population
    ROUND((elderly_count + disabled_count + no_vehicle_count) * 100.0 / NULLIF(total_population, 0), 2) as pct_population_impacted
FROM healthcare_access_metrics
WHERE total_population > 0
ORDER BY composite_vulnerability_score DESC, total_population DESC
LIMIT 100;

-- How the Query Works:
-- 1. Creates a CTE to aggregate key healthcare access vulnerability metrics by county
-- 2. Calculates percentages for elderly, disabled, and no-vehicle populations
-- 3. Identifies tracts with multiple high-risk factors
-- 4. Produces a final ranking based on a composite vulnerability score
-- 5. Shows both relative (%) and absolute (population) impact measures

-- Assumptions and Limitations:
-- - Assumes equal weighting of elderly, disabled, and transportation factors
-- - Does not account for proximity to existing healthcare facilities
-- - Based on 2000 census data which may not reflect current demographics
-- - Does not consider public transportation availability
-- - Minimum population filter may exclude some rural areas

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Incorporate distance to nearest hospital/clinic data
-- 3. Create severity tiers based on composite scores
-- 4. Add year-over-year comparison when using multi-year data
-- 5. Include additional factors like poverty and language barriers
-- 6. Calculate separate urban vs rural vulnerability scores
-- 7. Add racial/ethnic disparity analysis for healthcare access

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:53:16.656769
    - Additional Notes: Query focuses on healthcare access barriers by combining elderly population, disability status, and transportation limitations. The composite vulnerability score helps identify communities that may need targeted healthcare outreach or mobile health services. County-level aggregation provides a good balance between granularity and actionability for healthcare planning purposes.
    
    */