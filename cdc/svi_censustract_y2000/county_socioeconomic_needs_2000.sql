-- socioeconomic_disparities_analysis_2000.sql

-- Business Purpose:
-- Analyze socioeconomic disparities across census tracts to identify areas needing targeted
-- community development and social services investment. This analysis helps policymakers,
-- non-profits, and healthcare organizations prioritize resource allocation and program development.

WITH tract_metrics AS (
    -- Calculate key socioeconomic indicators per tract
    SELECT 
        state_name,
        county,
        tract,
        totpop2000 as population,
        g1v1r as poverty_rate,
        g1v2r as unemployment_rate,
        g1v3r as per_capita_income,
        g1v4r as no_hs_diploma_rate,
        g4v4r as no_vehicle_rate
    FROM mimi_ws_1.cdc.svi_censustract_y2000
    WHERE totpop2000 > 0  -- Exclude unpopulated tracts
),

tract_summary AS (
    -- Categorize tracts based on multiple socioeconomic challenges
    SELECT 
        state_name,
        county,
        COUNT(*) as total_tracts,
        SUM(CASE WHEN poverty_rate > 0.2 AND unemployment_rate > 0.1 
            AND no_hs_diploma_rate > 0.25 THEN 1 ELSE 0 END) as high_need_tracts,
        AVG(per_capita_income) as avg_income,
        AVG(no_vehicle_rate) as avg_no_vehicle_rate,
        SUM(population) as total_population
    FROM tract_metrics
    GROUP BY state_name, county
)

-- Generate final ranking of counties by socioeconomic challenges
SELECT 
    state_name,
    county,
    total_population,
    ROUND(high_need_tracts * 100.0 / total_tracts, 1) as pct_high_need_tracts,
    ROUND(avg_income, 0) as avg_per_capita_income,
    ROUND(avg_no_vehicle_rate * 100, 1) as pct_no_vehicle_access
FROM tract_summary
WHERE total_population > 10000  -- Focus on counties with significant population
ORDER BY pct_high_need_tracts DESC, total_population DESC
LIMIT 20;

-- How it works:
-- 1. First CTE extracts key socioeconomic indicators at the tract level
-- 2. Second CTE aggregates to county level and identifies high-need tracts
-- 3. Final query ranks counties based on percentage of high-need tracts

-- Assumptions and Limitations:
-- - Uses 2000 census data which may not reflect current conditions
-- - Simplified definition of "high need" based on three indicators
-- - Excludes very small counties (< 10,000 population)
-- - Does not account for cost of living differences between regions

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include additional indicators like education access or healthcare facilities
-- 3. Create separate rankings for urban vs rural counties
-- 4. Add year-over-year comparison when using with other SVI year tables
-- 5. Incorporate economic development zone designations for policy alignment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:36:22.156671
    - Additional Notes: Query aggregates multiple socioeconomic indicators to identify counties with the highest concentration of disadvantaged census tracts. Results are population-weighted and focus on areas with at least 10,000 residents. The 'high need' classification uses a multi-factor threshold approach combining poverty, unemployment, and education metrics.
    
    */