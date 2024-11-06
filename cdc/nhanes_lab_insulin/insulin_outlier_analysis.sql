-- nhanes_insulin_demographic_disparity.sql

-- Business Purpose:
-- - Identify potential disparities in insulin levels across demographic groups
-- - Support health equity initiatives and targeted intervention programs
-- - Guide resource allocation for diabetes prevention programs
-- - Provide evidence for population health management strategies

WITH insulin_quartiles AS (
  -- Calculate insulin quartiles for the entire population
  SELECT
    PERCENTILE(lbxin, 0.25) as q1,
    PERCENTILE(lbxin, 0.75) as q3
  FROM mimi_ws_1.cdc.nhanes_lab_insulin
  WHERE lbxin IS NOT NULL
),

flagged_records AS (
  -- Flag potentially concerning insulin values based on interquartile range
  SELECT 
    nli.*,
    iq.q1,
    iq.q3,
    (iq.q3 - iq.q1) * 1.5 as iqr_range,
    CASE 
      WHEN lbxin > iq.q3 + ((iq.q3 - iq.q1) * 1.5) THEN 'High'
      WHEN lbxin < iq.q1 - ((iq.q3 - iq.q1) * 1.5) THEN 'Low'
      ELSE 'Normal'
    END as insulin_status
  FROM mimi_ws_1.cdc.nhanes_lab_insulin nli
  CROSS JOIN insulin_quartiles iq
  WHERE lbxin IS NOT NULL
)

SELECT 
  EXTRACT(YEAR FROM mimi_src_file_date) as survey_year,
  insulin_status,
  COUNT(*) as participant_count,
  ROUND(AVG(lbxin), 2) as avg_insulin_level,
  ROUND(MIN(lbxin), 2) as min_insulin_level,
  ROUND(MAX(lbxin), 2) as max_insulin_level,
  ROUND(STDDEV(lbxin), 2) as std_dev_insulin
FROM flagged_records
GROUP BY 
  EXTRACT(YEAR FROM mimi_src_file_date),
  insulin_status
ORDER BY 
  survey_year,
  insulin_status;

-- How it works:
-- 1. Calculates population-wide insulin quartiles
-- 2. Flags records as High/Low/Normal based on 1.5 * IQR rule
-- 3. Aggregates results by year and insulin status
-- 4. Provides summary statistics for each group

-- Assumptions and Limitations:
-- - Assumes insulin values are normally distributed
-- - Does not account for demographic factors like age, gender, or ethnicity
-- - IQR-based flagging may need adjustment based on clinical guidelines
-- - Survey weights are not incorporated in this basic analysis

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender, ethnicity)
-- 2. Incorporate survey weights for more accurate population estimates
-- 3. Add geographic analysis if location data is available
-- 4. Compare results against clinical reference ranges
-- 5. Add trend analysis across multiple years
-- 6. Include correlation with other metabolic markers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:51:14.174315
    - Additional Notes: Query focuses on identifying statistical outliers in insulin measurements using IQR method, providing annual distribution patterns. Note that this implementation does not incorporate NHANES survey weights, which may affect population-level interpretations. Consider adding WTSAFPRP column for weighted analysis in production use.
    
    */