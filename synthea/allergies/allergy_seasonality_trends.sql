-- allergy_seasonality_patterns.sql
-- Business Purpose: 
-- Analyze seasonal patterns in allergy onset to help healthcare organizations:
-- 1. Optimize staffing levels during peak allergy seasons
-- 2. Plan inventory for allergy medications and treatments
-- 3. Develop proactive patient education and outreach programs
-- 4. Support capacity planning for allergy clinics

WITH monthly_allergies AS (
  -- Aggregate allergy occurrences by month
  SELECT 
    DATE_TRUNC('month', start) as allergy_month,
    description as allergy_type,
    COUNT(*) as new_cases,
    COUNT(DISTINCT patient) as unique_patients
  FROM mimi_ws_1.synthea.allergies
  WHERE start IS NOT NULL
  GROUP BY 1, 2
),

seasonal_summary AS (
  -- Calculate seasonal metrics
  SELECT 
    MONTH(allergy_month) as month_number,
    allergy_type,
    AVG(new_cases) as avg_monthly_cases,
    AVG(unique_patients) as avg_monthly_patients,
    MAX(new_cases) as peak_cases
  FROM monthly_allergies
  GROUP BY 1, 2
)

-- Generate final report with seasonal insights
SELECT 
  month_number,
  allergy_type,
  ROUND(avg_monthly_cases, 2) as avg_cases,
  ROUND(avg_monthly_patients, 2) as avg_patients,
  peak_cases,
  ROUND((avg_monthly_cases / SUM(avg_monthly_cases) OVER (PARTITION BY allergy_type)) * 100, 2) as pct_of_annual_cases
FROM seasonal_summary
WHERE allergy_type IN (
  -- Focus on top allergies by volume
  SELECT allergy_type 
  FROM seasonal_summary 
  GROUP BY 1 
  HAVING SUM(avg_monthly_cases) > 100
)
ORDER BY month_number, avg_monthly_cases DESC;

-- How this query works:
-- 1. First CTE aggregates allergies by month and type
-- 2. Second CTE calculates key seasonal metrics
-- 3. Final SELECT adds percentage calculations and filters to most significant allergies
-- 4. Results show monthly patterns that can inform resource planning

-- Assumptions and Limitations:
-- - Assumes allergy start dates are accurately recorded
-- - Seasonal patterns may vary by geographic region (not captured in this analysis)
-- - Synthetic data may not perfectly reflect real-world seasonality
-- - Limited to analyzing new allergy cases, not ongoing conditions

-- Possible Extensions:
-- 1. Add geographic analysis if location data becomes available
-- 2. Compare patterns across different years to identify trends
-- 3. Correlate with environmental or weather data
-- 4. Add age group analysis to identify demographic patterns
-- 5. Include severity metrics if available in future data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:09:27.099413
    - Additional Notes: Query focuses on month-over-month patterns and may need performance optimization for very large datasets. Consider adding WHERE clause filters for specific date ranges if analyzing multiple years of data.
    
    */