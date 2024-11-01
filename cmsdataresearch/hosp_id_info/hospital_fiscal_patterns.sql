-- hospital_fiscal_year_patterns.sql
-- Business Purpose: Analyze hospital fiscal year scheduling patterns to understand:
-- 1. Financial reporting cycles and potential seasonal impacts
-- 2. Operational trends that could affect reimbursement timing
-- 3. Planning considerations for healthcare analytics and reporting schedules
-- This information helps healthcare organizations better align their operations,
-- contracting cycles, and analytics timelines.

WITH fiscal_year_stats AS (
    -- Calculate fiscal year length and standardize to calendar format
    SELECT 
        date_trunc('year', fyb) as calendar_year,
        datediff(fye, fyb) as fy_length_days,
        CASE 
            WHEN MONTH(fyb) = 1 AND DAY(fyb) = 1 THEN 'Calendar Year'
            WHEN MONTH(fyb) = 7 AND DAY(fyb) = 1 THEN 'Mid-Year Start'
            WHEN MONTH(fyb) = 10 AND DAY(fyb) = 1 THEN 'Federal FY'
            ELSE 'Other'
        END as fy_pattern,
        COUNT(*) as hospital_count
    FROM mimi_ws_1.cmsdataresearch.hosp_id_info
    WHERE status = 'OPEN'  -- Focus on currently operating hospitals
    AND fyb IS NOT NULL 
    AND fye IS NOT NULL
    GROUP BY 1, 2, 3
)

SELECT 
    calendar_year,
    fy_pattern,
    hospital_count,
    fy_length_days,
    ROUND(100.0 * hospital_count / SUM(hospital_count) OVER (PARTITION BY calendar_year), 2) as pct_of_year
FROM fiscal_year_stats
WHERE calendar_year >= '2015-01-01'  -- Focus on recent years
ORDER BY calendar_year, hospital_count DESC;

-- How the query works:
-- 1. Creates a CTE to calculate fiscal year metrics for each hospital
-- 2. Categorizes fiscal year patterns into common types (Calendar, Mid-Year, Federal, Other)
-- 3. Aggregates hospitals by these patterns and calculates percentages
-- 4. Filters for recent years to show current trends

-- Assumptions and Limitations:
-- 1. Assumes fiscal year dates are accurately reported
-- 2. Limited to hospitals with 'OPEN' status
-- 3. May not capture mid-year fiscal year changes
-- 4. Focuses on standard fiscal year patterns; custom patterns grouped as 'Other'

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional fiscal year patterns
-- 2. Compare fiscal year patterns by hospital control type
-- 3. Analyze correlation between fiscal year pattern and hospital size/type
-- 4. Track changes in fiscal year patterns over time for individual hospitals
-- 5. Include financial metrics to assess impact of different fiscal year choices

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:24:59.138782
    - Additional Notes: Query focuses on fiscal year reporting cycles analysis which is crucial for financial planning and healthcare analytics scheduling. Note that the results are limited to open hospitals since 2015 and categorizes into common fiscal patterns (Calendar Year, Mid-Year Start, Federal FY). The 'Other' category may contain significant variations that require further investigation for specific use cases.
    
    */