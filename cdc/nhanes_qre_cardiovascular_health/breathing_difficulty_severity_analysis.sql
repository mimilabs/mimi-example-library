-- Shortness of Breath Impact Analysis
-- --------------------------------------------------------------------------
-- Business Purpose: 
-- This query analyzes patterns of shortness of breath among survey respondents
-- to identify severity levels and potential correlations with daily activities.
-- This information helps healthcare providers better understand population health
-- risks and design targeted intervention programs.

WITH breath_severity AS (
  -- Classify respondents by severity of shortness of breath symptoms
  SELECT 
    seqn,
    CASE 
      WHEN cdq010 = 1 THEN 'Mild' -- Shortness of breath when hurrying/uphill
      WHEN cdq020 = 1 THEN 'Moderate' -- SOB when walking at normal pace
      WHEN cdq030 = 1 OR cdq040 = 1 THEN 'Severe' -- Must stop while walking
      ELSE 'No SOB reported'
    END as breath_severity,
    -- Check for nighttime breathing issues
    CASE WHEN cdq050 = 1 OR cdq070 = 1 THEN 1 ELSE 0 END as has_night_symptoms
FROM mimi_ws_1.cdc.nhanes_qre_cardiovascular_health
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.cdc.nhanes_qre_cardiovascular_health)
)

SELECT 
  breath_severity,
  COUNT(*) as patient_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage,
  SUM(has_night_symptoms) as night_symptoms_count,
  ROUND(SUM(has_night_symptoms) * 100.0 / COUNT(*), 1) as pct_with_night_symptoms
FROM breath_severity
GROUP BY breath_severity
ORDER BY 
  CASE breath_severity
    WHEN 'No SOB reported' THEN 1
    WHEN 'Mild' THEN 2
    WHEN 'Moderate' THEN 3
    WHEN 'Severe' THEN 4
  END;

-- How this query works:
-- 1. Creates a CTE that classifies patients into severity groups based on their
--    reported symptoms and identifies those with nighttime breathing issues
-- 2. Aggregates the data to show distribution of severity levels and the 
--    prevalence of nighttime symptoms within each group
-- 3. Uses the most recent survey data based on mimi_src_file_date

-- Assumptions and limitations:
-- - Assumes survey responses are accurate and complete
-- - Severity classification is simplified into 4 categories
-- - Does not account for potential seasonal variations
-- - Limited to most recent survey period only

-- Possible extensions:
-- 1. Add demographic breakdowns (would need to join with demographics table)
-- 2. Compare results across different survey periods
-- 3. Analyze correlation with other cardiovascular symptoms
-- 4. Include analysis of associated risk factors like swelling (cdq080)
-- 5. Create risk scores based on combination of symptoms

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:57:30.563905
    - Additional Notes: The query provides a stratified analysis of breathing difficulties with an emphasis on nighttime symptoms. Note that the severity classification is a simplified model and may need adjustment based on specific clinical guidelines. The analysis requires complete survey responses for accurate categorization.
    
    */