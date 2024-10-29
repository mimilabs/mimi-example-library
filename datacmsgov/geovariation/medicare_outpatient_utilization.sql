-- medicare_service_utilization_patterns.sql

-- Purpose: Analyze patterns of healthcare service utilization and facility type preferences
-- across geographic regions to understand how beneficiaries access different care settings.
-- This analysis helps healthcare organizations optimize service delivery networks and
-- identify opportunities for care coordination.

-- Business Context:
-- - Informs network development and facility planning strategies
-- - Highlights regional variations in care delivery models
-- - Supports care coordination program design
-- - Identifies potential access barriers or gaps in service availability

SELECT 
    year,
    bene_geo_lvl,
    bene_geo_desc,
    benes_ffs_cnt,
    
    -- Outpatient facility utilization metrics
    op_visits_per_1000_benes AS outpatient_visits_rate,
    benes_op_pct AS pct_using_outpatient,
    
    -- Ambulatory surgery center utilization 
    asc_evnts_per_1000_benes AS asc_procedures_rate,
    benes_asc_pct AS pct_using_asc,
    
    -- Community health center utilization
    fqhc_rhc_visits_per_1000_benes AS fqhc_rhc_visits_rate,
    benes_fqhc_rhc_pct AS pct_using_fqhc_rhc,
    
    -- Emergency department utilization
    er_visits_per_1000_benes AS ed_visits_rate,
    benes_er_visits_pct AS pct_using_ed,
    
    -- Key ratios to assess care setting preferences
    ROUND(asc_evnts_per_1000_benes / NULLIF(op_visits_per_1000_benes, 0), 3) 
        AS asc_to_hospital_outpatient_ratio,
    ROUND(fqhc_rhc_visits_per_1000_benes / NULLIF(op_visits_per_1000_benes, 0), 3) 
        AS fqhc_to_hospital_outpatient_ratio

FROM mimi_ws_1.datacmsgov.geovariation

WHERE bene_age_lvl = 'All Beneficiaries'
  AND year = (SELECT MAX(year) FROM mimi_ws_1.datacmsgov.geovariation)
  AND bene_geo_lvl IN ('State', 'National')

ORDER BY 
    CASE bene_geo_lvl 
        WHEN 'National' THEN 1 
        WHEN 'State' THEN 2
    END,
    bene_geo_desc;

-- How this works:
-- 1. Focuses on outpatient care settings: hospital outpatient, ASC, FQHC/RHC, and ED
-- 2. Calculates utilization rates per 1000 beneficiaries and percentage of beneficiaries using each setting
-- 3. Creates ratios comparing ASC and FQHC utilization to hospital outpatient utilization
-- 4. Filters to most recent year and state/national level data
-- 5. Orders results to show national benchmark first, followed by states

-- Assumptions and limitations:
-- - Focuses on FFS Medicare beneficiaries only
-- - Does not account for differences in population health status
-- - Ratios may be affected by data completeness in rural areas
-- - Service intensity and complexity not considered in visit counts

-- Possible extensions:
-- 1. Add year-over-year trends analysis
-- 2. Incorporate demographic factors (age, dual status)
-- 3. Add cost per visit metrics by setting
-- 4. Include quality metrics by facility type
-- 5. Add geographic distance/drive time analysis
-- 6. Compare urban vs rural utilization patterns
-- 7. Analyze seasonal variation in utilization

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:22:10.470531
    - Additional Notes: Query reveals care setting preferences by comparing utilization rates across outpatient facilities (hospital outpatient, ASC, FQHC/RHC, ED). The ratio calculations help identify regions where alternative care settings are more prevalent, which can inform network planning and care coordination strategies. Limited to state-level analysis of fee-for-service beneficiaries.
    
    */