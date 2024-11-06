-- Title: NHANES Early Smoking Exposure and Regular Use Pattern Analysis

-- Business Purpose:
-- This query analyzes the relationship between early smoking exposure and development
-- of regular smoking habits to:
-- 1. Identify age patterns of first cigarette exposure vs. regular smoking initiation
-- 2. Calculate the transition time from first exposure to regular use
-- 3. Support early intervention program design by understanding critical age windows
-- 4. Inform youth smoking prevention strategies

WITH first_exposure AS (
  -- Get age of first cigarette exposure
  SELECT 
    seqn,
    smd630 as first_cigarette_age,
    smd030 as regular_smoking_age,
    CASE 
      WHEN smq040 = 1 THEN 'Current Every Day'
      WHEN smq040 = 2 THEN 'Current Some Days' 
      WHEN smq040 = 3 THEN 'Not At All'
      ELSE 'Unknown'
    END as current_smoking_status,
    smd650 as cigarettes_per_day
  FROM mimi_ws_1.cdc.nhanes_qre_smoking_cigarette_use
  WHERE smd630 IS NOT NULL 
    AND smd030 IS NOT NULL
),

smoking_patterns AS (
  -- Calculate key metrics about smoking progression
  SELECT
    current_smoking_status,
    COUNT(*) as smoker_count,
    ROUND(AVG(first_cigarette_age), 1) as avg_first_exposure_age,
    ROUND(AVG(regular_smoking_age), 1) as avg_regular_smoking_age,
    ROUND(AVG(regular_smoking_age - first_cigarette_age), 1) as avg_years_to_regular,
    ROUND(AVG(cigarettes_per_day), 1) as avg_cigarettes_per_day
  FROM first_exposure
  GROUP BY current_smoking_status
)

-- Final output with key smoking progression metrics
SELECT 
  current_smoking_status,
  smoker_count,
  avg_first_exposure_age,
  avg_regular_smoking_age,
  avg_years_to_regular,
  avg_cigarettes_per_day
FROM smoking_patterns
WHERE current_smoking_status != 'Unknown'
ORDER BY smoker_count DESC;

-- How It Works:
-- 1. First CTE gets individual-level data about first exposure and regular smoking
-- 2. Second CTE calculates aggregate patterns by current smoking status
-- 3. Final query presents the results in a clean, actionable format

-- Assumptions & Limitations:
-- 1. Relies on self-reported data which may have recall bias
-- 2. Missing data is excluded from calculations
-- 3. Does not account for potential confounding factors
-- 4. Cross-sectional nature limits causal inference

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender, etc.)
-- 2. Include quit attempt analysis for different exposure patterns
-- 3. Incorporate nicotine dependence measures
-- 4. Add trend analysis across survey years
-- 5. Include statistical tests for group differences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:14:31.791652
    - Additional Notes: Query specifically focuses on the progression timeline from first cigarette exposure to regular smoking habits. Most valuable for youth smoking prevention programs and understanding critical intervention windows. Performance may be impacted with large datasets due to multiple self-joins on the seqn column.
    
    */