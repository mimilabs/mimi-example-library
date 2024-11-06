-- Title: Daily Active Diagnoses Volume Forecasting
--
-- Business Purpose:
-- - Monitor and forecast daily patient volume by condition to optimize staffing
-- - Enable proactive capacity planning for clinical services
-- - Support operational decision making for resource allocation
-- - Track diagnosis patterns to identify potential outbreaks or unusual spikes

WITH daily_volumes AS (
  -- Get active conditions for each day
  SELECT 
    DATE_TRUNC('day', start) as service_date,
    description as condition_name,
    COUNT(DISTINCT patient) as daily_patient_count
  FROM mimi_ws_1.synthea.conditions
  WHERE start IS NOT NULL
    -- Only include conditions that are either ongoing (no stop date) 
    -- or were active within the last 2 years
    AND (stop IS NULL OR stop >= DATEADD(year, -2, CURRENT_DATE))
  GROUP BY 1, 2
),

summary_stats AS (
  -- Calculate volume statistics per condition
  SELECT
    condition_name,
    AVG(daily_patient_count) as avg_daily_patients,
    MAX(daily_patient_count) as peak_daily_patients,
    MIN(daily_patient_count) as min_daily_patients,
    STDDEV(daily_patient_count) as std_dev_patients
  FROM daily_volumes
  GROUP BY 1
)

-- Final output with volume patterns and variability
SELECT 
  condition_name,
  ROUND(avg_daily_patients, 1) as avg_daily_patients,
  peak_daily_patients,
  min_daily_patients,
  ROUND(std_dev_patients, 2) as daily_volume_variability,
  ROUND((std_dev_patients / avg_daily_patients) * 100, 1) as coefficient_of_variation
FROM summary_stats
WHERE avg_daily_patients >= 1  -- Focus on conditions with meaningful volume
ORDER BY avg_daily_patients DESC
LIMIT 20;

-- How this query works:
-- 1. Creates daily patient counts for each condition from the raw data
-- 2. Calculates summary statistics including average, peak, and variability metrics
-- 3. Returns top conditions by volume with their operational patterns

-- Assumptions and limitations:
-- - Assumes start dates are reliable indicators of when care is needed
-- - Limited to 2-year lookback period for active conditions
-- - Does not account for severity or resource intensity of conditions
-- - Synthetic data may not perfectly reflect real-world patterns

-- Possible extensions:
-- 1. Add weekly/monthly trending analysis
-- 2. Include demographic breakdowns
-- 3. Add year-over-year growth calculations
-- 4. Incorporate geographic clustering
-- 5. Connect to staffing ratio requirements
-- 6. Add predictive forecasting components

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:36:31.434368
    - Additional Notes: Query's daily volume calculations may be computationally intensive for large datasets with long date ranges. Consider partitioning by date ranges or adding WHERE clauses to limit the time period for better performance.
    
    */