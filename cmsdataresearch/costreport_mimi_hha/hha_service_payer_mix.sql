-- TITLE: Service Mix and Patient Census Analysis for Home Health Agencies

-- BUSINESS PURPOSE:
-- Analyze the distribution of service types, visit patterns, and patient census across Medicare, Medicaid, and other payers
-- to understand:
-- - Service mix and utilization trends
-- - Patient volume by discipline
-- - Differences in payer mix across services
-- This helps identify opportunities for service line optimization and resource allocation

SELECT 
    hha_name,
    state_code,
    fiscal_year_begin_date,
    
    -- Calculate service mix percentages for Medicare
    ROUND(skilled_nursing_carern_medicare_title_xviii_visits * 100.0 / NULLIF(total_medicare_title_xviii_visits, 0), 1) as pct_rn_medicare_visits,
    ROUND(physical_therapy_medicare_title_xviii_visits * 100.0 / NULLIF(total_medicare_title_xviii_visits, 0), 1) as pct_pt_medicare_visits,
    ROUND(occupational_therapy_medicare_title_xviii_visits * 100.0 / NULLIF(total_medicare_title_xviii_visits, 0), 1) as pct_ot_medicare_visits,
    ROUND(home_health_aide_medicare_title_xviii_visits * 100.0 / NULLIF(total_medicare_title_xviii_visits, 0), 1) as pct_aide_medicare_visits,

    -- Patient census metrics
    skilled_nursing_carern_total_patient_census as rn_total_census,
    physical_therapy_total_patient_census as pt_total_census,
    occupational_therapy_total_patient_census as ot_total_census,
    home_health_aide_total_patient_census as aide_total_census,

    -- Payer mix analysis
    total_medicare_title_xviii_visits as total_medicare_visits,
    total_medicaid_title_xix_visits as total_medicaid_visits,
    total_other_visits as total_other_visits,
    total_total_visits as grand_total_visits,
    
    -- Calculate payer mix percentages
    ROUND(total_medicare_title_xviii_visits * 100.0 / NULLIF(total_total_visits, 0), 1) as pct_medicare_visits,
    ROUND(total_medicaid_title_xix_visits * 100.0 / NULLIF(total_total_visits, 0), 1) as pct_medicaid_visits,
    ROUND(total_other_visits * 100.0 / NULLIF(total_total_visits, 0), 1) as pct_other_visits

FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha

-- Filter for most recent complete data
WHERE fiscal_year_begin_date >= '2019-01-01'
AND total_total_visits > 0  -- Exclude agencies with no visits
AND rpt_stus_cd = 'F'      -- Only include final reports

ORDER BY total_total_visits DESC
LIMIT 1000;

-- HOW IT WORKS:
-- 1. Calculates service mix percentages within Medicare to show distribution of visit types
-- 2. Pulls patient census numbers to show scale of operations by discipline
-- 3. Analyzes overall payer mix across Medicare, Medicaid and other sources
-- 4. Filters for recent complete data and significant agencies

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes rpt_stus_cd = 'F' indicates final, complete reports
-- - Limited to agencies with positive visit volumes
-- - Census numbers may include some duplicate counting across services
-- - Does not account for differences in visit intensity or complexity

-- POSSIBLE EXTENSIONS:
-- 1. Add year-over-year trending of service and payer mix
-- 2. Include financial metrics like cost per visit by service type
-- 3. Add geographic grouping/analysis at state or regional level
-- 4. Compare service mix patterns between high and low performing agencies
-- 5. Analyze relationship between service mix and patient outcomes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:36:40.479578
    - Additional Notes: Query targets service utilization analysis and visit distribution patterns across payer types. Best used for strategic planning and resource allocation decisions. May require adjustment of visit volume threshold (currently uses >0) based on analysis needs.
    
    */