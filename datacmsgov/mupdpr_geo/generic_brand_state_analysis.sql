-- Title: Medicare Part D Generic vs Brand Utilization Analysis By Geography
--
-- Business Purpose:
-- This query analyzes the relationship between generic and brand name drug utilization
-- across different geographic regions to identify cost-saving opportunities and evaluate
-- generic adoption patterns. This helps healthcare organizations and policymakers
-- optimize formulary strategies and identify areas for potential cost reduction.

WITH drug_utilization AS (
    -- Get the most recent year's data and aggregate key metrics
    SELECT 
        prscrbr_geo_desc,
        COUNT(DISTINCT CASE WHEN brnd_name = gnrc_name THEN gnrc_name END) as generic_drug_count,
        COUNT(DISTINCT CASE WHEN brnd_name != gnrc_name THEN brnd_name END) as brand_drug_count,
        SUM(CASE WHEN brnd_name = gnrc_name THEN tot_drug_cst ELSE 0 END) as generic_total_cost,
        SUM(CASE WHEN brnd_name != gnrc_name THEN tot_drug_cst ELSE 0 END) as brand_total_cost,
        SUM(CASE WHEN brnd_name = gnrc_name THEN tot_clms ELSE 0 END) as generic_claims,
        SUM(CASE WHEN brnd_name != gnrc_name THEN tot_clms ELSE 0 END) as brand_claims
    FROM mimi_ws_1.datacmsgov.mupdpr_geo
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.mupdpr_geo)
        AND prscrbr_geo_lvl = 'State'
    GROUP BY prscrbr_geo_desc
)

SELECT 
    prscrbr_geo_desc as state,
    generic_drug_count,
    brand_drug_count,
    ROUND(generic_total_cost/1000000, 2) as generic_cost_millions,
    ROUND(brand_total_cost/1000000, 2) as brand_cost_millions,
    ROUND(100.0 * generic_claims / NULLIF(generic_claims + brand_claims, 0), 1) as generic_utilization_rate,
    ROUND(100.0 * generic_total_cost / NULLIF(generic_total_cost + brand_total_cost, 0), 1) as generic_cost_share
FROM drug_utilization
WHERE prscrbr_geo_desc NOT IN ('Foreign Country', 'Unknown')
ORDER BY generic_cost_share DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate metrics for generic vs brand drugs by state
-- 2. Distinguishes generic drugs by matching brand_name = generic_name
-- 3. Calculates key metrics including drug counts, costs, and utilization rates
-- 4. Formats results in millions of dollars and percentages for easy interpretation
-- 5. Excludes non-US geographies and unknown locations
-- 6. Orders results by generic cost share to highlight state-level variations

-- Assumptions and Limitations:
-- 1. Assumes brand_name = generic_name indicates a generic drug
-- 2. Limited to most recent year's data
-- 3. Excludes territories and non-US locations
-- 4. Does not account for drug-specific factors like patent status
-- 5. Cost calculations include all payment sources (plan, beneficiary, subsidies)

-- Possible Extensions:
-- 1. Add year-over-year trending analysis
-- 2. Include therapeutic class analysis
-- 3. Add beneficiary count metrics
-- 4. Compare against national averages
-- 5. Incorporate low-income subsidy impact
-- 6. Add drug price variation analysis
-- 7. Include provider specialty influence
-- 8. Add regional grouping analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:05:54.569213
    - Additional Notes: Query performs well for analyzing cost distribution between generic and brand drugs, but may need index optimization for large datasets. Consider adding WHERE clauses to filter specific states or cost thresholds if performance issues arise with full dataset analysis.
    
    */