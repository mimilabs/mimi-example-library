-- nhanes_socioeconomic_health_disparities.sql

-- Business Purpose:
-- Analyze socioeconomic disparities in health examination participation rates by combining
-- poverty-income ratios with demographic factors. This helps identify potential access barriers
-- and participation gaps across different socioeconomic groups, supporting health equity initiatives
-- and targeted outreach strategies.

WITH population_segments AS (
  -- Create income level categories and calculate participation metrics
  SELECT 
    CASE 
      WHEN indfmpir < 1.0 THEN 'Below Poverty Line'
      WHEN indfmpir BETWEEN 1.0 AND 2.0 THEN 'Near Poverty'
      WHEN indfmpir > 2.0 THEN 'Above Poverty Line'
      ELSE 'Income Not Reported'
    END AS income_category,
    ridexmon AS exam_period,
    ridstatr AS participation_status,
    dmdeduc2 AS education_level,
    COUNT(*) as segment_count,
    AVG(wtmec2yr) as avg_exam_weight,
    COUNT(CASE WHEN ridstatr = 2 THEN 1 END) as completed_exams
  FROM mimi_ws_1.cdc.nhanes_demo_demographic_variables_sample_weights
  GROUP BY 1, 2, 3, 4
),

participation_metrics AS (
  -- Calculate participation rates and weighting factors
  SELECT 
    income_category,
    exam_period,
    education_level,
    SUM(segment_count) as total_participants,
    SUM(completed_exams) as total_completed_exams,
    AVG(avg_exam_weight) as avg_weight,
    ROUND(SUM(completed_exams) * 100.0 / SUM(segment_count), 2) as completion_rate
  FROM population_segments
  GROUP BY 1, 2, 3
)

-- Final output combining key metrics
SELECT 
  income_category,
  exam_period,
  education_level,
  total_participants,
  total_completed_exams,
  completion_rate,
  RANK() OVER (PARTITION BY exam_period ORDER BY completion_rate DESC) as completion_rank
FROM participation_metrics
WHERE income_category != 'Income Not Reported'
ORDER BY exam_period, completion_rank;

-- How the Query Works:
-- 1. Creates income categories based on poverty-income ratio (indfmpir)
-- 2. Segments population by income, examination period, and education
-- 3. Calculates participation rates and weights for each segment
-- 4. Ranks segments by completion rates within each examination period

-- Assumptions and Limitations:
-- - Assumes income reporting is accurate and complete
-- - Does not account for geographic variations
-- - Simplified education categories may mask important distinctions
-- - Weights are averaged which may affect statistical precision

-- Possible Extensions:
-- 1. Add geographic analysis using sdmvstra
-- 2. Include language and interpreter needs (sialang, siaintrp)
-- 3. Analyze temporal trends across multiple survey cycles
-- 4. Incorporate healthcare access indicators
-- 5. Add demographic intersectionality analysis (race, gender, age)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:05:46.232915
    - Additional Notes: Query focuses on examination completion rates across income levels and requires non-null poverty-income ratio (indfmpir) values for meaningful results. The ranking system assumes equal importance of all examination periods which may need adjustment based on specific analysis needs.
    
    */