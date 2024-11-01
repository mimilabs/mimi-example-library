-- dmepos_supplier_beneficiary_mix.sql

-- Business Purpose:
-- Analyzes the beneficiary mix served by DMEPOS suppliers to understand their patient population
-- characteristics and service patterns. This helps identify suppliers who specialize in 
-- serving specific demographic groups or patients with particular chronic conditions.
-- The insights can inform network adequacy assessments and care coordination strategies.

WITH supplier_metrics AS (
  -- Get the latest year's data and calculate key service metrics
  SELECT
    suplr_npi,
    suplr_prvdr_last_name_org,
    suplr_prvdr_state_abrvtn,
    tot_suplr_benes,
    suplr_mdcr_pymt_amt,
    
    -- Calculate beneficiary demographic percentages
    ROUND(bene_age_lt_65_cnt * 100.0 / tot_suplr_benes, 1) as pct_under_65,
    ROUND(bene_dual_cnt * 100.0 / tot_suplr_benes, 1) as pct_dual_eligible,
    
    -- Calculate key chronic condition percentages 
    bene_cc_ph_diabetes_v2_pct as pct_diabetes,
    bene_cc_ph_copd_v2_pct as pct_copd,
    bene_cc_bh_alz_non_alzdem_v2_pct as pct_dementia,
    
    -- Calculate average payment per beneficiary
    ROUND(suplr_mdcr_pymt_amt / tot_suplr_benes, 2) as payment_per_bene,
    bene_avg_risk_scre
    
  FROM mimi_ws_1.datacmsgov.mupdme_sup
  WHERE mimi_src_file_date = '2022-12-31'  -- Get most recent year
    AND tot_suplr_benes >= 11  -- Filter out suppliers with low volume
)

SELECT
  s.suplr_prvdr_state_abrvtn as state,
  COUNT(DISTINCT s.suplr_npi) as supplier_count,
  ROUND(AVG(s.tot_suplr_benes), 0) as avg_beneficiaries,
  ROUND(AVG(s.payment_per_bene), 2) as avg_payment_per_bene,
  ROUND(AVG(s.pct_under_65), 1) as avg_pct_under_65,
  ROUND(AVG(s.pct_dual_eligible), 1) as avg_pct_dual_eligible,
  ROUND(AVG(s.pct_diabetes), 1) as avg_pct_diabetes,
  ROUND(AVG(s.pct_copd), 1) as avg_pct_copd,
  ROUND(AVG(s.pct_dementia), 1) as avg_pct_dementia,
  ROUND(AVG(s.bene_avg_risk_scre), 2) as avg_risk_score

FROM supplier_metrics s
GROUP BY s.suplr_prvdr_state_abrvtn
HAVING supplier_count >= 5  -- Only show states with meaningful supplier presence
ORDER BY avg_payment_per_bene DESC;

-- Query Operation:
-- 1. Creates a CTE with supplier-level metrics including demographics and conditions
-- 2. Aggregates metrics at the state level
-- 3. Calculates averages for key indicators
-- 4. Filters and sorts results to highlight notable patterns

-- Assumptions and Limitations:
-- - Uses most recent year's data (2022)
-- - Excludes suppliers with fewer than 11 beneficiaries for privacy
-- - Excludes states with fewer than 5 suppliers for statistical significance
-- - Percentages may not sum to 100 due to rounding and overlapping categories

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break down by urban/rural areas using RUCA codes
-- 3. Add supplier specialty analysis
-- 4. Include additional chronic conditions
-- 5. Create supplier peer groups based on beneficiary mix
-- 6. Add statistical testing for significant differences between states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:21:16.355233
    - Additional Notes: Query aggregates DMEPOS supplier beneficiary characteristics by state to reveal regional patterns in patient demographics and chronic conditions. Requires at least 5 suppliers per state and 11 beneficiaries per supplier for statistical validity. Performance may be impacted when analyzing multiple years of data.
    
    */