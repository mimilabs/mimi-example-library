-- intergenerational_language_transmission.sql --

-- Business Purpose:
-- This analysis examines language patterns across generations to help healthcare organizations:
-- 1. Understand language transmission within families
-- 2. Predict future language support needs
-- 3. Design targeted outreach programs for multi-generational households
-- 4. Develop culturally appropriate family-centered care strategies

WITH language_combinations AS (
  -- Identify unique combinations of childhood and current home languages
  SELECT 
    acq030 as childhood_language,
    acd040 as current_home_language,
    COUNT(*) as respondent_count
  FROM mimi_ws_1.cdc.nhanes_qre_acculturation
  WHERE acq030 IS NOT NULL 
    AND acd040 IS NOT NULL
  GROUP BY acq030, acd040
),

language_shifts AS (
  -- Calculate language shift patterns
  SELECT 
    childhood_language,
    current_home_language,
    respondent_count,
    ROUND(100.0 * respondent_count / SUM(respondent_count) OVER 
      (PARTITION BY childhood_language), 1) as pct_of_childhood_speakers
  FROM language_combinations
)

-- Final result showing language transition patterns
SELECT 
  childhood_language,
  current_home_language,
  respondent_count,
  pct_of_childhood_speakers,
  CASE 
    WHEN childhood_language = current_home_language THEN 'Language Maintained'
    WHEN childhood_language != current_home_language THEN 'Language Shifted'
  END as language_pattern
FROM language_shifts
WHERE respondent_count >= 10 -- Focus on significant patterns
ORDER BY 
  respondent_count DESC,
  childhood_language,
  pct_of_childhood_speakers DESC;

-- How this query works:
-- 1. Creates a CTE to identify unique combinations of childhood and current home languages
-- 2. Calculates the percentage distribution of current language usage for each childhood language
-- 3. Categorizes patterns as either maintained or shifted
-- 4. Filters for statistically significant patterns (n>=10)

-- Assumptions and Limitations:
-- 1. Assumes reported languages are accurate and consistent
-- 2. Does not account for multilingual households where multiple languages are used equally
-- 3. Limited to direct comparisons between childhood and current home language
-- 4. May not capture seasonal or situational language usage patterns

-- Possible Extensions:
-- 1. Add demographic factors (age, gender, education) to understand language shift drivers
-- 2. Include geographic analysis to identify regional patterns
-- 3. Incorporate parent birthplace data to analyze immigration generation effects
-- 4. Compare language shifts with health outcomes or healthcare utilization patterns
-- 5. Analyze language stability across different time periods using mimi_src_file_date

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:22:50.033344
    - Additional Notes: Query focuses on tracking generational changes in language use by comparing childhood vs current home language patterns. Filter threshold of 10 respondents may need adjustment based on sample size. Consider adding confidence intervals for percentage calculations in future iterations.
    
    */