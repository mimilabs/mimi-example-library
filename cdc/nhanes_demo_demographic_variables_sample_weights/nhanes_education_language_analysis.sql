-- nhanes_education_literacy_barriers.sql

-- Business Purpose:
-- Analyze educational attainment and language barriers in healthcare survey participation
-- to identify potential literacy and communication challenges that could impact healthcare
-- access and outcomes. This information helps healthcare organizations develop targeted
-- health literacy programs and language services.

WITH participant_communication AS (
  -- Get base demographics and communication needs
  SELECT 
    sddsrvyr as survey_cycle,
    CASE 
      WHEN riagendr = 1 THEN 'Male'
      WHEN riagendr = 2 THEN 'Female'
      ELSE 'Other'
    END as gender,
    ridageyr as age,
    dmdeduc2 as education_level,
    sialang as interview_language,
    siaintrp as interpreter_needed,
    dmdcitzn as citizenship_status,
    COUNT(*) as participant_count
  FROM mimi_ws_1.cdc.nhanes_demo_demographic_variables_sample_weights
  WHERE ridageyr >= 25 -- Focus on adults who have likely completed education
  AND dmdeduc2 IS NOT NULL
  GROUP BY 1,2,3,4,5,6,7
)

SELECT
  survey_cycle,
  gender,
  -- Age grouping for analysis
  CASE 
    WHEN age < 45 THEN '25-44'
    WHEN age < 65 THEN '45-64'
    ELSE '65+'
  END as age_group,
  -- Simplify education levels
  CASE
    WHEN education_level <= 2 THEN 'Less than High School'
    WHEN education_level = 3 THEN 'High School/GED'
    WHEN education_level = 4 THEN 'Some College'
    WHEN education_level = 5 THEN 'College Graduate'
    ELSE 'Unknown'
  END as education_category,
  -- Language and interpretation needs
  interview_language,
  CASE 
    WHEN interpreter_needed = 1 THEN 'Yes'
    WHEN interpreter_needed = 2 THEN 'No'
    ELSE 'Unknown'
  END as interpreter_required,
  -- Citizenship as context
  CASE
    WHEN citizenship_status = 1 THEN 'Citizen'
    WHEN citizenship_status = 2 THEN 'Non-Citizen'
    ELSE 'Unknown'
  END as citizenship,
  SUM(participant_count) as total_participants,
  ROUND(100.0 * SUM(participant_count) / SUM(SUM(participant_count)) 
    OVER (PARTITION BY survey_cycle), 1) as percent_of_cycle
FROM participant_communication
GROUP BY 1,2,3,4,5,6,7
ORDER BY survey_cycle, education_category, age_group, gender;

-- Query Operation:
-- 1. Creates a CTE to handle base demographic and communication variables
-- 2. Applies adult age filter and removes null education records
-- 3. Groups and calculates distributions with relevant demographic breakdowns
-- 4. Provides percentage calculations relative to survey cycle

-- Assumptions and Limitations:
-- - Limited to participants 25+ years old to focus on completed education
-- - Excludes records with null education values
-- - Education categories simplified into 4 main groups
-- - Language/interpreter needs may be undercounted due to proxy responses
-- - Survey weights not applied (raw counts used)

-- Possible Extensions:
-- 1. Add temporal trends across survey cycles
-- 2. Include household composition analysis
-- 3. Incorporate income/poverty ratio correlation
-- 4. Add geographic analysis if available
-- 5. Apply survey weights for population-level estimates
-- 6. Cross-reference with health outcomes data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:07:38.379889
    - Additional Notes: Query focuses on education levels and language barriers in healthcare survey participation. Note that raw counts are used instead of survey weights, which may not accurately represent population-level estimates. Consider applying survey weights (wtmec2yr or wtint2yr) for more accurate population-level analysis.
    
    */