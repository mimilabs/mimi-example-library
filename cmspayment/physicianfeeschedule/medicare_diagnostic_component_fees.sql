-- Title: Medicare Professional vs Technical Component Payment Analysis
-- Business Purpose: Analyze reimbursement differences between professional (physician work) 
-- and technical (facility/equipment) components of diagnostic services to support:
-- - Service line planning for imaging centers and facilities
-- - Provider contract negotiations
-- - Resource allocation decisions between professional staff vs equipment investments

WITH base_components AS (
    -- Get diagnostic tests with both professional and technical components
    SELECT 
        year,
        hcpcs_code,
        locality,
        -- Professional component (modifier 26)
        MAX(CASE WHEN modifier = '26' THEN non_facility_fee_schedule_amount END) as prof_component_fee,
        -- Technical component (modifier TC)  
        MAX(CASE WHEN modifier = 'TC' THEN non_facility_fee_schedule_amount END) as tech_component_fee,
        -- Global fee (no modifier)
        MAX(CASE WHEN modifier IS NULL THEN non_facility_fee_schedule_amount END) as global_fee
    FROM mimi_ws_1.cmspayment.physicianfeeschedule
    WHERE pctc_indicator = '1' -- Diagnostic tests that can be split into components
    AND status_code = 'A'      -- Active codes only
    AND year = 2024           -- Current year
    GROUP BY 1,2,3
)
SELECT
    hcpcs_code,
    COUNT(DISTINCT locality) as num_localities,
    ROUND(AVG(prof_component_fee),2) as avg_prof_fee,
    ROUND(AVG(tech_component_fee),2) as avg_tech_fee,
    ROUND(AVG(tech_component_fee/prof_component_fee),1) as tech_to_prof_ratio,
    ROUND(AVG(global_fee),2) as avg_global_fee
FROM base_components
WHERE prof_component_fee > 0 
AND tech_component_fee > 0
GROUP BY 1
HAVING COUNT(DISTINCT locality) > 30 -- Focus on widely used procedures
ORDER BY avg_global_fee DESC
LIMIT 20;

-- How it works:
-- 1. Identifies diagnostic procedures that can be split into professional/technical components
-- 2. Calculates average fees for each component across localities
-- 3. Computes the ratio of technical to professional fees
-- 4. Focuses on widely used procedures across multiple localities

-- Assumptions and Limitations:
-- - Only includes active procedure codes (status = 'A')
-- - Limited to diagnostic procedures with both components (pctc_indicator = '1')
-- - Excludes procedures with $0 fees for either component
-- - Averages may mask significant geographic variation
-- - Current year data only

-- Possible Extensions:
-- 1. Add year-over-year trending of component ratios
-- 2. Include procedure descriptions and categories
-- 3. Add geographic analysis by state/region
-- 4. Compare against facility vs non-facility differences
-- 5. Filter for specific types of diagnostic services (e.g., imaging, pathology)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:47:00.427994
    - Additional Notes: Query separates and compares professional (physician) vs technical (facility) components of Medicare diagnostic service payments. Best used for analyzing cost structures of diagnostic facilities and physician compensation models. Only includes procedures with both components and significant geographic distribution.
    
    */