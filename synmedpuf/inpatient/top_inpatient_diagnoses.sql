-- medicare_inpatient_diagnoses_patterns.sql

-- Business Purpose:
-- This query analyzes the patterns and distribution of primary diagnoses in Medicare inpatient claims
-- to understand the main causes of hospitalizations. The insights help:
-- 1. Understand disease burden and population health needs
-- 2. Support resource allocation and care management programs
-- 3. Identify opportunities for preventive interventions
-- 4. Guide clinical program development

WITH ranked_diagnoses AS (
  -- Get primary diagnoses and calculate metrics
  SELECT 
    prncpal_dgns_cd as diagnosis_code,
    COUNT(*) as admission_count,
    COUNT(DISTINCT bene_id) as unique_patients,
    AVG(clm_pmt_amt) as avg_payment,
    SUM(clm_pmt_amt) as total_payments,
    AVG(clm_utlztn_day_cnt) as avg_length_of_stay
  FROM mimi_ws_1.synmedpuf.inpatient
  WHERE prncpal_dgns_cd IS NOT NULL
  GROUP BY prncpal_dgns_cd

  -- Rank diagnoses by frequency
  QUALIFY ROW_NUMBER() OVER (
    ORDER BY admission_count DESC
  ) <= 20
)

-- Final output with key metrics
SELECT
  diagnosis_code,
  admission_count,
  unique_patients,
  ROUND(avg_payment, 2) as avg_payment,
  ROUND(total_payments, 2) as total_payments,
  ROUND(avg_length_of_stay, 1) as avg_length_of_stay,
  ROUND(100.0 * admission_count / SUM(admission_count) OVER (), 2) as pct_of_total_admissions
FROM ranked_diagnoses
ORDER BY admission_count DESC;

-- How it works:
-- 1. Groups claims by primary diagnosis code
-- 2. Calculates key metrics like admission counts, unique patients, and costs
-- 3. Ranks diagnoses by frequency and takes top 20
-- 4. Formats final output with rounded numbers and percentage calculations

-- Assumptions and limitations:
-- 1. Uses principal diagnosis only, not secondary diagnoses
-- 2. Assumes diagnosis codes are properly coded and validated
-- 3. Limited to top 20 diagnoses for focused analysis
-- 4. Does not account for seasonal variations
-- 5. Does not include clinical descriptions of diagnosis codes

-- Possible extensions:
-- 1. Add diagnosis code descriptions through a lookup table
-- 2. Break down by patient demographics (age, gender)
-- 3. Analyze temporal trends by admission date
-- 4. Compare metrics across geographic regions
-- 5. Include readmission rates for each diagnosis
-- 6. Add severity or risk adjustment metrics
-- 7. Compare against national benchmarks
-- 8. Break out emergency vs. elective admissions
-- 9. Analyze variation by hospital characteristics
-- 10. Include quality metrics by diagnosis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:35:27.916808
    - Additional Notes: Query provides a high-level view of inpatient hospitalization patterns by primary diagnosis, focusing on volume, cost, and length of stay metrics. Note that diagnosis code descriptions would need to be added through a separate lookup table for better interpretability of results.
    
    */