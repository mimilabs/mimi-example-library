-- Population Density Impact Analysis for Healthcare Planning
--
-- Business Purpose:
-- Analyze county-level population density relative to CBSA size to identify
-- areas where healthcare resource allocation may need special consideration
-- due to population concentration patterns.
--
-- This analysis helps healthcare organizations understand where population
-- density might create unique challenges or opportunities for service delivery.

WITH density_metrics AS (
    SELECT 
        state_abr,
        county_name,
        cbsa_title,
        county_2012_pop,
        cbsa_2012_pop,
        -- Calculate what percentage of the CBSA population is in each county
        CASE 
            WHEN cbsa_2012_pop > 0 THEN 
                ROUND((county_2012_pop * 100.0 / cbsa_2012_pop), 2)
            ELSE NULL
        END as pct_of_cbsa_pop,
        2013_code
    FROM mimi_ws_1.cdc.urbanrural_classification
    WHERE cbsa_2012_pop > 0  -- Focus on counties within CBSAs
)

SELECT 
    state_abr AS state,
    -- Categorize counties based on their population contribution to CBSA
    CASE 
        WHEN pct_of_cbsa_pop >= 50 THEN 'Dominant'
        WHEN pct_of_cbsa_pop >= 25 THEN 'Major'
        WHEN pct_of_cbsa_pop >= 10 THEN 'Significant'
        ELSE 'Minor'
    END as county_significance,
    -- Group by urban-rural classification
    CASE 2013_code
        WHEN 1 THEN 'Large Central Metro'
        WHEN 2 THEN 'Large Fringe Metro'
        WHEN 3 THEN 'Medium Metro'
        WHEN 4 THEN 'Small Metro'
        ELSE 'Other'
    END as urban_rural_category,
    COUNT(*) as county_count,
    ROUND(AVG(pct_of_cbsa_pop), 2) as avg_pct_of_cbsa_pop,
    ROUND(AVG(county_2012_pop)) as avg_county_pop
FROM density_metrics
GROUP BY 
    state_abr,
    CASE 
        WHEN pct_of_cbsa_pop >= 50 THEN 'Dominant'
        WHEN pct_of_cbsa_pop >= 25 THEN 'Major'
        WHEN pct_of_cbsa_pop >= 10 THEN 'Significant'
        ELSE 'Minor'
    END,
    CASE 2013_code
        WHEN 1 THEN 'Large Central Metro'
        WHEN 2 THEN 'Large Fringe Metro'
        WHEN 3 THEN 'Medium Metro'
        WHEN 4 THEN 'Small Metro'
        ELSE 'Other'
    END
ORDER BY 
    state_abr,
    county_significance,
    urban_rural_category;

-- How this query works:
-- 1. Creates a CTE that calculates what percentage of each CBSA's population
--    is contained within each member county
-- 2. Categorizes counties based on their population contribution to their CBSA
-- 3. Groups results by state, significance category, and urban-rural classification
-- 4. Provides counts and averages for analysis
--
-- Assumptions and limitations:
-- - Assumes CBSA population > 0 for valid percentage calculations
-- - Uses 2012 population data as that's what's available in the dataset
-- - Focuses on metro areas (CBSA-based analysis)
-- - Categories for county significance are arbitrary and could be adjusted
--
-- Possible extensions:
-- 1. Add temporal analysis by incorporating 2006 and 1990 classifications
-- 2. Include analysis of county-to-county population ratios within same CBSA
-- 3. Add population density calculations if county area data were available
-- 4. Incorporate additional demographic or health outcome data
-- 5. Create state-level summaries of population distribution patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:10:57.252896
    - Additional Notes: The query focuses on measuring the relative population concentration within Core Based Statistical Areas (CBSAs), categorizing counties based on their proportional contribution to their CBSA's total population. This helps identify which counties are population centers within their metropolitan regions, which is valuable for healthcare capacity planning and resource allocation. The significance thresholds (50%, 25%, 10%) can be adjusted based on specific analysis needs.
    
    */