-- Title: Medicare State Accessibility and Penetration Analysis

-- Business Purpose: Analyze county-level Medicare market opportunities by identifying
-- states with the highest volume of mapped counties and most diverse plan offerings.
-- This helps identify potential market expansion opportunities and assess market penetration.

WITH CountyMetrics AS (
    -- Calculate key metrics per state
    SELECT 
        statename,
        COUNT(DISTINCT county_code) as total_counties,
        COUNT(DISTINCT ma_region_code) as unique_ma_regions,
        COUNT(DISTINCT pdp_region_code) as unique_pdp_regions,
        -- Calculate percentage of counties with both MA and PDP coverage
        SUM(CASE WHEN ma_region_code IS NOT NULL AND pdp_region_code IS NOT NULL THEN 1 ELSE 0 END) * 100.0 / 
            COUNT(county_code) as dual_coverage_pct
    FROM mimi_ws_1.prescriptiondrugplan.geographic_locator
    GROUP BY statename
),
StateRanking AS (
    -- Rank states by market opportunity indicators
    SELECT 
        statename,
        total_counties,
        unique_ma_regions,
        unique_pdp_regions,
        ROUND(dual_coverage_pct, 2) as dual_coverage_pct,
        -- Create composite score for overall market opportunity
        ROUND((total_counties * dual_coverage_pct * (unique_ma_regions + unique_pdp_regions)) / 100.0, 2) 
            as market_opportunity_score
    FROM CountyMetrics
)
-- Final output with top opportunities
SELECT *
FROM StateRanking
WHERE market_opportunity_score > 0
ORDER BY market_opportunity_score DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates county-level data into state-level metrics
-- 2. Second CTE calculates a composite market opportunity score
-- 3. Final query filters and ranks states by opportunity score

-- Assumptions and Limitations:
-- 1. Assumes current data represents active coverage areas
-- 2. Market opportunity score weighs county volume and coverage diversity equally
-- 3. Does not account for population density or demographic factors
-- 4. Limited to geographic coverage, not plan quality or enrollment

-- Possible Extensions:
-- 1. Add year-over-year comparison to identify growing markets
-- 2. Include population data to weight market opportunity scores
-- 3. Create regional clusters for targeted market expansion
-- 4. Add filters for specific MA or PDP region types
-- 5. Include economic indicators for market potential assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:29:12.380651
    - Additional Notes: The market opportunity score formula (counties * coverage * regions) may need adjustment based on specific business priorities. Consider adding weights to components or normalizing scores across different state sizes for more balanced comparisons. Current scoring favors larger states with more counties.
    
    */