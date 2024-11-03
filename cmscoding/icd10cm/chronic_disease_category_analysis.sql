-- Title: ICD-10-CM Chronic Disease Code Analysis

-- Business Purpose:
-- - Identify and analyze diagnostic codes related to major chronic diseases
-- - Support population health management and care coordination programs
-- - Enable risk stratification and disease management initiatives
-- - Guide preventive care and wellness program development

-- Main Query
WITH chronic_conditions AS (
    SELECT 
        code,
        description,
        mimi_src_file_date,
        -- Identify major chronic disease categories using code patterns
        CASE 
            WHEN code LIKE 'E11%' THEN 'Type 2 Diabetes'
            WHEN code LIKE 'I10%' THEN 'Hypertension'
            WHEN code LIKE 'I25%' THEN 'Chronic Heart Disease'
            WHEN code LIKE 'J44%' THEN 'COPD'
            WHEN code LIKE 'J45%' THEN 'Asthma'
        END AS chronic_category
    FROM mimi_ws_1.cmscoding.icd10cm
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmscoding.icd10cm)
)
SELECT 
    chronic_category,
    COUNT(DISTINCT code) as code_count,
    MIN(description) as sample_condition,
    -- Using collect_set instead of STRING_AGG for Spark SQL compatibility
    collect_set(SUBSTRING(code, 1, 3)) as common_code_patterns
FROM chronic_conditions
WHERE chronic_category IS NOT NULL
GROUP BY chronic_category
ORDER BY code_count DESC;

-- How it works:
-- 1. Identifies the most recent ICD-10-CM code set using MAX(mimi_src_file_date)
-- 2. Uses CASE statement to categorize codes into major chronic conditions
-- 3. Aggregates results to show code counts and patterns for each category
-- 4. Provides sample conditions and common code patterns for reference

-- Assumptions and Limitations:
-- - Focuses only on selected high-priority chronic conditions
-- - Uses simple pattern matching which may not capture all relevant codes
-- - Based on current version of ICD-10-CM codes only
-- - Does not account for combination codes or complications

-- Possible Extensions:
-- 1. Add more chronic condition categories (e.g., cancer, kidney disease)
-- 2. Include trend analysis across multiple years
-- 3. Add severity indicators based on code specificity
-- 4. Create hierarchical groupings within each chronic condition
-- 5. Include related conditions and common comorbidities
-- 6. Add mapping to quality measures or care guidelines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:57:38.345360
    - Additional Notes: Query focuses on five major chronic conditions (diabetes, hypertension, heart disease, COPD, asthma) and provides category-level metrics using the most recent ICD-10-CM codes. The collect_set function returns arrays of unique code patterns which may need to be processed further for reporting purposes.
    
    */