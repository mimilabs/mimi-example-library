-- RBCS Active Procedure Concentration Analysis
--
-- Business Purpose:
-- Identifies the most concentrated areas of active procedures within Medicare Part B services
-- to help healthcare organizations focus their operational and strategic planning.
-- This analysis supports resource allocation, training needs assessment, and market positioning decisions.

WITH active_procedures AS (
    -- Filter for current active procedures only
    SELECT 
        rbcs_cat,
        rbcs_cat_desc,
        rbcs_subcat_desc,
        rbcs_major_ind,
        COUNT(*) as procedure_count
    FROM mimi_ws_1.datacmsgov.betos
    WHERE hcpcs_cd_end_dt IS NULL  -- Active procedures
    AND _input_file_date = '2022-12-31'  -- Most recent data
    GROUP BY 
        rbcs_cat,
        rbcs_cat_desc,
        rbcs_subcat_desc,
        rbcs_major_ind
)

SELECT 
    rbcs_cat,
    rbcs_cat_desc,
    rbcs_subcat_desc,
    -- Break down by procedure complexity
    SUM(CASE WHEN rbcs_major_ind = 'M' THEN procedure_count ELSE 0 END) as major_procedures,
    SUM(CASE WHEN rbcs_major_ind = 'O' THEN procedure_count ELSE 0 END) as other_procedures,
    SUM(procedure_count) as total_procedures,
    -- Calculate concentration metrics
    ROUND(SUM(procedure_count) * 100.0 / SUM(SUM(procedure_count)) OVER (), 2) as pct_of_total
FROM active_procedures
GROUP BY 
    rbcs_cat,
    rbcs_cat_desc,
    rbcs_subcat_desc
HAVING total_procedures > 0
ORDER BY total_procedures DESC
LIMIT 15;

-- How this query works:
-- 1. Filters for currently active procedures using the most recent data
-- 2. Groups procedures by category and subcategory
-- 3. Calculates counts for major and other procedures
-- 4. Computes the concentration percentage for each category/subcategory combination
-- 5. Returns the top 15 most concentrated areas

-- Assumptions and Limitations:
-- - Assumes current date procedures (_input_file_date='2022-12-31') are most relevant
-- - Only considers active procedures (no end date)
-- - Does not account for procedure frequency or revenue impact
-- - Limited to top 15 areas for focus

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include revenue or cost data if available
-- 3. Add geographic distribution analysis
-- 4. Compare against specialty-specific benchmarks
-- 5. Include complexity ratio trends over time
-- 6. Add procedure volume or utilization metrics when available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:30:05.387520
    - Additional Notes: Query focuses on currently active procedures and their distribution patterns across categories, which is particularly useful for strategic planning and resource allocation. Note that the results are limited to top 15 most concentrated areas and only uses the most recent data snapshot (2022-12-31).
    
    */