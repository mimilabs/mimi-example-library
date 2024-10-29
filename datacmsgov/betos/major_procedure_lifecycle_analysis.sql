-- Major Procedure Trends and Transitions Analysis
-- Business Purpose: Identifies patterns in how medical procedures transition between active 
-- and inactive status over time, with focus on major procedures. This helps healthcare 
-- organizations understand procedural code lifecycle management, plan for changes,
-- and track evolution of medical services coverage.

WITH active_procedures AS (
    -- Get currently active major procedures
    SELECT 
        hcpcs_cd,
        rbcs_family_desc,
        rbcs_subcat_desc,
        hcpcs_cd_add_dt,
        hcpcs_cd_end_dt
    FROM mimi_ws_1.datacmsgov.betos
    WHERE rbcs_major_ind = 'M'  -- Focus on major procedures
    AND (_input_file_date = '2022-12-31'  -- Most recent data
    AND (hcpcs_cd_end_dt IS NULL OR hcpcs_cd_end_dt > CURRENT_DATE))
),

procedure_transitions AS (
    -- Compare against historical data to find transitions
    SELECT 
        hcpcs_cd,
        rbcs_family_desc,
        rbcs_subcat_desc,
        hcpcs_cd_add_dt,
        DATEDIFF(month, hcpcs_cd_add_dt, COALESCE(hcpcs_cd_end_dt, CURRENT_DATE)) as months_active,
        CASE 
            WHEN hcpcs_cd_end_dt IS NULL THEN 'Currently Active'
            ELSE 'Discontinued'
        END as status
    FROM mimi_ws_1.datacmsgov.betos
    WHERE rbcs_major_ind = 'M'
)

SELECT 
    rbcs_subcat_desc,
    COUNT(DISTINCT hcpcs_cd) as procedure_count,
    AVG(months_active) as avg_months_active,
    SUM(CASE WHEN status = 'Currently Active' THEN 1 ELSE 0 END) as active_procedures,
    SUM(CASE WHEN status = 'Discontinued' THEN 1 ELSE 0 END) as discontinued_procedures
FROM procedure_transitions
GROUP BY rbcs_subcat_desc
ORDER BY procedure_count DESC;

-- How it works:
-- 1. First CTE identifies currently active major procedures
-- 2. Second CTE calculates lifecycle metrics for all major procedures
-- 3. Final query aggregates by subcategory to show procedure counts and status distribution

-- Assumptions and Limitations:
-- - Assumes current date is relevant for active status determination
-- - Limited to major procedures only (rbcs_major_ind = 'M')
-- - Does not account for seasonal or temporary procedure codes
-- - Transition patterns may vary by specialty and region

-- Possible Extensions:
-- 1. Add time-based trending to show how procedure counts change quarterly/yearly
-- 2. Include replacement analysis (which new codes replace discontinued ones)
-- 3. Add specialty-specific analysis by joining with provider specialty data
-- 4. Incorporate cost/reimbursement data to understand financial impact
-- 5. Create predictive model for procedure code lifecycle based on historical patterns/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:09:00.224312
    - Additional Notes: Query focuses on procedure code lifecycle metrics and transitions, particularly useful for healthcare administrators and policy analysts tracking Medicare service evolution. Best run on annual data snapshots for trend analysis. Consider memory usage when extending to multi-year comparisons.
    
    */