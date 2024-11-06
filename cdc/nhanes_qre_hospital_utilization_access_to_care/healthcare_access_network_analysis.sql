-- healthcare_provider_network_analysis.sql
-- Business Purpose: 
-- Analyze healthcare provider network utilization and patient loyalty
-- Key insights for healthcare providers and payers:
-- 1. Evaluate patient retention and preferred healthcare locations
-- 2. Understand healthcare access patterns across different settings
-- 3. Identify potential gaps in healthcare service delivery

WITH healthcare_access_summary AS (
    -- Categorize and aggregate healthcare access characteristics
    SELECT 
        CASE 
            WHEN huq030 = 1 THEN 'Has Usual Place of Care'
            WHEN huq030 = 2 THEN 'No Usual Place of Care'
            ELSE 'Unknown'
        END AS usual_care_status,
        CASE 
            WHEN huq04_ = 1 THEN 'Doctor''s Office'
            WHEN huq04_ = 2 THEN 'Clinic'
            WHEN huq04_ = 3 THEN 'Emergency Room'
            WHEN huq04_ = 4 THEN 'Other Place'
            ELSE 'Unspecified'
        END AS preferred_care_location,
        CASE 
            WHEN huq05_ = 0 THEN '0 Visits'
            WHEN huq05_ BETWEEN 1 AND 2 THEN '1-2 Visits'
            WHEN huq05_ BETWEEN 3 AND 4 THEN '3-4 Visits'
            WHEN huq05_ >= 5 THEN '5+ Visits'
            ELSE 'Unknown'
        END AS annual_visit_frequency,
        COUNT(*) AS respondent_count,
        ROUND(AVG(CAST(huq05_ AS FLOAT)), 2) AS avg_annual_visits
    FROM 
        mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
    GROUP BY 
        usual_care_status,
        preferred_care_location,
        annual_visit_frequency
)

SELECT 
    usual_care_status,
    preferred_care_location,
    annual_visit_frequency,
    respondent_count,
    ROUND(respondent_count * 100.0 / SUM(respondent_count) OVER (), 2) AS percentage_distribution,
    avg_annual_visits
FROM 
    healthcare_access_summary
ORDER BY 
    respondent_count DESC
LIMIT 20;

-- Query Methodology:
-- 1. Creates a CTE to categorize healthcare access dimensions
-- 2. Segments data by usual care status, preferred location, and visit frequency
-- 3. Calculates respondent counts and percentage distributions
-- 4. Provides insights into patient healthcare engagement patterns

-- Assumptions and Limitations:
-- - Data represents self-reported survey responses
-- - Limited to NHANES survey sample
-- - Potential recall bias in reporting healthcare visits

-- Potential Query Extensions:
-- 1. Add demographic segmentation (age, gender, income)
-- 2. Analyze longitudinal trends across survey cycles
-- 3. Incorporate health status correlation (huq010)

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:39:46.516637
    - Additional Notes: Captures multi-dimensional view of healthcare utilization patterns with categorical breakdowns. Useful for healthcare policy planning and provider network strategy. Requires careful interpretation due to survey-based data collection methodology.
    
    */