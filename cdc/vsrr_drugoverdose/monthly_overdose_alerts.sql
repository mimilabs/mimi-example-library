/* state_monthly_overdose_analysis.sql

Business Purpose:
- Monitor monthly changes in drug overdose deaths at the state level
- Identify states showing concerning month-over-month increases
- Enable early warning detection for emerging overdose hotspots
- Support rapid public health response planning
*/

WITH monthly_trends AS (
  -- Calculate month-over-month changes in overdose deaths by state
  SELECT 
    state_name,
    report_date,
    indicator,
    data_value as current_deaths,
    LAG(data_value) OVER (PARTITION BY state_name, indicator ORDER BY report_date) as previous_deaths,
    ROUND(((data_value - LAG(data_value) OVER (PARTITION BY state_name, indicator 
      ORDER BY report_date)) / NULLIF(LAG(data_value) OVER (PARTITION BY state_name, indicator 
      ORDER BY report_date), 0)) * 100, 1) as pct_change
  FROM mimi_ws_1.cdc.vsrr_drugoverdose
  WHERE indicator = 'Number of Drug Overdose Deaths'
    AND report_date >= ADD_MONTHS(CURRENT_DATE, -12)
    AND percent_complete = '100'
)

SELECT 
  state_name,
  DATE_FORMAT(report_date, 'MMM yyyy') as month_year,
  current_deaths,
  previous_deaths,
  pct_change,
  -- Flag concerning increases
  CASE 
    WHEN pct_change >= 10 THEN 'Significant Increase'
    WHEN pct_change >= 5 THEN 'Moderate Increase'
    WHEN pct_change <= -5 THEN 'Decrease'
    ELSE 'Stable'
  END as trend_category
FROM monthly_trends
WHERE current_deaths IS NOT NULL 
  AND previous_deaths IS NOT NULL
ORDER BY report_date DESC, pct_change DESC;

/* How the Query Works:
1. Creates monthly_trends CTE to calculate month-over-month changes
2. Focuses on complete data (percent_complete = 100) from the last 12 months
3. Calculates percentage changes and categorizes trends
4. Returns results ordered by date and change magnitude

Assumptions and Limitations:
- Only analyzes states with 100% complete reporting
- Month-over-month comparison may be affected by seasonal patterns
- Small absolute numbers can result in large percentage changes
- Provisional data subject to updates

Possible Extensions:
1. Add rolling averages to smooth monthly fluctuations
2. Include population-adjusted rates for better state comparisons
3. Add statistical significance testing for changes
4. Create alerts for states exceeding historical variation
5. Incorporate drug category breakdowns for trend analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:58:03.673241
    - Additional Notes: Query is designed as an early warning system for state-level overdose trends, focusing on month-over-month changes. Most effective when used as part of a regular monitoring schedule. The 5% and 10% thresholds for trend categorization should be reviewed and adjusted based on historical patterns and public health requirements.
    
    */