-- Title: ZIP Code Access Pattern Analysis for Network Planning
--
-- Business Purpose: 
-- This query analyzes ZIP code access patterns based on the residential vs business ratio
-- distributions to help organizations:
-- - Understand where potential members/patients live vs work
-- - Optimize facility and service locations
-- - Plan targeted outreach strategies
-- - Identify areas needing improved access

WITH zip_patterns AS (
    SELECT 
        usps_zip_pref_state AS state,
        -- Categorize ZIPs based on residential vs business composition
        CASE 
            WHEN res_ratio > 0.7 THEN 'Residential Dominant'
            WHEN bus_ratio > 0.5 THEN 'Business Dominant'
            ELSE 'Mixed Use'
        END AS area_type,
        -- Count unique ZIPs
        COUNT(DISTINCT zip) as zip_count,
        -- Calculate average ratios
        ROUND(AVG(res_ratio), 3) as avg_res_ratio,
        ROUND(AVG(bus_ratio), 3) as avg_bus_ratio,
        -- Calculate median total ratio
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tot_ratio), 3) as median_tot_ratio
    FROM mimi_ws_1.huduser.zip_to_county_mto
    GROUP BY 1, 2
)

SELECT 
    state,
    area_type,
    zip_count,
    avg_res_ratio,
    avg_bus_ratio,
    median_tot_ratio,
    -- Calculate percentage distribution within state
    ROUND(100.0 * zip_count / SUM(zip_count) OVER (PARTITION BY state), 1) as pct_of_state
FROM zip_patterns
ORDER BY state, zip_count DESC;

-- How the Query Works:
-- 1. Creates a CTE that categorizes ZIP codes based on residential vs business ratios
-- 2. Calculates key metrics for each category within each state
-- 3. Adds percentage distribution calculations
-- 4. Orders results by state and ZIP count for easy analysis

-- Assumptions and Limitations:
-- - Categories are defined using fixed thresholds (0.7 for residential, 0.5 for business)
-- - Analysis assumes current ratios are representative of actual usage patterns
-- - Does not account for seasonal variations in ZIP code usage
-- - Limited to latest available data snapshot

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating historical data
-- 2. Include county-level demographic or income data for deeper insights
-- 3. Add geographic clustering analysis
-- 4. Incorporate distance calculations to major metropolitan areas
-- 5. Add filters for specific states or regions of interest
-- 6. Include population density metrics for better context

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:17:35.646373
    - Additional Notes: Query categorizes ZIP codes into residential, business, or mixed-use areas based on address ratios. Results show state-level distribution patterns and can be used for facility planning and service area optimization. The 0.7 and 0.5 threshold values for categorization may need adjustment based on specific business needs.
    
    */