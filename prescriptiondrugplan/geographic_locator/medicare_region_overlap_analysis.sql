-- Title: Medicare Regional Service Area Overlap Analysis
-- Business Purpose: Identify and analyze overlapping service areas between MA and PDP regions
-- to understand market dynamics and potential coordination opportunities between
-- different types of Medicare plans. This insight helps strategic planning for
-- market entry and expansion.

WITH region_pairing AS (
    -- Group counties by their MA and PDP region combinations
    SELECT 
        ma_region_code,
        ma_region,
        pdp_region_code,
        pdp_region,
        COUNT(DISTINCT county_code) as county_count,
        COUNT(DISTINCT statename) as state_count
    FROM mimi_ws_1.prescriptiondrugplan.geographic_locator
    WHERE ma_region_code IS NOT NULL 
    AND pdp_region_code IS NOT NULL
    GROUP BY 
        ma_region_code,
        ma_region,
        pdp_region_code,
        pdp_region
),

region_metrics AS (
    -- Calculate significance metrics for each region pairing
    SELECT 
        *,
        ROUND(county_count * 100.0 / SUM(county_count) OVER(), 2) as pct_total_counties,
        DENSE_RANK() OVER (ORDER BY county_count DESC) as coverage_rank
    FROM region_pairing
)

SELECT 
    ma_region_code,
    ma_region,
    pdp_region_code,
    pdp_region,
    county_count,
    state_count,
    pct_total_counties,
    coverage_rank
FROM region_metrics
WHERE coverage_rank <= 10
ORDER BY coverage_rank;

-- How it works:
-- 1. First CTE pairs MA and PDP regions and counts their overlapping counties
-- 2. Second CTE adds analytical metrics like percentage and ranking
-- 3. Final query filters for top 10 most significant overlaps

-- Assumptions and limitations:
-- 1. Assumes current data reflects active service areas
-- 2. Does not account for population density or Medicare eligibility
-- 3. Treats all counties equally regardless of size or population
-- 4. Limited to regions with both MA and PDP codes present

-- Possible extensions:
-- 1. Add temporal analysis by incorporating historical data
-- 2. Include population demographics for weighted analysis
-- 3. Add market competition metrics by analyzing plan counts
-- 4. Incorporate plan performance metrics for quality assessment
-- 5. Add geographic adjacency analysis for expansion planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:50:08.037192
    - Additional Notes: Query identifies geographic service area overlaps between MA and PDP regions, focusing on areas with highest county coverage. Best used for market expansion planning and cross-program coordination strategies. Performance may be impacted when analyzing historical data across multiple quarters due to the COUNT DISTINCT operations.
    
    */