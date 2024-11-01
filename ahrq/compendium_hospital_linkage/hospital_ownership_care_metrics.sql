-- Title: Hospital Ownership Impact on Care Access and Financial Performance
--
-- Business Purpose:
-- Analyzes hospital ownership patterns and their relationship to uncompensated care and financial metrics.
-- This helps healthcare strategists and policymakers:
-- 1. Understand how different ownership models serve vulnerable populations
-- 2. Assess financial sustainability across ownership types
-- 3. Identify potential gaps in care access
-- 4. Support policy decisions regarding healthcare resource allocation

WITH ownership_summary AS (
  -- Aggregate key metrics by ownership type
  SELECT 
    hos_ownership,
    COUNT(DISTINCT compendium_hospital_id) as total_hospitals,
    COUNT(DISTINCT health_sys_id) as unique_health_systems,
    AVG(hos_ucburden) as avg_uncompensated_care_burden,
    SUM(CASE WHEN hos_highuc = 1 THEN 1 ELSE 0 END) as high_uc_hospitals,
    AVG(hos_net_revenue) as avg_net_revenue,
    AVG(hos_beds) as avg_beds
  FROM mimi_ws_1.ahrq.compendium_hospital_linkage
  WHERE hos_ownership IS NOT NULL
  GROUP BY hos_ownership
)

SELECT 
  hos_ownership,
  total_hospitals,
  unique_health_systems,
  ROUND(avg_uncompensated_care_burden, 2) as avg_uc_burden,
  high_uc_hospitals,
  ROUND(high_uc_hospitals * 100.0 / total_hospitals, 1) as pct_high_uc,
  ROUND(avg_net_revenue / 1000000, 2) as avg_net_revenue_millions,
  ROUND(avg_beds, 0) as avg_bed_capacity
FROM ownership_summary
ORDER BY total_hospitals DESC;

-- How it works:
-- 1. Creates a CTE to aggregate metrics by ownership type
-- 2. Calculates key performance indicators including:
--    - Hospital counts and system diversity
--    - Uncompensated care metrics
--    - Financial performance
--    - Capacity measures
-- 3. Formats final output with rounded values and meaningful scales

-- Assumptions and Limitations:
-- 1. Assumes hos_ownership classifications are consistent and accurate
-- 2. Financial metrics may not account for regional cost variations
-- 3. Uncompensated care burden reporting may vary by institution
-- 4. Single time point analysis may not capture temporal trends

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include year-over-year trend analysis
-- 3. Incorporate quality metrics correlation
-- 4. Add statistical significance testing
-- 5. Include payer mix analysis
-- 6. Add market concentration metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:53:34.362314
    - Additional Notes: Query breaks down hospital performance metrics by ownership type, focusing on uncompensated care burden and financial sustainability. Key metric calculations assume complete and accurate reporting of financial data and uncompensated care figures. Best used for high-level strategic analysis rather than detailed operational planning.
    
    */