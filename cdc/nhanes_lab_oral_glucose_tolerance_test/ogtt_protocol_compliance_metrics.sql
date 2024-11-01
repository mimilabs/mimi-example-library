-- Title: Oral Glucose Test Compliance and Quality Analysis
-- Business Purpose:
-- - Monitor patient compliance with glucose tolerance test protocols
-- - Identify potential data quality issues in test administration
-- - Support clinical operations optimization and protocol adherence
-- - Assess test completion rates and validity of results

WITH test_compliance AS (
    SELECT 
        mimi_src_file_date,
        -- Analyze test protocol compliance
        COUNT(*) as total_tests,
        AVG(CASE WHEN gtxdrank = 1 THEN 1 ELSE 0 END) * 100 as full_drink_pct,
        
        -- Check timing adherence
        AVG(CASE 
            WHEN gtdbl2mn BETWEEN 115 AND 125 THEN 1 
            ELSE 0 
        END) * 100 as correct_timing_pct,
        
        -- Evaluate fasting compliance
        AVG(CASE 
            WHEN phafsthr >= 8 THEN 1 
            ELSE 0 
        END) * 100 as fasting_compliance_pct,
        
        -- Assess completion rates
        AVG(CASE 
            WHEN lbxglt IS NOT NULL 
            AND gtdcode IS NULL THEN 1 
            ELSE 0 
        END) * 100 as completed_test_pct
    FROM mimi_ws_1.cdc.nhanes_lab_oral_glucose_tolerance_test
    GROUP BY mimi_src_file_date
    ORDER BY mimi_src_file_date
)

SELECT 
    mimi_src_file_date as test_date,
    total_tests,
    ROUND(full_drink_pct, 1) as pct_full_glucose_drink,
    ROUND(correct_timing_pct, 1) as pct_correct_timing,
    ROUND(fasting_compliance_pct, 1) as pct_proper_fasting,
    ROUND(completed_test_pct, 1) as pct_completed_tests
FROM test_compliance;

-- How this query works:
-- 1. Creates a CTE to calculate key compliance metrics
-- 2. Aggregates data by file date to show trends
-- 3. Calculates percentages for various quality indicators
-- 4. Rounds results for easier interpretation

-- Assumptions and Limitations:
-- - Assumes gtxdrank=1 indicates complete consumption of glucose drink
-- - Assumes 2-hour measurement should occur between 115-125 minutes
-- - Assumes 8+ hours fasting is compliant
-- - Missing values are treated as non-compliant
-- - Results are dependent on accurate data entry

-- Possible Extensions:
-- 1. Add stratification by demographic factors
-- 2. Include reasons for incomplete tests from gtdcode
-- 3. Create quality control alerts for non-compliant patterns
-- 4. Add seasonal analysis of compliance rates
-- 5. Compare compliance across different testing facilities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:19:15.928946
    - Additional Notes: Query focuses on operational quality metrics rather than clinical outcomes. Key metrics include protocol timing adherence, fasting compliance, and test completion rates. Results are aggregated by file date to show trends over time. Best used for clinical operations monitoring and quality improvement initiatives.
    
    */