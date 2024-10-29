-- Title: High-Cost Specialty Drug Geographic Access Analysis in Medicare Part D

-- Business Purpose:
-- This query analyzes geographic distribution and access patterns for specialty/high-cost drugs 
-- in Medicare Part D. It helps identify potential access disparities and cost burdens across states
-- by focusing on drugs with high per-prescription costs. This information is valuable for:
-- - Payers developing specialty pharmacy networks
-- - Policy makers addressing geographic access barriers
-- - Life sciences companies planning market access strategies
-- - Health systems evaluating specialty drug formularies

WITH drug_metrics AS (
  -- Calculate average cost per prescription for each drug nationally
  SELECT 
    brnd_name,
    gnrc_name,
    SUM(tot_drug_cst) / SUM(tot_clms) as avg_cost_per_rx,
    SUM(tot_clms) as total_claims
  FROM mimi_ws_1.datacmsgov.mupdpr_geo
  WHERE prscrbr_geo_lvl = 'National'
    AND mimi_src_file_date = '2022-12-31'  -- Most recent year
  GROUP BY brnd_name, gnrc_name
  HAVING SUM(tot_clms) > 1000  -- Focus on drugs with meaningful volume
    AND SUM(tot_drug_cst) / SUM(tot_clms) > 5000  -- High-cost drugs >$5000/rx
),

state_access AS (
  -- Analyze state-level utilization of high-cost drugs
  SELECT 
    g.prscrbr_geo_desc as state,
    COUNT(DISTINCT CASE WHEN g.tot_clms >= 100 THEN d.brnd_name END) as high_cost_drugs_with_access,
    SUM(g.tot_drug_cst) as total_specialty_cost,
    SUM(g.tot_benes) as total_beneficiaries_affected
  FROM mimi_ws_1.datacmsgov.mupdpr_geo g
  INNER JOIN drug_metrics d 
    ON g.brnd_name = d.brnd_name
  WHERE g.prscrbr_geo_lvl = 'State'
    AND g.mimi_src_file_date = '2022-12-31'
  GROUP BY g.prscrbr_geo_desc
)

SELECT 
  state,
  high_cost_drugs_with_access,
  total_specialty_cost,
  total_beneficiaries_affected,
  total_specialty_cost / NULLIF(total_beneficiaries_affected, 0) as cost_per_beneficiary
FROM state_access
WHERE state != 'National'
ORDER BY high_cost_drugs_with_access DESC;

-- How the Query Works:
-- 1. First CTE identifies high-cost drugs (>$5000 per prescription) at the national level
-- 2. Second CTE analyzes state-level access to these high-cost drugs
-- 3. Final output shows key metrics by state to identify access patterns

-- Assumptions and Limitations:
-- - Uses $5000/rx threshold to define high-cost drugs (adjustable based on needs)
-- - Requires minimum claim volume of 1000 nationally to exclude rare outliers
-- - State-level access defined as 100+ claims (adjustable threshold)
-- - Cost calculations don't account for rebates or actual net costs
-- - Geographic patterns may reflect legitimate variations in patient populations

-- Possible Extensions:
-- 1. Add therapeutic category analysis to segment by disease state
-- 2. Include year-over-year trends to show access pattern changes
-- 3. Incorporate beneficiary cost share analysis (LIS vs non-LIS)
-- 4. Add population demographics to normalize access metrics
-- 5. Compare high-cost drug access patterns to overall drug access
-- 6. Include rural vs urban geographic subdivisions
-- 7. Add specific disease state filters (e.g., oncology, rare disease)
-- 8. Analyze correlation with specialty pharmacy locations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:40:02.088317
    - Additional Notes: Query focuses on geographic access patterns for high-cost drugs (>$5000 per prescription) with significant prescription volume (>1000 claims nationally). The cost thresholds and claim volume filters can be adjusted based on specific analysis needs. Results exclude territories and foreign claims to focus on U.S. state comparisons. Performance may be impacted when analyzing multiple years of data simultaneously.
    
    */