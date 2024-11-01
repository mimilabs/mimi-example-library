-- DME Claims - Provider Acceptance and Patient Cost Burden Analysis
-- Business Purpose: 
--   Analyze Medicare DME provider participation patterns and beneficiary financial burden to:
--   - Track provider assignment acceptance rates which impacts patient out-of-pocket costs
--   - Measure average deductible and patient payment responsibilities
--   - Identify claim payment patterns that may affect patient access
--   This helps payers and policymakers understand barriers to DME access

WITH claim_metrics AS (
  -- Calculate key metrics at claim level
  SELECT 
    bene_id,
    clm_id,
    carr_clm_prvdr_asgnmt_ind_sw AS provider_accepts_assignment,
    carr_clm_cash_ddctbl_apld_amt AS deductible_amount,
    nch_clm_bene_pmt_amt AS beneficiary_payment,
    clm_pmt_amt AS medicare_payment,
    nch_carr_clm_alowd_amt AS allowed_amount,
    YEAR(clm_from_dt) AS claim_year
  FROM mimi_ws_1.synmedpuf.dme
  WHERE clm_from_dt IS NOT NULL
    AND clm_pmt_amt >= 0  -- Exclude negative payment adjustments
),

annual_summary AS (
  -- Aggregate metrics by year
  SELECT
    claim_year,
    COUNT(DISTINCT bene_id) AS total_beneficiaries,
    COUNT(DISTINCT clm_id) AS total_claims,
    AVG(CASE WHEN provider_accepts_assignment = 'Y' THEN 1 ELSE 0 END) AS assignment_acceptance_rate,
    AVG(deductible_amount) AS avg_deductible,
    AVG(beneficiary_payment) AS avg_beneficiary_payment,
    AVG(medicare_payment) AS avg_medicare_payment,
    AVG(allowed_amount) AS avg_allowed_amount
  FROM claim_metrics
  GROUP BY claim_year
)

SELECT
  claim_year,
  total_beneficiaries,
  total_claims,
  ROUND(assignment_acceptance_rate * 100, 1) AS assignment_acceptance_pct,
  ROUND(avg_deductible, 2) AS avg_deductible_amt,
  ROUND(avg_beneficiary_payment, 2) AS avg_beneficiary_payment_amt,
  ROUND(avg_medicare_payment, 2) AS avg_medicare_payment_amt,
  ROUND((avg_beneficiary_payment / NULLIF(avg_allowed_amount, 0)) * 100, 1) AS beneficiary_cost_share_pct
FROM annual_summary
ORDER BY claim_year;

-- How this query works:
-- 1. First CTE extracts core financial and assignment metrics at claim level
-- 2. Second CTE calculates yearly aggregates including acceptance rates and averages
-- 3. Final SELECT formats results and calculates beneficiary cost share percentage

-- Assumptions and Limitations:
-- - Assumes provider assignment indicator is accurately captured
-- - Excludes negative payment adjustments which may be corrections
-- - Does not account for secondary insurance coverage
-- - Time series limited by data availability

-- Possible Extensions:
-- 1. Add geographic analysis by provider state
-- 2. Segment by DME categories using HCPCS codes
-- 3. Compare metrics across provider specialties
-- 4. Add month-over-month trend analysis
-- 5. Include beneficiary demographic factors
-- 6. Analyze claim denial patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:26:54.483221
    - Additional Notes: Query focuses on provider participation and patient cost analysis over time. Results are aggregated annually which may mask seasonal patterns. The assignment_acceptance_pct metric is particularly important for monitoring provider participation in Medicare. Cost share calculations exclude any secondary insurance coverage that beneficiaries may have.
    
    */