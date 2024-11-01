-- Title: ICD-10-CM Code Changes and Updates Analysis
-- 
-- Business Purpose:
-- - Track and analyze changes in ICD-10-CM codes across annual updates
-- - Identify new, removed, and modified diagnosis codes
-- - Support healthcare organizations in maintaining compliant diagnosis coding
-- - Enable impact analysis of coding changes on clinical documentation and billing

WITH code_changes AS (
    SELECT 
        code,
        description,
        EXTRACT(YEAR FROM mimi_src_file_date) as code_year,
        -- Flag codes present in current but not previous year
        CASE WHEN LAG(code) OVER (PARTITION BY code ORDER BY mimi_src_file_date) IS NULL 
             THEN 'New'
             -- Flag codes with description changes
             WHEN description != LAG(description) OVER (PARTITION BY code ORDER BY mimi_src_file_date)
             THEN 'Modified'
             ELSE 'Unchanged'
        END as change_status
    FROM mimi_ws_1.cmscoding.icd10cm
),

annual_summary AS (
    SELECT 
        code_year,
        change_status,
        COUNT(*) as code_count,
        -- Calculate percentage of total codes for that year
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY code_year), 2) as pct_of_year
    FROM code_changes
    GROUP BY code_year, change_status
)

SELECT 
    code_year,
    change_status,
    code_count,
    pct_of_year as percentage_of_total,
    -- Create a simple visual representation
    REPEAT('■', CAST(pct_of_year AS INT)) as visual_distribution
FROM annual_summary
ORDER BY code_year DESC, change_status;

-- How it works:
-- 1. First CTE (code_changes) identifies the status of each code by comparing with previous year
-- 2. Second CTE (annual_summary) aggregates changes by year and status
-- 3. Final query adds visualization and formats results for presentation

-- Assumptions and Limitations:
-- - Assumes sequential annual updates in the source data
-- - Cannot detect codes that were removed (requires additional logic)
-- - Visual representation rounds to nearest integer
-- - Does not account for sub-category or hierarchical relationships

-- Possible Extensions:
-- 1. Add specific code examples for each type of change
-- 2. Include analysis of which clinical areas experience most changes
-- 3. Add deletion detection by comparing year-over-year
-- 4. Generate compliance impact reports for specific specialties
-- 5. Create forecasting for future code volume based on historical patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:08:56.523327
    - Additional Notes: Query tracks year-over-year changes in ICD-10-CM codes, focusing on new and modified codes. Best used with multi-year data. Performance may be impacted with very large datasets due to window functions. Consider partitioning by year if performance issues arise.
    
    */