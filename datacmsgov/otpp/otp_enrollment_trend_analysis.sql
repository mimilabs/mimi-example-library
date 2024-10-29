-- Provider Enrollment Trend Analysis for Opioid Treatment Programs
-- Business Purpose:
-- - Track the growth rate of OTP provider enrollment over time
-- - Identify seasonality or patterns in provider participation
-- - Support capacity planning and provider recruitment strategies
-- - Monitor program expansion effectiveness

WITH monthly_enrollments AS (
  SELECT 
    DATE_TRUNC('month', medicare_id_effective_date) AS enrollment_month,
    COUNT(DISTINCT npi) AS new_providers,
    COUNT(DISTINCT provider_name) AS unique_facilities
  FROM mimi_ws_1.datacmsgov.otpp
  WHERE medicare_id_effective_date IS NOT NULL
  GROUP BY DATE_TRUNC('month', medicare_id_effective_date)
),

rolling_metrics AS (
  SELECT
    enrollment_month,
    new_providers,
    unique_facilities,
    SUM(new_providers) OVER (ORDER BY enrollment_month) as cumulative_providers,
    ROUND(100.0 * new_providers / LAG(new_providers, 1) OVER (ORDER BY enrollment_month) - 100, 1) as mom_growth_rate
  FROM monthly_enrollments
)

SELECT
  enrollment_month,
  new_providers,
  cumulative_providers,
  unique_facilities,
  mom_growth_rate
FROM rolling_metrics
WHERE enrollment_month >= '2020-01-01'  -- Adjust date range as needed
ORDER BY enrollment_month DESC;

-- How this query works:
-- 1. First CTE aggregates provider enrollments by month
-- 2. Second CTE calculates running totals and month-over-month growth
-- 3. Final select filters recent years and presents key metrics

-- Assumptions & Limitations:
-- - Assumes medicare_id_effective_date represents initial enrollment
-- - Does not account for providers who may have left the program
-- - Growth rates may be volatile in early months with small numbers

-- Possible Extensions:
-- 1. Add year-over-year growth comparisons
-- 2. Include provider retention analysis
-- 3. Segment growth by state/region
-- 4. Add forecasting of future enrollment trends
-- 5. Compare against substance abuse prevalence data/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:06:15.558092
    - Additional Notes: Query focuses on temporal analysis of provider enrollment patterns. Monthly aggregation may mask daily/weekly variation. Consider adjusting the date filter (2020-01-01) based on actual data availability and business needs. Growth rate calculations may need special handling for months with zero previous enrollments.
    
    */