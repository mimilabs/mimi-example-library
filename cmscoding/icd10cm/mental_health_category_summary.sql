-- Title: ICD-10-CM Mental Health Condition Analysis

-- Business Purpose:
-- - Identify and analyze mental health related diagnostic codes
-- - Support behavioral health program planning and resource allocation
-- - Enable population health management for mental health conditions
-- - Aid in mental health service line development and marketing

-- Main Query
WITH mental_health_codes AS (
    -- Filter for current mental health codes (F01-F99 range)
    SELECT 
        code,
        description,
        mimi_src_file_date
    FROM mimi_ws_1.cmscoding.icd10cm
    WHERE code LIKE 'F%'
    AND LENGTH(code) = 3  -- Focus on primary categories
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmscoding.icd10cm)
)

SELECT 
    -- Create meaningful groupings of mental health conditions
    CASE 
        WHEN code BETWEEN 'F01' AND 'F09' THEN 'Organic Mental Disorders'
        WHEN code BETWEEN 'F10' AND 'F19' THEN 'Substance Use Disorders'
        WHEN code BETWEEN 'F20' AND 'F29' THEN 'Schizophrenia Spectrum'
        WHEN code BETWEEN 'F30' AND 'F39' THEN 'Mood Disorders'
        WHEN code BETWEEN 'F40' AND 'F48' THEN 'Anxiety Disorders'
        ELSE 'Other Mental Health Conditions'
    END AS condition_category,
    
    -- Collect codes and descriptions for each category
    COUNT(*) as code_count,
    COLLECT_LIST(CONCAT(code, ': ', description)) as detailed_codes
FROM mental_health_codes
GROUP BY 
    CASE 
        WHEN code BETWEEN 'F01' AND 'F09' THEN 'Organic Mental Disorders'
        WHEN code BETWEEN 'F10' AND 'F19' THEN 'Substance Use Disorders'
        WHEN code BETWEEN 'F20' AND 'F29' THEN 'Schizophrenia Spectrum'
        WHEN code BETWEEN 'F30' AND 'F39' THEN 'Mood Disorders'
        WHEN code BETWEEN 'F40' AND 'F48' THEN 'Anxiety Disorders'
        ELSE 'Other Mental Health Conditions'
    END
ORDER BY condition_category;

-- How the Query Works:
-- 1. CTE filters for mental health codes (F-codes) using the most recent data
-- 2. Main query categorizes codes into major mental health condition groups
-- 3. Aggregates codes within each category and provides detailed descriptions
-- 4. Results are ordered by condition category for easy reading

-- Assumptions and Limitations:
-- - Uses only 3-character codes for high-level categorization
-- - Focuses on current codes only (most recent mimi_src_file_date)
-- - Categorization is simplified; some nuanced conditions may be oversimplified
-- - Does not include severity levels or additional specifications

-- Possible Extensions:
-- 1. Add trend analysis by comparing categories across multiple years
-- 2. Include more detailed subcategories using 4+ character codes
-- 3. Create mappings to common treatment protocols or medications
-- 4. Add related procedure codes (ICD-10-PCS) for common treatments
-- 5. Incorporate cost or utilization data if available in other tables

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:11:20.953964
    - Additional Notes: The query uses COLLECT_LIST which may have memory limitations for very large datasets. Results are grouped by high-level F-code categories only, focusing on the primary 3-character ICD-10-CM mental health diagnostic codes. For detailed subcategory analysis, the LENGTH(code) = 3 filter should be modified.
    
    */