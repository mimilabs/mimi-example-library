-- Medicare Part D Low Income Subsidy Impact Analysis

-- Business Purpose:
-- This query analyzes the impact and utilization patterns of the Medicare Part D 
-- Low Income Subsidy (LIS) program by comparing prescription costs and claims
-- between LIS and non-LIS beneficiaries. The analysis helps identify potential
-- disparities in drug access and financial burden between these populations.

WITH base_metrics AS (
  SELECT
    -- Provider identification
    prscrbr_npi,
    prscrbr_last_org_name,
    prscrbr_type,
    prscrbr_state_abrvtn,
    
    -- Overall prescription metrics
    tot_clms,
    tot_drug_cst,
    tot_benes,
    
    -- LIS specific metrics
    lis_tot_clms,
    lis_drug_cst,
    
    -- Non-LIS specific metrics  
    nonlis_tot_clms,
    nonlis_drug_cst,
    
    -- Calculated fields
    CAST(lis_tot_clms AS FLOAT)/NULLIF(tot_clms, 0) AS lis_claim_ratio,
    CAST(lis_drug_cst AS FLOAT)/NULLIF(tot_drug_cst, 0) AS lis_cost_ratio,
    
    -- Source date for filtering
    mimi_src_file_date
  FROM mimi_ws_1.datacmsgov.mupdpr_prvdr
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    AND tot_clms > 0  -- Filter to active prescribers
)

SELECT 
  prscrbr_state_abrvtn AS state,
  prscrbr_type AS provider_type,
  
  -- Provider counts and total volume
  COUNT(DISTINCT prscrbr_npi) AS provider_count,
  SUM(tot_clms) AS total_claims,
  SUM(tot_drug_cst) AS total_cost,
  
  -- LIS utilization metrics
  AVG(lis_claim_ratio) AS avg_lis_claim_ratio,
  AVG(lis_cost_ratio) AS avg_lis_cost_ratio,
  
  -- Cost comparisons
  SUM(lis_drug_cst)/NULLIF(SUM(lis_tot_clms), 0) AS avg_cost_per_lis_claim,
  SUM(nonlis_drug_cst)/NULLIF(SUM(nonlis_tot_clms), 0) AS avg_cost_per_nonlis_claim

FROM base_metrics
GROUP BY 1, 2
HAVING provider_count >= 10  -- Ensure statistical significance
ORDER BY total_claims DESC

-- Query Operation:
-- 1. Filters to most recent year and active prescribers
-- 2. Calculates LIS vs non-LIS ratios at provider level
-- 3. Aggregates metrics by state and provider type
-- 4. Computes average costs per claim for comparison

-- Assumptions & Limitations:
-- - Assumes 2022 data is complete and representative
-- - Excludes providers with no claims
-- - Groups with fewer than 10 providers excluded for privacy
-- - Does not account for differences in drug mix or patient complexity

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include beneficiary demographic factors
-- 3. Analyze specific drug categories or therapeutic classes
-- 4. Add geographic analysis at more granular levels
-- 5. Include risk score adjustments for patient complexity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:56:40.872026
    - Additional Notes: Query provides comparative analysis between Low Income Subsidy (LIS) and non-LIS Medicare Part D beneficiaries, focusing on claim volumes and cost differentials. Key metrics include provider-level LIS ratios and average cost per claim. Requires minimum of 10 providers per group for statistical validity. Default analysis is for 2022 but can be modified for other years by changing mimi_src_file_date filter.
    
    */