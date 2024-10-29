-- nursing_home_staffing_efficiency_analysis.sql
-- Business Purpose: 
-- Analyze staffing efficiency and turnover patterns across nursing home affiliated entities
-- to identify best practices and opportunities for operational improvements.
-- This helps healthcare organizations optimize workforce management and reduce costs
-- while maintaining quality of care.

WITH StaffingMetrics AS (
  -- Calculate key staffing efficiency metrics by affiliated entity
  SELECT 
    affiliated_entity,
    number_of_facilities,
    number_of_states_and_territories_with_operations,
    average_total_nurse_hours_per_resident_day,
    average_total_nursing_staff_turnover_percentage,
    average_registered_nurse_turnover_percentage,
    average_number_of_administrators_who_have_left_the_nursing_home,
    average_staffing_rating,
    average_overall_5star_rating
  FROM mimi_ws_1.datacmsgov.nursinghome_ae_perf
  WHERE number_of_facilities >= 5  -- Focus on entities with meaningful scale
)

SELECT
  affiliated_entity,
  number_of_facilities,
  number_of_states_and_territories_with_operations,
  
  -- Staffing levels
  ROUND(average_total_nurse_hours_per_resident_day, 2) as nurse_hours_per_day,
  
  -- Turnover metrics
  ROUND(average_total_nursing_staff_turnover_percentage, 1) as nurse_turnover_pct,
  ROUND(average_registered_nurse_turnover_percentage, 1) as rn_turnover_pct,
  ROUND(average_number_of_administrators_who_have_left_the_nursing_home, 1) as admin_turnover,
  
  -- Quality indicators
  average_staffing_rating as staffing_stars,
  average_overall_5star_rating as overall_stars,
  
  -- Calculated efficiency metrics
  ROUND(average_total_nurse_hours_per_resident_day / 
    NULLIF(average_total_nursing_staff_turnover_percentage/100, 0), 2) 
    as hours_per_turnover_ratio
    
FROM StaffingMetrics
WHERE average_staffing_rating IS NOT NULL
ORDER BY hours_per_turnover_ratio DESC
LIMIT 100;

/* How it works:
- Filters for nursing home entities with 5+ facilities to ensure meaningful analysis
- Calculates a staffing efficiency ratio comparing hours provided vs turnover rate
- Higher ratio suggests more stable staffing despite high care hours
- Includes geographic spread and quality metrics for context

Assumptions & Limitations:
- Assumes facilities with 5+ locations provide more reliable aggregate metrics
- Does not account for regional staffing market variations
- Turnover percentages may be affected by reporting inconsistencies
- Does not factor in wage data or local cost of living

Possible Extensions:
1. Add year-over-year trend analysis when historical data available
2. Segment by facility ownership type (for-profit vs non-profit)
3. Incorporate COVID-19 impact analysis using vaccination rate correlations
4. Add financial metrics like fines to assess compliance cost impact
5. Compare staffing patterns between single-state and multi-state operators
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:42:39.344203
    - Additional Notes: The query provides a staffing efficiency index utilizing hours-to-turnover ratio as a key performance indicator. The 5+ facilities filter and 100 row limit may need adjustment based on specific analysis needs. Consider local market conditions when interpreting results.
    
    */