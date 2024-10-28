
/* 
Home Health Agency Claims Analysis - Key Metrics
============================================

Business Purpose:
This query analyzes home health agency (HHA) claims to understand:
1. Service utilization patterns and costs
2. Patient visit metrics
3. Common diagnoses treated by HHAs

This provides insights into how home health services are being utilized
and identifies opportunities for care optimization and cost management.
*/

WITH claim_metrics AS (
  -- Aggregate key metrics at the claim level
  SELECT 
    bene_id,
    clm_id,
    clm_from_dt,
    clm_thru_dt,
    clm_pmt_amt,
    clm_tot_chrg_amt,
    clm_hha_tot_visit_cnt,
    prncpal_dgns_cd,
    -- Calculate claim duration in days
    DATEDIFF(clm_thru_dt, clm_from_dt) + 1 as episode_days
  FROM mimi_ws_1.synmedpuf.hha
  WHERE clm_from_dt IS NOT NULL 
    AND clm_thru_dt IS NOT NULL
)

SELECT
  -- Service utilization summary
  COUNT(DISTINCT bene_id) as total_patients,
  COUNT(DISTINCT clm_id) as total_claims,
  
  -- Visit and cost metrics
  ROUND(AVG(clm_hha_tot_visit_cnt),1) as avg_visits_per_claim,
  ROUND(AVG(episode_days),1) as avg_episode_days,
  ROUND(AVG(clm_pmt_amt),2) as avg_payment_amount,
  ROUND(AVG(clm_tot_chrg_amt),2) as avg_charge_amount,
  
  -- Payment efficiency 
  ROUND(SUM(clm_pmt_amt)/SUM(clm_tot_chrg_amt) * 100, 1) as payment_to_charge_ratio,
  ROUND(SUM(clm_pmt_amt)/SUM(clm_hha_tot_visit_cnt), 2) as avg_payment_per_visit

FROM claim_metrics
WHERE clm_pmt_amt > 0
  AND clm_tot_chrg_amt > 0
  AND clm_hha_tot_visit_cnt > 0;

/*
How this query works:
1. CTE aggregates claim-level metrics excluding NULL dates
2. Main query calculates key business metrics around utilization and costs
3. Filters ensure we only analyze valid claims with positive payments/charges/visits

Assumptions & Limitations:
- Assumes claims with $0 payments/charges are errors or incomplete
- Limited to claim-level analysis (doesn't drill into revenue centers)
- Doesn't account for seasonal variations or geographic differences

Possible Extensions:
1. Add temporal analysis to show trends over time
2. Include diagnosis analysis to understand conditions treated
3. Group by provider or state to show geographic patterns
4. Calculate readmission rates by linking to inpatient claims
5. Analyze LUPA claims separately using clm_hha_lupa_ind_cd
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:33:45.152783
    - Additional Notes: Query focuses on core utilization metrics for Home Health Agency claims including per-visit costs, episode durations, and payment ratios. Note that claims with zero values for payments, charges, or visits are excluded from analysis to maintain data quality. Best used as a high-level dashboard of HHA service utilization and cost efficiency.
    
    */