-- pac_therapy_services_analysis.sql

-- Business Purpose:
-- Analyze therapy service utilization and intensity across post-acute care settings
-- to understand care delivery patterns and potential opportunities for optimizing 
-- therapy services. This analysis helps:
-- - Compare therapy minutes per patient across settings
-- - Evaluate mix of individual vs group therapy
-- - Identify variations in therapy service delivery
-- - Support therapy staffing and resource allocation decisions

WITH therapy_metrics AS (
  SELECT 
    srvc_ctgry,
    smry_ctgry,
    state,
    -- Calculate average therapy minutes per beneficiary
    ROUND(tot_pt_mnts / NULLIF(bene_dstnct_cnt, 0), 1) as avg_pt_mins_per_bene,
    ROUND(tot_ot_mnts / NULLIF(bene_dstnct_cnt, 0), 1) as avg_ot_mins_per_bene, 
    ROUND(tot_slp_mnts / NULLIF(bene_dstnct_cnt, 0), 1) as avg_slp_mins_per_bene,
    
    -- Calculate percent individual vs concurrent/group therapy
    ROUND(100.0 * indvdl_pt_mnts / NULLIF(tot_pt_mnts, 0), 1) as pct_individual_pt,
    ROUND(100.0 * (cncrnt_grp_pt_mnts + cotrt_pt_mnts) / NULLIF(tot_pt_mnts, 0), 1) as pct_group_pt,
    
    -- Total beneficiaries and average clinical characteristics
    bene_dstnct_cnt,
    bene_avg_risk_scre,
    bene_avg_age
  FROM mimi_ws_1.datacmsgov.muppac_geo
  WHERE smry_ctgry = 'State'  -- State-level analysis
    AND year = 2022  -- Most recent year
    AND srvc_ctgry IN ('SNF', 'IRF') -- Focus on settings with significant therapy
)

SELECT
  srvc_ctgry as setting,
  COUNT(state) as num_states,
  
  -- Physical therapy metrics
  ROUND(AVG(avg_pt_mins_per_bene), 1) as avg_pt_mins,
  ROUND(AVG(pct_individual_pt), 1) as avg_pct_individual_pt,
  ROUND(AVG(pct_group_pt), 1) as avg_pct_group_pt,
  
  -- Average patient characteristics
  ROUND(AVG(bene_avg_risk_scre), 2) as avg_risk_score,
  ROUND(AVG(bene_avg_age), 1) as avg_patient_age,
  
  -- Volume metrics  
  SUM(bene_dstnct_cnt) as total_beneficiaries
FROM therapy_metrics
GROUP BY srvc_ctgry
ORDER BY total_beneficiaries DESC;

-- How this query works:
-- 1. Creates a CTE to calculate key therapy metrics at the state level
-- 2. Focuses on SNF and IRF settings where therapy is a core service
-- 3. Calculates average therapy minutes per beneficiary and therapy delivery patterns
-- 4. Aggregates results to compare patterns across settings

-- Assumptions and Limitations:
-- - Assumes therapy minutes are accurately reported in source data
-- - Limited to state-level analysis; facility-level variations not captured
-- - Focuses only on Medicare fee-for-service beneficiaries
-- - Does not account for case-mix differences between settings

-- Possible Extensions:
-- 1. Add trend analysis by including multiple years
-- 2. Break down therapy patterns by patient diagnoses
-- 3. Include geographic analysis of therapy intensity
-- 4. Add cost analysis related to therapy utilization
-- 5. Compare outcomes for different therapy delivery patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:59:12.424447
    - Additional Notes: Note that the analysis is limited to SNF and IRF settings due to their higher therapy service volume. The query focuses on state-level averages which may mask significant facility-level variations. Therapy minutes calculations assume complete and accurate reporting in the source data.
    
    */