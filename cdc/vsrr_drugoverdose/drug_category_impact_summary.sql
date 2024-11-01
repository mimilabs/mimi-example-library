/* Drug Overdose Prevention Category Impact Analysis
   
Business Purpose:
- Analyze which drug categories are driving overdose deaths
- Identify emerging drug threats across states
- Support targeted prevention and intervention strategies
- Guide resource allocation for drug-specific responses

Created: 2024-02-14
*/

WITH latest_period AS (
  -- Get the most recent reporting period
  SELECT MAX(report_date) as max_date
  FROM mimi_ws_1.cdc.vsrr_drugoverdose
  WHERE indicator NOT LIKE '%predicted%'
),

national_totals AS (
  -- Calculate national totals by drug category
  SELECT 
    indicator,
    SUM(data_value) as total_deaths,
    COUNT(DISTINCT state) as states_reporting
  FROM mimi_ws_1.cdc.vsrr_drugoverdose d
  CROSS JOIN latest_period lp
  WHERE d.report_date = lp.max_date
    AND state != 'US'
    AND indicator NOT LIKE '%predicted%'
    AND indicator NOT LIKE '%Natural%' -- Exclude natural causes
  GROUP BY indicator
)

SELECT
  indicator as drug_category,
  total_deaths,
  states_reporting,
  ROUND(total_deaths / states_reporting, 1) as avg_deaths_per_state,
  ROUND(100.0 * total_deaths / SUM(total_deaths) OVER (), 1) as pct_of_total_deaths
FROM national_totals
WHERE total_deaths > 0
ORDER BY total_deaths DESC;

/* How this query works:
- Identifies the most recent reporting period
- Aggregates death counts by drug category at the national level
- Calculates per-state averages and percentage distributions
- Excludes predicted values and natural causes to focus on actual drug-related deaths

Assumptions and Limitations:
- Assumes data completeness varies across states
- Does not account for population differences between states
- Categories are not mutually exclusive (deaths may involve multiple drugs)
- Provisional data subject to updates

Possible Extensions:
1. Add year-over-year comparison to identify emerging threats
2. Break down by region to show geographic patterns
3. Create drug combination analysis for poly-substance deaths
4. Add seasonal trending analysis
5. Include demographic factors if available in other tables
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:41:29.266937
    - Additional Notes: Query provides a high-level snapshot of drug overdose impact by category, useful for public health resource allocation and intervention planning. Note that death counts may overlap across categories due to poly-substance cases, so percentages should not be expected to sum to 100%.
    
    */