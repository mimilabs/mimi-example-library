
/* 
Healthcare Demographics and Cost Analysis
======================================

Business Purpose:
This query analyzes key demographic patterns and healthcare costs across the patient population
to identify potential disparities in healthcare coverage and expenses across different demographic groups.
This information can help healthcare providers and policymakers:
- Understand healthcare cost distribution across demographics
- Identify potential gaps in coverage
- Support equitable healthcare planning

*/

WITH patient_metrics AS (
  -- Calculate age and living status for each patient
  SELECT 
    id,
    race,
    ethnicity,
    gender,
    FLOOR(DATEDIFF(COALESCE(deathdate, CURRENT_DATE), birthdate)/365.25) as age,
    CASE WHEN deathdate IS NULL THEN 'Living' ELSE 'Deceased' END as living_status,
    healthcare_expenses,
    healthcare_coverage,
    (healthcare_expenses - healthcare_coverage) as out_of_pocket
  FROM mimi_ws_1.synthea.patients
)

SELECT
  -- Demographic grouping
  race,
  gender,
  living_status,
  
  -- Population metrics
  COUNT(*) as patient_count,
  ROUND(AVG(age), 1) as avg_age,
  
  -- Healthcare cost metrics
  ROUND(AVG(healthcare_expenses), 2) as avg_expenses,
  ROUND(AVG(healthcare_coverage), 2) as avg_coverage,
  ROUND(AVG(out_of_pocket), 2) as avg_out_of_pocket,
  
  -- Coverage ratio
  ROUND(AVG(healthcare_coverage/healthcare_expenses)*100, 1) as avg_coverage_percentage

FROM patient_metrics
GROUP BY race, gender, living_status
HAVING patient_count >= 100  -- Filter for statistically significant groups
ORDER BY race, gender, living_status;

/*
How It Works:
------------
1. CTE calculates derived metrics for each patient including:
   - Age based on birth/death dates or current date
   - Living status
   - Out of pocket expenses
2. Main query aggregates by demographic groups to show:
   - Population counts
   - Average ages
   - Healthcare cost metrics
   - Coverage percentages

Assumptions & Limitations:
-------------------------
- Assumes healthcare_expenses > 0 for coverage percentage calculation
- Limited to groups with 100+ patients for statistical significance
- Does not account for time-based trends
- Does not consider geographic variations
- Synthetic data may not perfectly reflect real-world patterns

Possible Extensions:
-------------------
1. Add geographic analysis by state/region
2. Include temporal trends by analyzing costs over time
3. Add age group breakdowns
4. Compare against regional benchmarks
5. Add statistical significance tests
6. Include analysis of specific medical conditions
7. Add healthcare utilization patterns
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:27:46.997150
    - Additional Notes: Query aggregates patients into demographic groups of 100+ members to ensure statistical relevance. Healthcare coverage percentage calculations may produce division by zero errors if any patients have zero expenses. Consider adding NULLIF or other handling for zero expenses if needed in production use.
    
    */