
/*******************************************************************************
Title: Core Immunization Analysis - Patient Coverage and Costs
 
Business Purpose:
This query analyzes key immunization metrics to help healthcare organizations:
1. Track immunization coverage across their patient population 
2. Monitor immunization costs and financial impact
3. Identify trends in vaccine administration
*******************************************************************************/

-- Main analysis query
WITH immunization_stats AS (
  -- Get the total unique patients and average costs by vaccine type
  SELECT 
    description as vaccine_type,
    COUNT(DISTINCT patient) as total_patients,
    COUNT(*) as total_administrations,
    ROUND(AVG(base_cost), 2) as avg_cost,
    MIN(date) as first_administration,
    MAX(date) as last_administration
  FROM mimi_ws_1.synthea.immunizations
  GROUP BY description
)

SELECT
  vaccine_type,
  total_patients,
  total_administrations,
  avg_cost,
  -- Calculate administrations per patient
  ROUND(CAST(total_administrations AS FLOAT)/total_patients, 2) as administrations_per_patient,
  -- Calculate days between first and last administration
  DATEDIFF(day, first_administration, last_administration) as days_administered,
  first_administration,
  last_administration
FROM immunization_stats
ORDER BY total_patients DESC;

/*******************************************************************************
How This Query Works:
1. Creates a CTE to aggregate key metrics by vaccine type
2. Calculates derived metrics like administrations per patient
3. Orders results by total patients to show most common vaccines first

Assumptions & Limitations:
- Assumes each patient record is unique and valid
- Does not account for recommended schedules or age-appropriate dosing
- Cost analysis assumes base_cost is consistently recorded
- Time period is limited to available data range

Possible Extensions:
1. Add age group analysis:
   - Break down vaccination rates by patient age groups
   
2. Add temporal trends:
   - Show month-over-month or year-over-year changes in vaccination rates
   
3. Add geographical analysis:
   - If location data available, show regional vaccination patterns
   
4. Add compliance analysis:
   - Compare actual vs recommended vaccination schedules
   
5. Add cost trend analysis:
   - Show how vaccine costs change over time
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:48:57.802048
    - Additional Notes: The query provides high-level metrics for vaccine administration but might need index optimization for large datasets. Consider adding date filters when running against production data to improve performance. The administrations_per_patient metric assumes even distribution across the population and should be interpreted alongside clinical guidelines.
    
    */