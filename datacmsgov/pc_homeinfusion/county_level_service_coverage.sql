-- Home Infusion Provider County-Level Accessibility Analysis
--
-- Business Purpose: 
-- Analyzes the density and accessibility of home infusion therapy providers at the county level
-- to identify areas that may be underserved or have limited access to these critical services.
-- This helps healthcare organizations and policymakers make informed decisions about
-- service expansion and resource allocation.

WITH county_providers AS (
    -- Get count of unique providers per county
    SELECT 
        state,
        state_county_name,
        COUNT(DISTINCT enrollment_id) as provider_count,
        COUNT(DISTINCT zip_code) as unique_zip_codes
    FROM mimi_ws_1.datacmsgov.pc_homeinfusion
    WHERE state_county_name IS NOT NULL
    GROUP BY state, state_county_name
),
county_stats AS (
    -- Calculate state-level statistics for comparison
    SELECT
        state,
        AVG(provider_count) as avg_providers_per_county,
        MAX(provider_count) as max_providers_per_county,
        MIN(provider_count) as min_providers_per_county
    FROM county_providers
    GROUP BY state
)
SELECT 
    cp.state,
    cp.state_county_name,
    cp.provider_count,
    cp.unique_zip_codes,
    cs.avg_providers_per_county,
    CASE 
        WHEN cp.provider_count < cs.avg_providers_per_county * 0.5 THEN 'Underserved'
        WHEN cp.provider_count > cs.avg_providers_per_county * 1.5 THEN 'Well-Served'
        ELSE 'Adequately Served'
    END as service_coverage_status
FROM county_providers cp
JOIN county_stats cs ON cp.state = cs.state
ORDER BY 
    cp.state,
    cp.provider_count DESC;

-- How the Query Works:
-- 1. First CTE (county_providers) counts unique providers and zip codes per county
-- 2. Second CTE (county_stats) calculates state-level statistics for comparison
-- 3. Main query joins these together to create a comprehensive view of service coverage
-- 4. Includes a classification system for service coverage based on state averages

-- Assumptions and Limitations:
-- 1. Assumes current provider enrollment status is active
-- 2. Does not account for population density or demographic needs
-- 3. Service coverage classification is relative to state averages only
-- 4. Does not consider provider capacity or service volume
-- 5. Counties with NULL values are excluded from analysis

-- Possible Extensions:
-- 1. Add population data to calculate providers per capita
-- 2. Include demographic factors (age, income) for needs assessment
-- 3. Add temporal analysis to track changes in coverage over time
-- 4. Incorporate drive time or distance analysis for accessibility
-- 5. Add provider capacity metrics if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:23:29.936426
    - Additional Notes: The query focuses on relative service coverage using state averages as benchmarks. For more accurate accessibility analysis, consider adding population density data and adjusting the threshold values (currently set at 0.5 and 1.5 times state average) based on specific regional requirements.
    
    */