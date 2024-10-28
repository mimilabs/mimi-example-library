
-- air_quality_exceedances_by_state.sql
/*
Business Purpose: 
Analyze states with the highest air quality standard exceedances to identify areas
requiring urgent environmental intervention and policy focus.

The query aggregates primary and secondary air quality standard exceedances by state,
providing insights into which regions face the most significant air quality challenges.
*/

WITH state_exceedances AS (
  -- Calculate total exceedances and monitoring stats by state
  SELECT 
    state_name,
    year,
    COUNT(DISTINCT site_num) as monitor_count,
    SUM(primary_exceedance_count) as total_primary_exceedances,
    SUM(secondary_exceedance_count) as total_secondary_exceedances,
    SUM(observation_count) as total_observations
  FROM mimi_ws_1.epa.airdata_yearly
  WHERE year >= 2018  -- Focus on recent years
  GROUP BY state_name, year
),

ranked_states AS (
  -- Rank states by total exceedances
  SELECT 
    state_name,
    year,
    monitor_count,
    total_primary_exceedances,
    total_secondary_exceedances,
    total_observations,
    -- Calculate exceedances per 1000 observations for fair comparison
    ROUND(total_primary_exceedances * 1000.0 / NULLIF(total_observations, 0), 2) as primary_exceedance_rate,
    ROUND(total_secondary_exceedances * 1000.0 / NULLIF(total_observations, 0), 2) as secondary_exceedance_rate
  FROM state_exceedances
)

SELECT 
  state_name,
  year,
  monitor_count,
  total_primary_exceedances,
  total_secondary_exceedances,
  primary_exceedance_rate,
  secondary_exceedance_rate
FROM ranked_states
WHERE total_primary_exceedances > 0 OR total_secondary_exceedances > 0
ORDER BY year DESC, total_primary_exceedances DESC, total_secondary_exceedances DESC
LIMIT 20;

/*
How it works:
1. First CTE aggregates exceedance counts and monitoring statistics by state and year
2. Second CTE calculates normalized exceedance rates per 1000 observations
3. Final query filters for states with exceedances and orders by most severe cases

Assumptions & Limitations:
- Assumes recent data (2018+) is most relevant for current decision-making
- Does not differentiate between types of pollutants causing exceedances
- Raw exceedance counts may be influenced by number of monitors in each state
- Normalized rates help account for varying observation counts

Possible Extensions:
1. Add pollutant-specific analysis to identify which substances cause most exceedances
2. Include seasonal analysis to identify temporal patterns
3. Join with demographic/industrial data to correlate exceedances with potential causes
4. Add geographic clustering to identify regional patterns
5. Include trend analysis to show improvement/degradation over time
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:23:18.291920
    - Additional Notes: Query normalizes air quality violations per 1000 observations to account for varying monitor counts across states. Results focus on recent years (2018+) and show both absolute violation counts and normalized rates to support fair state-to-state comparisons. Monitor counts are included to provide context about measurement coverage.
    
    */