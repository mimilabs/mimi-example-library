-- Medicare Inpatient Hospital Behavioral Health Analysis
-- 
-- Business Purpose:
-- This query analyzes the prevalence of behavioral health conditions among Medicare beneficiaries 
-- served by different hospitals to:
-- 1. Identify facilities with high volumes of behavioral health patients
-- 2. Assess variation in dual-eligible status and risk scores 
-- 3. Support strategic planning for behavioral health program development
-- 4. Enable targeted outreach to facilities serving vulnerable populations

WITH bh_metrics AS (
  SELECT 
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    tot_benes,
    tot_dschrgs,
    bene_dual_cnt,
    bene_avg_risk_scre,
    -- Calculate composite behavioral health score
    (bene_cc_bh_anxiety_v1_pct + 
     bene_cc_bh_depress_v1_pct +
     bene_cc_bh_schizo_oth_psy_v1_pct +
     bene_cc_bh_bipolar_v1_pct) as composite_bh_score,
    -- Calculate dual eligible percentage  
    ROUND(100.0 * bene_dual_cnt / tot_benes, 1) as dual_pct
  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31'
    AND tot_benes >= 100  -- Filter for meaningful sample size
)

SELECT
  rndrng_prvdr_state_abrvtn as state,
  rndrng_prvdr_ccn as ccn,
  rndrng_prvdr_org_name as hospital_name,
  tot_benes,
  tot_dschrgs,
  dual_pct,
  ROUND(composite_bh_score, 1) as composite_bh_score,
  ROUND(bene_avg_risk_scre, 2) as avg_risk_score,
  -- Flag high BH burden facilities
  CASE WHEN composite_bh_score > 200 THEN 'High BH'
       ELSE 'Standard' END as bh_designation
FROM bh_metrics
ORDER BY composite_bh_score DESC
LIMIT 100;

-- How it works:
-- 1. Creates behavioral health metrics by combining key psychiatric condition percentages
-- 2. Calculates dual eligible percentage as key social risk indicator
-- 3. Identifies facilities with high behavioral health burden
-- 4. Returns top 100 facilities ranked by behavioral health score

-- Assumptions & Limitations:
-- - Uses 2022 data only
-- - Minimum threshold of 100 beneficiaries per facility
-- - Composite score weights all conditions equally
-- - Does not account for severity within conditions

-- Possible Extensions:
-- 1. Add geographic analysis of behavioral health access
-- 2. Compare outcomes/costs between high vs standard BH facilities
-- 3. Trend analysis over multiple years
-- 4. Incorporate substance use disorder metrics
-- 5. Add hospital characteristics (teaching status, bed size, etc.)/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:11:20.018825
    - Additional Notes: Query focuses on behavioral health burden across hospitals using a composite score of mental health conditions. Note that the composite score methodology is simplified and may need adjustment based on clinical priorities. Dual eligibility and risk scores provide context for social determinants. Consider adjusting the minimum beneficiary threshold (currently 100) based on specific analysis needs.
    
    */