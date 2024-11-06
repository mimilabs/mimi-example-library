-- TITLE: Home Health Agency Utilization and Service Capacity Analysis

-- BUSINESS PURPOSE:
-- This analysis examines the operational capacity and utilization patterns of home health agencies to:
-- - Assess patient access by analyzing total visit volumes and patient census
-- - Evaluate staffing mix and service delivery capacity
-- - Understand the relationship between agency size and service diversity
-- - Identify potential capacity constraints or underutilization

WITH agency_service_metrics AS (
    -- Calculate key service volume metrics per agency
    SELECT 
        provider_ccn,
        hha_name,
        state_code,
        type_of_control,
        fiscal_year_end_date,
        -- Total visit volumes
        total_total_visits,
        -- Calculate mix of nursing vs therapy visits
        skilled_nursing_carern_total_visits + skilled_nursing_carelpn_total_visits AS total_nursing_visits,
        physical_therapy_total_visits + occupational_therapy_total_visits + speech_language_path_total_visits AS total_therapy_visits,
        -- Patient census metrics
        skilled_nursing_carern_total_patient_census + skilled_nursing_carelpn_total_patient_census AS total_nursing_census,
        physical_therapy_total_patient_census + occupational_therapy_total_patient_census + 
        speech_language_path_total_patient_census AS total_therapy_census
    FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
    WHERE fiscal_year_end_date >= '2019-01-01'
    AND total_total_visits > 0
)

SELECT
    state_code,
    type_of_control,
    COUNT(DISTINCT provider_ccn) as agency_count,
    
    -- Volume metrics
    AVG(total_total_visits) as avg_annual_visits,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_total_visits) as median_annual_visits,
    
    -- Service mix
    AVG(total_nursing_visits * 100.0 / NULLIF(total_total_visits, 0)) as avg_pct_nursing_visits,
    AVG(total_therapy_visits * 100.0 / NULLIF(total_total_visits, 0)) as avg_pct_therapy_visits,
    
    -- Census metrics
    AVG(total_nursing_census) as avg_nursing_census,
    AVG(total_therapy_census) as avg_therapy_census

FROM agency_service_metrics
GROUP BY state_code, type_of_control
HAVING COUNT(DISTINCT provider_ccn) >= 3 -- Ensure adequate sample size
ORDER BY state_code, agency_count DESC;

-- HOW IT WORKS:
-- 1. Creates a CTE that calculates key operational metrics per agency
-- 2. Aggregates metrics by state and control type to show patterns
-- 3. Includes both volume and mix metrics to understand service capacity
-- 4. Filters to recent years and active agencies for relevance

-- ASSUMPTIONS & LIMITATIONS:
-- - Assumes visit volumes > 0 indicates active agencies
-- - Limited to recent years (2019+) for current relevance
-- - Requires at least 3 agencies per group for meaningful averages
-- - Does not account for seasonal variations
-- - May not reflect quality of care or patient outcomes

-- POSSIBLE EXTENSIONS:
-- 1. Add year-over-year growth rates to identify expanding/contracting markets
-- 2. Include financial metrics to correlate size with financial performance
-- 3. Add geographic clustering analysis to identify service gaps
-- 4. Compare actual utilization to licensed capacity
-- 5. Break down service mix by payer type
-- 6. Add quality metrics to assess relationship between size and outcomes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:47:56.193445
    - Additional Notes: Query provides balanced overview of HHA service capacity and utilization while minimizing overlap with other operational analytics. Works best for comparative analysis across states and ownership types. Consider memory usage if expanding time range beyond recommended 2019+ filter.
    
    */