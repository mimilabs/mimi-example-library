-- cbsa_residential_business_balance_analysis.sql

-- Business Purpose:
-- This query examines the balance between residential and business presence in CBSAs
-- to identify areas with optimal mixed-use characteristics. This analysis helps:
-- 1. Real estate developers identify areas with balanced live-work potential
-- 2. Urban planners understand community development patterns
-- 3. Economic development offices target areas for mixed-use initiatives
-- 4. Retailers evaluate locations with both consumer base and business partnerships

SELECT 
    cbsa,
    usps_zip_pref_state,
    -- Calculate averages across all ZIP codes in each CBSA
    COUNT(DISTINCT zip) as zip_count,
    ROUND(AVG(res_ratio), 3) as avg_residential_ratio,
    ROUND(AVG(bus_ratio), 3) as avg_business_ratio,
    -- Calculate the balance score (closer to 1 means more balanced)
    ROUND(ABS(AVG(res_ratio) - AVG(bus_ratio)), 3) as res_bus_balance_score,
    -- Classify CBSAs based on their mix
    CASE 
        WHEN AVG(res_ratio) > 0.7 THEN 'Primarily Residential'
        WHEN AVG(bus_ratio) > 0.7 THEN 'Primarily Business'
        WHEN ABS(AVG(res_ratio) - AVG(bus_ratio)) < 0.2 THEN 'Balanced Mix'
        ELSE 'Mixed Use'
    END as area_classification
FROM mimi_ws_1.huduser.zip_to_cbsa_mto
WHERE cbsa != '99999' -- Exclude non-CBSA areas
GROUP BY cbsa, usps_zip_pref_state
-- Focus on areas with significant ZIP code coverage
HAVING COUNT(DISTINCT zip) >= 10
-- Order by most balanced areas first
ORDER BY res_bus_balance_score ASC
LIMIT 20;

-- How it works:
-- 1. Groups ZIP codes by CBSA and state
-- 2. Calculates average residential and business ratios
-- 3. Creates a balance score showing how close the mix is to 50/50
-- 4. Classifies areas based on their residential/business mix
-- 5. Filters for CBSAs with at least 10 ZIP codes for statistical relevance

-- Assumptions and Limitations:
-- 1. Equal weighting given to residential and business ratios
-- 2. Minimum threshold of 10 ZIP codes may exclude smaller CBSAs
-- 3. Classification thresholds are somewhat arbitrary and may need adjustment
-- 4. Current snapshot may not reflect seasonal variations
-- 5. Does not account for address density or total address count

-- Possible Extensions:
-- 1. Add year-over-year trend analysis for changing area characteristics
-- 2. Include population density data for more nuanced analysis
-- 3. Add geographic clustering analysis for similar CBSAs
-- 4. Incorporate economic indicators for market potential assessment
-- 5. Add size-based segmentation (small/medium/large CBSAs)
-- 6. Include specific industry concentration metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:17:33.268153
    - Additional Notes: The query focuses on identifying CBSAs with balanced residential and business characteristics. The balance score calculation (ABS(AVG(res_ratio) - AVG(bus_ratio))) provides a numerical measure where lower values indicate better mixed-use balance. The minimum threshold of 10 ZIP codes ensures statistical significance but may exclude smaller markets worthy of analysis.
    
    */