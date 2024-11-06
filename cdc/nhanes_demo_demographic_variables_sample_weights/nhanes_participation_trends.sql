-- nhanes_survey_participation_trends.sql

-- Business Purpose:
-- Analyze NHANES survey participation trends over time and data cycles to:
-- 1. Track participation rates and potential selection bias
-- 2. Evaluate completion rates for both interviews and medical exams
-- 3. Identify demographic groups with lower participation
-- 4. Support survey methodology improvements and resource allocation

WITH participation_metrics AS (
  -- Calculate participation metrics by data cycle
  SELECT 
    sddsrvyr as data_cycle,
    COUNT(*) as total_participants,
    
    -- Interview completion rates
    COUNT(CASE WHEN ridstatr = 1 THEN 1 END) as interview_complete,
    COUNT(CASE WHEN ridstatr = 2 THEN 1 END) as interview_and_exam_complete,
    
    -- Gender distribution
    COUNT(CASE WHEN riagendr = 1 THEN 1 END) as male_count,
    COUNT(CASE WHEN riagendr = 2 THEN 1 END) as female_count,
    
    -- Age group distribution  
    COUNT(CASE WHEN ridageyr < 18 THEN 1 END) as under_18,
    COUNT(CASE WHEN ridageyr BETWEEN 18 AND 64 THEN 1 END) as adults_18_64,
    COUNT(CASE WHEN ridageyr >= 65 THEN 1 END) as seniors_65_plus,
    
    -- Average weights
    AVG(wtintprp) as avg_interview_weight,
    AVG(wtmecprp) as avg_exam_weight
  FROM mimi_ws_1.cdc.nhanes_demo_demographic_variables_sample_weights
  GROUP BY sddsrvyr
)

SELECT
  data_cycle,
  total_participants,
  
  -- Calculate completion rates
  ROUND(100.0 * interview_complete / total_participants, 1) as interview_rate_pct,
  ROUND(100.0 * interview_and_exam_complete / total_participants, 1) as full_completion_rate_pct,
  
  -- Calculate gender distribution
  ROUND(100.0 * male_count / total_participants, 1) as male_pct,
  ROUND(100.0 * female_count / total_participants, 1) as female_pct,
  
  -- Calculate age distribution
  ROUND(100.0 * under_18 / total_participants, 1) as under_18_pct,
  ROUND(100.0 * adults_18_64 / total_participants, 1) as adults_pct,
  ROUND(100.0 * seniors_65_plus / total_participants, 1) as seniors_pct,
  
  -- Weight metrics
  ROUND(avg_interview_weight, 2) as avg_interview_weight,
  ROUND(avg_exam_weight, 2) as avg_exam_weight
FROM participation_metrics
ORDER BY data_cycle;

-- How this query works:
-- 1. Creates a CTE to calculate raw participation counts and metrics by survey cycle
-- 2. Groups data by survey cycle (sddsrvyr) to track trends over time
-- 3. Calculates multiple participation metrics including completion rates and demographic distributions
-- 4. Includes sampling weight averages to assess representativeness

-- Assumptions and Limitations:
-- 1. Assumes ridstatr values of 1 and 2 indicate interview and exam completion
-- 2. Does not account for changes in survey methodology between cycles
-- 3. Demographic categories are simplified for overview purposes
-- 4. Weight calculations may need adjustment based on specific analysis needs

-- Possible Extensions:
-- 1. Add geographic analysis using masked variance units
-- 2. Include income and education level completion rates
-- 3. Analyze participation rates by language and interpreter use
-- 4. Compare urban vs rural participation patterns
-- 5. Add statistical significance testing between cycles

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:01:34.167419
    - Additional Notes: Query provides high-level participation metrics across survey cycles but may need weight adjustment factors for accurate population-level estimates. Consider adding confidence intervals for trend analysis and adjusting demographic categories based on specific research needs.
    
    */