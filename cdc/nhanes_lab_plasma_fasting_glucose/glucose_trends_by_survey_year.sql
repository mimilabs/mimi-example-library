/*****************************************************************************
Title: NHANES Longitudinal Glucose Monitoring Trends Analysis

Business Purpose:
- Track changes in population-level fasting glucose over time using CDC NHANES data
- Identify potential shifts in diabetes risk patterns across survey cycles
- Support public health planning and intervention targeting
- Enable year-over-year comparison of metabolic health indicators

Created: 2024-02-12
******************************************************************************/

WITH yearly_stats AS (
  -- Calculate key glucose statistics by source file year
  SELECT 
    YEAR(mimi_src_file_date) as survey_year,
    COUNT(DISTINCT seqn) as sample_size,
    ROUND(AVG(lbxglu), 1) as avg_glucose_mgdl,
    ROUND(STDDEV(lbxglu), 2) as glucose_std_dev,
    ROUND(PERCENTILE(lbxglu, 0.5), 1) as median_glucose,
    COUNT(CASE WHEN lbxglu >= 126 THEN 1 END) as high_risk_count
  FROM mimi_ws_1.cdc.nhanes_lab_plasma_fasting_glucose
  WHERE lbxglu IS NOT NULL 
    AND mimi_src_file_date IS NOT NULL
  GROUP BY YEAR(mimi_src_file_date)
),

year_over_year AS (
  -- Calculate year-over-year changes
  SELECT 
    survey_year,
    avg_glucose_mgdl,
    LAG(avg_glucose_mgdl) OVER (ORDER BY survey_year) as prev_year_avg,
    ROUND(avg_glucose_mgdl - LAG(avg_glucose_mgdl) OVER (ORDER BY survey_year), 1) as yoy_change,
    sample_size,
    high_risk_count,
    ROUND(100.0 * high_risk_count / sample_size, 1) as high_risk_percentage
  FROM yearly_stats
)

SELECT 
  survey_year,
  sample_size,
  avg_glucose_mgdl,
  yoy_change,
  high_risk_percentage,
  CASE 
    WHEN yoy_change > 0 THEN 'Increasing'
    WHEN yoy_change < 0 THEN 'Decreasing'
    ELSE 'Stable'
  END as trend_direction
FROM year_over_year
ORDER BY survey_year;

/*****************************************************************************
How it works:
1. First CTE aggregates key glucose statistics by survey year
2. Second CTE calculates year-over-year changes and risk percentages
3. Final query formats results with trend indicators

Assumptions and Limitations:
- Assumes mimi_src_file_date reflects actual survey year
- Does not account for sampling weights
- High risk defined as fasting glucose >= 126 mg/dL
- Simple trend analysis may not capture seasonal variations
- Does not adjust for demographic factors

Possible Extensions:
1. Add demographic stratification (age groups, gender, ethnicity)
2. Incorporate sampling weights for population-level estimates
3. Include confidence intervals for trend analysis
4. Add seasonal adjustment factors
5. Compare against national diabetes prevalence data
*****************************************************************************/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:15:32.452334
    - Additional Notes: The query analyzes temporal patterns in NHANES glucose data, calculating annual averages and risk percentages. Note that the trend analysis relies on mimi_src_file_date for temporal grouping, which may need validation against actual survey cycles. The high-risk threshold of 126 mg/dL follows standard clinical guidelines but should be reviewed with healthcare professionals for specific applications.
    
    */