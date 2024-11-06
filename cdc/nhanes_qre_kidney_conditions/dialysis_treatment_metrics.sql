-- kidney_dialysis_and_symptoms.sql

-- Business Purpose:
-- Analyze the relationship between dialysis treatment and associated kidney symptoms
-- to better understand treatment patterns and symptom burden. This information can help:
-- - Healthcare providers optimize dialysis care delivery
-- - Payers understand treatment complexity and resource needs
-- - Healthcare systems plan dialysis service capacity
-- - Researchers study quality of life impacts on dialysis patients

SELECT 
    -- Calculate dialysis and symptom rates
    COUNT(DISTINCT seqn) AS total_patients,
    
    -- Dialysis metrics
    SUM(CASE WHEN kiq025 = 1 THEN 1 ELSE 0 END) AS patients_on_dialysis,
    ROUND(100.0 * SUM(CASE WHEN kiq025 = 1 THEN 1 ELSE 0 END) / COUNT(DISTINCT seqn), 1) AS dialysis_rate,
    
    -- Kidney condition indicators
    SUM(CASE WHEN kiq022 = 1 THEN 1 ELSE 0 END) AS patients_with_kidney_disease,
    
    -- Associated symptoms for dialysis patients
    SUM(CASE WHEN kiq025 = 1 AND kiq005 IN (1,2,3) THEN 1 ELSE 0 END) AS dialysis_patients_with_urinary_issues,
    
    -- Treatment timing analysis
    MIN(mimi_src_file_date) AS earliest_data_date,
    MAX(mimi_src_file_date) AS latest_data_date

FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions

-- Only include valid responses
WHERE kiq025 IS NOT NULL 
  AND seqn IS NOT NULL;

-- How this query works:
-- 1. Focuses on dialysis as a key treatment indicator
-- 2. Calculates prevalence rates for dialysis and related conditions
-- 3. Examines symptom patterns among dialysis patients
-- 4. Includes data quality metrics via date ranges

-- Assumptions and Limitations:
-- - Assumes kiq025=1 indicates current dialysis treatment
-- - Limited to patients with valid dialysis status responses
-- - Self-reported data may have recall bias
-- - Cross-sectional view only (no longitudinal tracking)

-- Possible Extensions:
-- 1. Add demographic breakdowns by age/gender
-- 2. Compare symptoms between dialysis and non-dialysis patients
-- 3. Analyze changes in dialysis rates over time
-- 4. Include quality of life indicators
-- 5. Add geographic analysis if location data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:25:55.438573
    - Additional Notes: Query provides a high-level overview of dialysis prevalence and associated symptoms in the NHANES dataset. Response codes (1,2,3) in the symptoms calculation correspond to different frequency levels of urinary issues. The date range calculation helps validate data coverage periods.
    
    */