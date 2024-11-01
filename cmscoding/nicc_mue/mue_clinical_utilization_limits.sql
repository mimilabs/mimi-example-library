-- TITLE: Medicare MUE Clinical Utilization Pattern Analysis

-- PURPOSE: Analyze the clinical utilization patterns and billing restrictions across 
-- different service types to identify:
-- 1. High-volume procedures with strict billing limits
-- 2. Services with varying restrictions across settings
-- 3. Rationale patterns that may impact care delivery
-- 
-- Business Value: This analysis helps:
-- - Revenue cycle teams optimize billing practices
-- - Clinical operations teams understand service delivery constraints
-- - Strategic planning teams identify potential care setting opportunities

-- Main Query
WITH ranked_procedures AS (
    SELECT 
        hcpcs_cpt_code,
        service_type,
        COALESCE(dme_supplier_services_mue_values, 
                 outpatient_hospital_services_mue_values,
                 practitioner_services_mue_values) as mue_value,
        mue_rationale,
        mue_adjudication_indicator,
        -- Rank procedures within each service type by MUE value
        ROW_NUMBER() OVER (PARTITION BY service_type 
                          ORDER BY COALESCE(dme_supplier_services_mue_values,
                                          outpatient_hospital_services_mue_values,
                                          practitioner_services_mue_values) DESC) as rank_in_type
    FROM mimi_ws_1.cmscoding.nicc_mue
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.cmscoding.nicc_mue)
)
SELECT 
    service_type,
    hcpcs_cpt_code,
    mue_value,
    mue_rationale,
    mue_adjudication_indicator,
    -- Calculate percentage of total procedures for context
    COUNT(*) OVER (PARTITION BY service_type) as total_procedures_in_type,
    ROUND(mue_value * 100.0 / SUM(mue_value) OVER (PARTITION BY service_type), 2) as pct_of_type_total
FROM ranked_procedures
WHERE rank_in_type <= 10  -- Focus on top 10 procedures per service type
ORDER BY 
    service_type,
    mue_value DESC;

-- HOW IT WORKS:
-- 1. Uses CTE to rank procedures within each service type based on MUE values
-- 2. Focuses on most recent data using latest mimi_src_file_date
-- 3. Coalesces MUE values across different service settings
-- 4. Calculates relative percentages for context
-- 5. Returns top 10 procedures per service type

-- ASSUMPTIONS & LIMITATIONS:
-- 1. Assumes latest file date represents current policy
-- 2. Treats null MUE values as missing rather than zero
-- 3. Limited to top 10 procedures per type for manageable analysis
-- 4. Does not account for seasonal variations
-- 5. Does not consider procedure costs or reimbursement rates

-- POSSIBLE EXTENSIONS:
-- 1. Add procedure descriptions for better context
-- 2. Include trend analysis across multiple quarters
-- 3. Incorporate cost/reimbursement data for financial impact
-- 4. Add specialty-specific analysis
-- 5. Compare against actual utilization data if available
-- 6. Analyze rationale patterns for compliance insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:17:11.890402
    - Additional Notes: Query focuses on identifying utilization restrictions by service type and could be resource-intensive on large datasets due to window functions. Consider adding WHERE clauses for specific service types if analyzing a subset of data.
    
    */