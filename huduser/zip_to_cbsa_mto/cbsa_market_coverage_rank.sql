-- zip_cbsa_market_coverage_analysis.sql
--
-- Business Purpose:
-- Analyzes residential and business coverage patterns in Core-Based Statistical Areas (CBSAs) 
-- to identify high-opportunity markets with significant address presence but low market penetration.
-- This helps in prioritizing market expansion, sales territory planning, and resource allocation.

WITH cbsa_metrics AS (
    -- Calculate key market metrics by CBSA
    SELECT 
        cbsa,
        COUNT(DISTINCT zip) as zip_count,
        ROUND(AVG(res_ratio), 3) as avg_residential_coverage,
        ROUND(AVG(bus_ratio), 3) as avg_business_coverage,
        ROUND(SUM(CASE WHEN res_ratio > 0.8 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as pct_high_res_zips
    FROM mimi_ws_1.huduser.zip_to_cbsa_mto
    WHERE cbsa != '99999'  -- Exclude non-CBSA areas
    GROUP BY cbsa
),
ranked_markets AS (
    -- Identify top markets based on coverage metrics
    SELECT 
        m.*,
        z.usps_zip_pref_city,
        z.usps_zip_pref_state,
        RANK() OVER (PARTITION BY z.usps_zip_pref_state ORDER BY m.zip_count DESC) as state_rank
    FROM cbsa_metrics m
    JOIN mimi_ws_1.huduser.zip_to_cbsa_mto z ON m.cbsa = z.cbsa
    WHERE m.avg_residential_coverage > 0.5  -- Focus on areas with substantial residential presence
)

SELECT 
    cbsa,
    usps_zip_pref_city,
    usps_zip_pref_state,
    zip_count,
    avg_residential_coverage,
    avg_business_coverage,
    pct_high_res_zips
FROM ranked_markets
WHERE state_rank = 1  -- Show top market in each state
ORDER BY zip_count DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates key metrics by CBSA including ZIP count and coverage ratios
-- 2. Second CTE ranks markets within each state and adds geographic context
-- 3. Final output shows top market in each state based on size and coverage
--
-- Assumptions & Limitations:
-- - Assumes current ZIP-CBSA relationships are stable
-- - Coverage ratios are averaged across ZIPs without weighting
-- - Non-CBSA areas (99999) are excluded from analysis
--
-- Possible Extensions:
-- 1. Add population data to weight coverage metrics
-- 2. Include year-over-year growth trends
-- 3. Add competitor presence analysis
-- 4. Incorporate distance/drive time between ZIP centroids
-- 5. Layer in specific industry vertical metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:14:37.765468
    - Additional Notes: Query identifies leading CBSAs by market coverage metrics and ranks them by state, focusing on areas with significant residential presence (>50%). Results are limited to top 20 markets and exclude non-CBSA territories. Coverage calculations are unweighted averages across ZIP codes.
    
    */