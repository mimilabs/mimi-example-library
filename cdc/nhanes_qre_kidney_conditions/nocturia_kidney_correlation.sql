-- nocturnal_urination_analysis.sql
--
-- Business Purpose: 
-- Analyze nighttime urination patterns to identify potential public health implications,
-- inform clinical screening guidelines, and understand population-level nocturia prevalence.
-- This information is valuable for:
-- - Healthcare providers developing screening protocols
-- - Public health officials planning education programs
-- - Medical device and pharmaceutical companies targeting treatment solutions

WITH nocturia_summary AS (
  -- Categorize and count nighttime urination frequencies
  SELECT 
    kiq480,
    CASE kiq480
      WHEN 1 THEN '0 times'
      WHEN 2 THEN '1 time'
      WHEN 3 THEN '2-3 times'
      WHEN 4 THEN '4-5 times'
      WHEN 5 THEN '6+ times'
      ELSE 'Not reported'
    END AS frequency_category,
    COUNT(*) as patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
  FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions
  WHERE kiq480 IS NOT NULL
  GROUP BY kiq480
),

kidney_correlation AS (
  -- Analyze relationship between nocturia and kidney conditions
  SELECT
    n.frequency_category,
    COUNT(CASE WHEN k.kiq022 = 1 THEN 1 END) as with_kidney_disease,
    COUNT(*) as total_patients,
    ROUND(COUNT(CASE WHEN k.kiq022 = 1 THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0), 1) as kidney_disease_pct
  FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions k
  JOIN nocturia_summary n ON k.kiq480 = n.kiq480
  WHERE k.kiq480 IS NOT NULL
  GROUP BY n.frequency_category
)

-- Combine results with kidney disease correlation
SELECT 
  ns.frequency_category,
  ns.patient_count,
  ns.percentage as population_percentage,
  kc.kidney_disease_pct as kidney_disease_percentage
FROM nocturia_summary ns
LEFT JOIN kidney_correlation kc ON ns.frequency_category = kc.frequency_category
ORDER BY ns.kiq480;

-- How it works:
-- 1. First CTE categorizes nighttime urination frequency and calculates population percentages
-- 2. Second CTE analyzes correlation with diagnosed kidney conditions
-- 3. Final query combines both analyses for a comprehensive view

-- Assumptions and Limitations:
-- - Relies on self-reported data which may have recall bias
-- - Missing values are excluded from percentage calculations
-- - Assumes survey responses are representative of the general population
-- - Does not account for confounding factors like age, medications, or other conditions

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender)
-- 2. Include analysis of impact on quality of life measures
-- 3. Correlate with other urological conditions in the dataset
-- 4. Add temporal analysis across survey cycles
-- 5. Include statistical significance testing for observed correlations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:24:25.662013
    - Additional Notes: Query focuses on analyzing the relationship between nighttime urination frequency and kidney disease presence. The percentage calculations exclude NULL values which may affect overall population estimates. Consider adding WHERE clauses to filter specific time periods if analyzing trends over multiple survey cycles.
    
    */