
/* NNDSS Disease Surveillance Dashboard - Core Metrics
 *
 * Business Purpose:
 * This query analyzes the National Notifiable Diseases Surveillance System (NNDSS) data
 * to identify disease trends and potential outbreaks across reporting areas. It provides
 * key metrics that public health officials can use to:
 * - Monitor current disease activity
 * - Compare against historical patterns
 * - Identify areas with higher than normal case counts
 */

WITH current_metrics AS (
  -- Get the most recent reporting week's data
  SELECT MAX(current_mmwr_year) as latest_year,
         MAX(mmwr_week) as latest_week 
  FROM mimi_ws_1.cdc.nndss
),

disease_summary AS (
  SELECT 
    n.reporting_area,
    n.label as disease,
    n.current_week as latest_cases,
    n.previous_52_week_max as historical_max,
    n.cumulative_ytd_current_mmwr_year as ytd_cases,
    -- Calculate percent of historical maximum
    ROUND(100.0 * n.current_week / NULLIF(n.previous_52_week_max, 0), 1) as pct_of_max
  FROM mimi_ws_1.cdc.nndss n
  JOIN current_metrics cm 
    ON n.current_mmwr_year = cm.latest_year 
    AND n.mmwr_week = cm.latest_week
  WHERE 
    -- Filter out aggregate rows and non-standard areas
    n.reporting_area NOT IN ('TOTAL', 'UNITED STATES')
    AND n.current_week IS NOT NULL
)

SELECT 
  disease,
  reporting_area,
  latest_cases,
  historical_max,
  ytd_cases,
  pct_of_max,
  -- Flag areas with unusually high current cases
  CASE WHEN pct_of_max >= 80 THEN 'HIGH ACTIVITY'
       WHEN pct_of_max >= 50 THEN 'ELEVATED'
       ELSE 'NORMAL' END as activity_level
FROM disease_summary
WHERE latest_cases > 0  -- Only show diseases with current activity
ORDER BY 
  disease,
  latest_cases DESC,
  reporting_area;

/* How this query works:
 * 1. Identifies the most recent reporting period
 * 2. Calculates key metrics for each disease/area combination
 * 3. Flags areas with elevated or high disease activity
 * 4. Orders results to highlight areas of greatest concern
 *
 * Assumptions and Limitations:
 * - Relies on regular weekly reporting from all areas
 * - Historical maximum may not account for seasonal patterns
 * - Missing or NULL values may affect calculations
 * - Does not account for population size differences between areas
 *
 * Possible Extensions:
 * 1. Add population-adjusted rates using census data
 * 2. Include week-over-week and year-over-year change calculations
 * 3. Add seasonal baseline comparisons
 * 4. Create disease-specific thresholds for activity levels
 * 5. Add geographical clustering analysis
 * 6. Include moving averages to smooth reporting variations
 */
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:30:21.158069
    - Additional Notes: Query focuses on current disease activity levels relative to historical patterns. Best used for weekly monitoring dashboards and outbreak detection. Note that the 80% and 50% thresholds for activity levels are arbitrary and may need adjustment based on specific disease patterns and public health requirements.
    
    */