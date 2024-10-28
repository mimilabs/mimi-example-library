
/*******************************************************************************
Title: Leading Causes of Death Analysis from NHANES Mortality Data

Business Purpose:
This query analyzes the distribution of leading causes of death in the NHANES
mortality dataset to identify the most common causes and their relative frequency.
This information is crucial for:
- Public health planning and resource allocation
- Understanding mortality patterns in the US population
- Identifying key areas for preventive healthcare interventions

Created: 2024-02
*******************************************************************************/

WITH cause_of_death_counts AS (
  -- Get counts and percentages for each leading cause of death
  SELECT 
    CASE ucod_leading
      WHEN '001' THEN 'Heart Disease'
      WHEN '002' THEN 'Cancer'
      WHEN '003' THEN 'Chronic Lower Respiratory Disease'
      WHEN '004' THEN 'Accidents'
      WHEN '005' THEN 'Cerebrovascular Disease'
      WHEN '006' THEN "Alzheimer's Disease"
      WHEN '007' THEN 'Diabetes'
      WHEN '008' THEN 'Influenza/Pneumonia'
      WHEN '009' THEN 'Kidney Disease'
      WHEN '010' THEN 'Other Causes'
    END AS cause_of_death,
    COUNT(*) as death_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as percentage
  FROM mimi_ws_1.cdc.nhanes_mortality
  WHERE 
    mortstat = 1  -- Only include deceased individuals
    AND ucod_leading IS NOT NULL  -- Exclude missing cause of death
    AND eligstat = 1  -- Only eligible participants
  GROUP BY ucod_leading
)

SELECT 
  cause_of_death,
  death_count,
  percentage,
  -- Create a simple bar chart using repeated characters
  REPEAT('█', CAST(percentage AS INT)) as distribution
FROM cause_of_death_counts
WHERE cause_of_death IS NOT NULL
ORDER BY death_count DESC;

/*******************************************************************************
How this query works:
1. Filters for deceased, eligible participants with known cause of death
2. Groups and counts deaths by leading cause
3. Calculates percentage distribution
4. Presents results with a text-based visualization

Assumptions & Limitations:
- Only includes eligible participants (eligstat = 1)
- Only includes confirmed deaths (mortstat = 1)
- Excludes records with missing cause of death
- Percentages are rounded to 1 decimal place

Possible Extensions:
1. Add time-based analysis by incorporating permth_int
2. Include demographic breakdowns
3. Analyze correlation with diabetes and hypertension flags
4. Compare causes of death across different NHANES survey periods
5. Add survival analysis using person-months of follow-up

For additional insights, consider joining with other NHANES tables containing:
- Demographic information
- Socioeconomic factors
- Clinical measurements
- Laboratory results
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:34:05.548046
    - Additional Notes: The query provides a basic frequency analysis with text-based visualization. Note that the REPEAT function used for visualization may not be supported in all SQL dialects, and the maximum visualization length is limited by the percentage value. For large-scale analysis, consider removing the visualization column or replacing it with a proper BI tool visualization.
    
    */