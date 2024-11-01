-- Title: Early Tobacco Use Patterns and Age of Initiation Analysis

-- Business Purpose:
-- - Analyze the age distribution of first cigarette use to identify critical intervention windows
-- - Examine relationship between early initiation and current smoking intensity
-- - Support youth prevention program targeting and resource allocation
-- - Inform public health policy around youth tobacco access restrictions

WITH smoker_data AS (
  -- Get valid smoking behavior data
  SELECT 
    smd630 as age_first_cigarette,
    smq640 as days_smoked_last_30,
    smq650 as cigarettes_per_day
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_adult_recent_tobacco_use_youth_cigarettetobacco_use
  WHERE smd630 > 0  -- Filter valid age responses
    AND smd630 < 100  -- Remove outliers
    AND smq620 = 1  -- Has tried smoking
),

age_group_analysis AS (
  -- Segment data into age groups and calculate metrics
  SELECT
    CASE 
      WHEN age_first_cigarette < 13 THEN 'Under 13'
      WHEN age_first_cigarette BETWEEN 13 AND 15 THEN '13-15'
      WHEN age_first_cigarette BETWEEN 16 AND 18 THEN '16-18'
      ELSE 'Over 18'
    END as initiation_age_group,
    COUNT(*) as group_size,
    AVG(CAST(days_smoked_last_30 AS DOUBLE)) as avg_days_smoking,
    AVG(CAST(cigarettes_per_day AS DOUBLE)) as avg_cigarettes_daily
  FROM smoker_data
  GROUP BY 
    CASE 
      WHEN age_first_cigarette < 13 THEN 'Under 13'
      WHEN age_first_cigarette BETWEEN 13 AND 15 THEN '13-15'
      WHEN age_first_cigarette BETWEEN 16 AND 18 THEN '16-18'
      ELSE 'Over 18'
    END
)

SELECT 
  initiation_age_group,
  ROUND(group_size) as respondents,
  ROUND(group_size * 100.0 / SUM(group_size) OVER(), 1) as pct_of_smokers,
  ROUND(avg_days_smoking, 1) as avg_days_smoking_per_month,
  ROUND(avg_cigarettes_daily, 1) as avg_cigarettes_per_day
FROM age_group_analysis
ORDER BY 
  CASE initiation_age_group
    WHEN 'Under 13' THEN 1
    WHEN '13-15' THEN 2
    WHEN '16-18' THEN 3
    ELSE 4
  END;

-- How this query works:
-- 1. First CTE (smoker_data) filters and prepares the base dataset
-- 2. Second CTE (age_group_analysis) segments data and calculates group-level metrics
-- 3. Final SELECT adds percentage calculations and formats output
-- 4. Results ordered by age group for logical presentation

-- Assumptions and Limitations:
-- - Assumes self-reported age of first cigarette use is reliable
-- - Limited to respondents with valid age responses
-- - Current smoking behavior may be influenced by factors beyond age of initiation
-- - Survey data may have inherent sampling biases

-- Possible Extensions:
-- 1. Add demographic breakdowns (gender, ethnicity, education level)
-- 2. Include cessation attempt analysis by age of initiation
-- 3. Incorporate brand preference analysis
-- 4. Add time series analysis to track changes in initiation age over survey years
-- 5. Include geographic analysis if location data available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:26:08.206483
    - Additional Notes: Query focuses on age-based patterns of smoking initiation and subsequent usage intensity. Note that the CAST operations on numerical fields are included to handle potential null values in the source data. Best used for longitudinal public health studies and youth prevention program planning.
    
    */