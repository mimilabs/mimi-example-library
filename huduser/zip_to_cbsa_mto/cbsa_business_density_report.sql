-- cbsa_business_address_coverage_analysis.sql
--
-- Business Purpose:
-- This query analyzes the distribution of business addresses across CBSAs to identify
-- areas with high commercial density and potential market opportunities. It helps
-- business strategists and market researchers understand where business activities
-- are concentrated to inform site selection, market entry, and expansion decisions.

WITH ranked_business_areas AS (
    -- Calculate total business addresses and rank CBSAs by business coverage
    SELECT 
        cbsa,
        usps_zip_pref_state,
        COUNT(DISTINCT zip) as zip_count,
        AVG(bus_ratio) as avg_business_ratio,
        SUM(CASE WHEN bus_ratio > 0.5 THEN 1 ELSE 0 END) as high_business_density_zips
    FROM mimi_ws_1.huduser.zip_to_cbsa_mto
    WHERE cbsa != '99999'  -- Exclude non-CBSA areas
    GROUP BY cbsa, usps_zip_pref_state
    HAVING COUNT(DISTINCT zip) >= 10  -- Focus on CBSAs with meaningful ZIP coverage
)

SELECT 
    r.cbsa,
    r.usps_zip_pref_state as state,
    r.zip_count,
    ROUND(r.avg_business_ratio, 3) as avg_business_ratio,
    r.high_business_density_zips,
    ROUND(r.high_business_density_zips::FLOAT / r.zip_count, 3) as business_concentration_score
FROM ranked_business_areas r
WHERE r.avg_business_ratio > 0.2  -- Focus on areas with significant business presence
ORDER BY business_concentration_score DESC, zip_count DESC
LIMIT 20;

-- How it works:
-- 1. Groups ZIP codes by CBSA and state
-- 2. Calculates key business metrics:
--    - Number of ZIP codes in each CBSA
--    - Average business ratio
--    - Count of ZIP codes with high business density
-- 3. Computes a business concentration score
-- 4. Filters and ranks results based on business presence

-- Assumptions and Limitations:
-- - Assumes business address ratio is a good proxy for commercial activity
-- - Limited to CBSAs with at least 10 ZIP codes for statistical relevance
-- - Does not account for business size or industry type
-- - Current as of the latest ZIP-CBSA mapping update

-- Possible Extensions:
-- 1. Add time-series analysis by incorporating historical data
-- 2. Include industry-specific analysis using NAICS code overlays
-- 3. Compare business vs residential ratios for mixed-use analysis
-- 4. Add geographic clustering analysis for regional patterns
-- 5. Include demographic data for market potential assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:31:21.182909
    - Additional Notes: Query efficiently identifies commercial hotspots across CBSAs by analyzing business address distributions and concentration patterns. Useful for market research and site selection analysis. Note that results are limited to CBSAs with 10+ ZIP codes and significant business presence (>20% business ratio) to ensure statistical relevance.
    
    */