
/*******************************************************************************
NHANES Demographic Analysis - Population Health Overview
*******************************************************************************/

/*******************************************************************************
Business Purpose:
This query analyzes key demographic characteristics of NHANES survey participants
to understand the population health sample composition and representation.
The insights support:
- Population health assessment and monitoring
- Health disparities research
- Survey methodology evaluation
*******************************************************************************/

-- Main analysis query
WITH participant_stats AS (
  -- Get core demographic distributions
  SELECT 
    -- Age groups
    CASE 
      WHEN ridageyr < 18 THEN 'Under 18'
      WHEN ridageyr BETWEEN 18 AND 44 THEN '18-44'
      WHEN ridageyr BETWEEN 45 AND 64 THEN '45-64'
      ELSE '65 and over'
    END AS age_group,
    
    -- Gender 
    CASE riagendr
      WHEN 1 THEN 'Male'
      WHEN 2 THEN 'Female'
    END AS gender,
    
    -- Race/Ethnicity
    CASE ridreth1
      WHEN 1 THEN 'Mexican American'
      WHEN 2 THEN 'Other Hispanic' 
      WHEN 3 THEN 'Non-Hispanic White'
      WHEN 4 THEN 'Non-Hispanic Black'
      WHEN 5 THEN 'Other Race'
    END AS race_ethnicity,
    
    -- Count participants
    COUNT(*) as participant_count,
    
    -- Calculate average weights
    AVG(wtmec2yr) as avg_exam_weight,
    AVG(wtint2yr) as avg_interview_weight,
    
    -- Income metrics
    AVG(indfmpir) as avg_poverty_ratio
    
  FROM mimi_ws_1.cdc.nhanes_demo_demographic_variables_sample_weights
  WHERE ridstatr = 2  -- Include only participants with both interview and exam
  GROUP BY 1,2,3
)

-- Generate final summary 
SELECT
  age_group,
  gender, 
  race_ethnicity,
  participant_count,
  ROUND(avg_exam_weight,2) as avg_exam_weight,
  ROUND(avg_interview_weight,2) as avg_interview_weight,
  ROUND(avg_poverty_ratio,2) as avg_poverty_ratio
FROM participant_stats
ORDER BY age_group, gender, race_ethnicity;

/*******************************************************************************
How this query works:
1. Filters for complete participants (interview + exam)
2. Groups participants into key demographic segments
3. Calculates weighted statistics for each segment
4. Presents results in an analysis-ready format

Assumptions and Limitations:
- Uses only complete participants (ridstatr = 2)
- Simplified race/ethnicity categories
- Assumes weights are properly calibrated
- No time trend analysis

Possible Extensions:
1. Add temporal analysis by sddsrvyr (survey cycle)
2. Include education level analysis
3. Add geographic analysis using masked geography variables
4. Calculate age-adjusted rates
5. Compare interviewed-only vs examined participants
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:53:13.697068
    - Additional Notes: Query uses sample weights (wtmec2yr, wtint2yr) which are critical for nationally representative estimates. Results should be interpreted considering the complex survey design. For trend analysis across multiple survey cycles, weights may need to be adjusted according to NHANES analytical guidelines.
    
    */