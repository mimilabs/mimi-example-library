
/*******************************************************************
Title: Key Patient Vital Signs Analysis
 
Business Purpose:
- Monitor patient health trends through vital sign measurements
- Identify potential health risks based on abnormal vital signs
- Support preventive care by tracking vital sign patterns
 
Created: 2024-02
*******************************************************************/

-- Extract key vital signs and their distributions across patients
WITH vital_signs AS (
  -- Focus on common vital sign measurements 
  SELECT 
    description,
    value,
    units,
    -- Convert values to numeric for analysis
    CAST(REGEXP_REPLACE(value, '[^0-9.]', '') AS DOUBLE) AS numeric_value 
  FROM mimi_ws_1.synthea.observations
  WHERE 
    -- Filter for vital signs of interest
    description IN (
      'Body Mass Index',
      'Body Weight',
      'Blood Pressure',
      'Heart rate',
      'Respiratory rate'
    )
    -- Ensure valid numeric values
    AND value REGEXP '^[0-9.]+$'
)

SELECT
  description AS vital_sign,
  COUNT(*) AS measurement_count,
  -- Calculate distribution statistics
  ROUND(AVG(numeric_value), 2) AS avg_value,
  ROUND(MIN(numeric_value), 2) AS min_value,
  ROUND(MAX(numeric_value), 2) AS max_value,
  ROUND(PERCENTILE(numeric_value, 0.5), 2) AS median_value,
  units AS measurement_unit
FROM vital_signs
GROUP BY description, units
ORDER BY measurement_count DESC;

/*******************************************************************
How this query works:
1. Filters observations to focus on key vital signs
2. Cleanses and converts string values to numeric format
3. Calculates summary statistics for each vital sign
 
Assumptions & Limitations:
- Assumes vital sign values are stored in consistent format
- Limited to numeric measurements only
- Does not account for patient demographics or time trends
- Some vital signs may have multiple unit types
 
Possible Extensions:
1. Add trending over time analysis
2. Segment by patient demographics (age, gender)
3. Identify outliers and potential health risks
4. Compare against medical reference ranges
5. Add correlation analysis between different vital signs
*******************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:45:42.814145
    - Additional Notes: Query focuses on five key vital signs and provides their statistical distributions. Values outside numeric format are excluded from analysis. Consider implementing error handling for non-numeric values and adding data quality checks before using in production.
    
    */