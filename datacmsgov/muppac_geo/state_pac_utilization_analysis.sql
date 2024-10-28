
/*******************************************************************************
Medicare Post-Acute Care and Hospice Utilization Analysis

This query analyzes key metrics across different post-acute care settings to 
understand utilization patterns, costs, and patient demographics at the state level.

Business Purpose:
- Compare utilization and costs across post-acute care settings by state
- Identify geographic variations in post-acute care delivery
- Support healthcare policy and resource allocation decisions

Primary Metric Groups:
- Service utilization (episodes, days) 
- Costs and payments
- Patient demographics and clinical characteristics
*******************************************************************************/

WITH state_summary AS (
  -- Get state-level stats for each service category, excluding national records
  SELECT 
    state,
    srvc_ctgry,
    SUM(bene_dstnct_cnt) as total_beneficiaries,
    SUM(tot_epsd_stay_cnt) as total_episodes,
    SUM(tot_srvc_days) as total_service_days,
    ROUND(AVG(tot_mdcr_pymt_amt/NULLIF(bene_dstnct_cnt,0)), 2) as avg_payment_per_beneficiary,
    ROUND(AVG(bene_avg_age), 1) as avg_patient_age,
    ROUND(AVG(bene_dual_pct), 1) as avg_dual_eligible_pct,
    ROUND(AVG(bene_rrl_pct), 1) as avg_rural_pct
  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'State' 
    AND state IS NOT NULL
    AND year = 2022  -- Adjust year as needed
  GROUP BY state, srvc_ctgry
)

SELECT
  state,
  srvc_ctgry as service_category,
  total_beneficiaries,
  total_episodes,
  total_service_days,
  avg_payment_per_beneficiary,
  avg_patient_age,
  avg_dual_eligible_pct as pct_dual_eligible,
  avg_rural_pct as pct_rural
FROM state_summary
ORDER BY 
  state,
  CASE srvc_ctgry
    WHEN 'HH' THEN 1    -- Home Health
    WHEN 'SNF' THEN 2   -- Skilled Nursing
    WHEN 'IRF' THEN 3   -- Inpatient Rehab
    WHEN 'LTCH' THEN 4  -- Long-term Care Hospital
    WHEN 'Hospice' THEN 5
    ELSE 6
  END;

/*******************************************************************************
HOW IT WORKS:
1. Creates state-level summary by aggregating key metrics
2. Calculates per-beneficiary averages and percentages 
3. Orders results by state and service category for easy comparison

ASSUMPTIONS & LIMITATIONS:
- Focuses on state-level analysis only (excludes provider & national level)
- Some states may have incomplete data for certain services
- Averages may be skewed for states with low beneficiary counts
- Limited to one year of data at a time

POSSIBLE EXTENSIONS:
1. Add year-over-year comparison:
   - Include multiple years
   - Calculate growth rates

2. Enhanced geographic analysis:
   - Group by census regions
   - Urban vs rural comparisons
   - State demographic correlations

3. Deeper service analysis:
   - Length of stay distributions
   - Therapy minutes analysis
   - Diagnosis pattern analysis
   - Cost variation analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:28:40.296876
    - Additional Notes: The query summarizes Medicare post-acute care utilization metrics at the state level, currently hardcoded for 2022. Users should modify the year filter in the CTE to analyze different time periods. The analysis may be incomplete for states with redacted data due to low volume providers.
    
    */