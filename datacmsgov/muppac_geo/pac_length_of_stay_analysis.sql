-- pac_care_setting_length_of_stay.sql

-- Business Purpose:
-- Analyze average length of stay and service intensity across different post-acute care settings
-- to understand care delivery patterns and resource utilization. This analysis helps:
-- - Identify variations in care duration between settings
-- - Compare service utilization patterns
-- - Support capacity planning and resource allocation
-- - Inform payment policy and care pathway design

SELECT 
    -- Care setting and aggregation level
    srvc_ctgry AS care_setting,
    smry_ctgry AS summary_level,
    state,
    
    -- Calculate average length of stay
    ROUND(SUM(tot_srvc_days) / NULLIF(SUM(tot_epsd_stay_cnt), 0), 1) AS avg_length_of_stay,
    
    -- Service volume metrics
    SUM(bene_dstnct_cnt) AS total_beneficiaries,
    SUM(tot_epsd_stay_cnt) AS total_episodes,
    SUM(tot_srvc_days) AS total_service_days,
    
    -- Calculate average service minutes per day where applicable
    CASE 
        WHEN srvc_ctgry IN ('HH', 'SNF', 'IRF') THEN
            ROUND((SUM(tot_pt_mnts) + SUM(tot_ot_mnts) + SUM(tot_slp_mnts)) / 
                  NULLIF(SUM(tot_srvc_days), 0), 1)
        ELSE NULL
    END AS avg_therapy_minutes_per_day,
    
    -- Calculate average payment per episode
    ROUND(SUM(tot_mdcr_pymt_amt) / NULLIF(SUM(tot_epsd_stay_cnt), 0), 2) AS avg_payment_per_episode

FROM mimi_ws_1.datacmsgov.muppac_geo

-- Filter for most recent year and state/national level data
WHERE YEAR = (SELECT MAX(YEAR) FROM mimi_ws_1.datacmsgov.muppac_geo)
AND smry_ctgry IN ('State', 'National')

GROUP BY 
    srvc_ctgry,
    smry_ctgry,
    state

-- Order results logically
ORDER BY 
    CASE WHEN smry_ctgry = 'National' THEN 1 ELSE 2 END,
    care_setting,
    state

-- Query Design Notes:
-- 1. Groups data by care setting (HH, SNF, IRF, LTCH, Hospice) and geographic level
-- 2. Calculates key metrics around length of stay and service intensity
-- 3. Includes both state and national level data for comparison
-- 4. Uses conditional logic to handle therapy minutes which only apply to certain settings
-- 5. Handles null division cases using NULLIF

-- Assumptions & Limitations:
-- - Assumes therapy minutes are only relevant for HH, SNF, and IRF settings
-- - Does not account for case mix or patient complexity differences
-- - State-level comparisons may be affected by different patient populations
-- - Aggregated data masks individual provider variation

-- Possible Extensions:
-- 1. Add trending over multiple years to show longitudinal patterns
-- 2. Include patient demographic and clinical characteristics
-- 3. Break down therapy minutes by discipline (PT/OT/SLP)
-- 4. Add quality metrics or readmission rates
-- 5. Compare rural vs urban patterns
-- 6. Analyze seasonal variations in length of stay

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:12:58.487803
    - Additional Notes: Query focuses on length of stay patterns across care settings and calculates average service intensity metrics. The therapy minutes calculations are limited to HH, SNF, and IRF settings only. National and state-level aggregations provide hierarchical comparison capabilities. Results are most meaningful when analyzing the most recent full year of data.
    
    */