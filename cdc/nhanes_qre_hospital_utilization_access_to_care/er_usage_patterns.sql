-- er_utilization_analysis.sql

-- Business Purpose:
-- Analyzes emergency room utilization patterns from NHANES data to identify:
-- - Proportion of respondents using ER as primary care location
-- - Relationship between having a usual care location and ER usage
-- - Helps healthcare organizations optimize resource allocation and reduce avoidable ER visits

WITH usual_care_locations AS (
  SELECT 
    -- Categorize primary care locations
    CASE 
      WHEN huq04_ = 3 THEN 'Emergency Room'
      WHEN huq04_ IN (1,2) THEN 'Clinic/Doctor Office'
      WHEN huq04_ = 4 THEN 'Other Location'
      ELSE 'No Regular Location'
    END AS care_location,
    
    -- Include recent hospital stays as potential ER indicator
    huq07_ AS had_hospital_stay,
    
    -- General health status
    huq010 AS health_status,
    
    -- Count respondents
    COUNT(*) as patient_count,
    
    -- Calculate percentages
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
    
  FROM mimi_ws_1.cdc.nhanes_qre_hospital_utilization_access_to_care
  WHERE huq04_ IS NOT NULL
  GROUP BY care_location, huq07_, huq010
)

SELECT
  care_location,
  health_status,
  had_hospital_stay,
  patient_count,
  percentage,
  -- Running total to show cumulative distribution
  SUM(percentage) OVER (ORDER BY percentage DESC) as cumulative_pct
FROM usual_care_locations
ORDER BY care_location, percentage DESC;

-- How this query works:
-- 1. Creates a CTE to categorize care locations and calculate base metrics
-- 2. Groups results by location type, health status, and hospital stays
-- 3. Calculates percentages and running totals
-- 4. Orders results to highlight most common patterns

-- Assumptions & Limitations:
-- - Assumes huq04_ codes are consistent across survey years
-- - Does not account for seasonal variations in ER usage
-- - Missing values are excluded from analysis
-- - Self-reported data may have recall bias

-- Possible Extensions:
-- 1. Add geographic analysis if location data available
-- 2. Compare ER usage across different demographic groups
-- 3. Analyze trends over time using mimi_src_file_date
-- 4. Cross-reference with insurance status if available
-- 5. Add cost analysis metrics if payment data exists

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:58:17.838530
    - Additional Notes: Query focuses on emergency room utilization patterns and could benefit from additional filtering on mimi_src_file_date to analyze specific time periods. Consider adding WHERE clause conditions to exclude outlier cases where hospital stays might skew ER usage patterns.
    
    */