
/* Drug Overdose Death Trends Analysis
   
   Business Purpose:
   - Track and analyze provisional drug overdose death counts across states
   - Identify geographic patterns and trends in overdose mortality
   - Support public health monitoring and response efforts
*/

-- Main Analysis Query
WITH recent_data AS (
  -- Get most recent 12-month period data for all states
  SELECT DISTINCT 
    state_name,
    report_date,
    indicator,
    data_value,
    percent_complete
  FROM mimi_ws_1.cdc.vsrr_drugoverdose
  WHERE indicator = 'Number of Drug Overdose Deaths'
    AND period = '12 months-ending'
    AND percent_complete = '100'  -- Focus on complete data
    AND report_date = (
      SELECT MAX(report_date) 
      FROM mimi_ws_1.cdc.vsrr_drugoverdose
    )
)

SELECT
  state_name,
  data_value as overdose_deaths,
  RANK() OVER (ORDER BY data_value DESC) as death_count_rank
FROM recent_data
WHERE state_name != 'United States' -- Exclude national total
ORDER BY overdose_deaths DESC
LIMIT 10;

/* How This Query Works:
   1. Filters for most recent 12-month period with complete data
   2. Selects state-level overdose death counts
   3. Ranks states by death counts
   4. Shows top 10 states with highest counts

   Assumptions & Limitations:
   - Uses only 100% complete data points
   - Focuses on absolute death counts rather than population-adjusted rates
   - Limited to most recent time period only
   - Does not break down by specific drug types

   Possible Extensions:
   1. Add year-over-year percent change calculations
   2. Include drug type breakdown (opioids vs stimulants etc)
   3. Calculate per-capita rates using state population data
   4. Add time series analysis to show trends
   5. Include percent pending investigation analysis
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:46:20.802458
    - Additional Notes: Query focuses on current state-level drug overdose mortality rankings using only fully complete (100%) data points. Does not account for population differences between states or historical trends. Best used for initial high-level geographic assessment of overdose burden.
    
    */