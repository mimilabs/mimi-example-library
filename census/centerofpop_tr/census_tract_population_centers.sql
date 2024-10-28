
-- Census Tract Population Centers Analysis
-- Purpose: Analyze population distribution patterns across census tracts to identify
-- demographic concentrations and inform planning decisions.

/* This query examines census tract population centers to:
   1. Identify the most populated tracts
   2. Show their geographic coordinates
   3. Provide state/county context
   Main use cases: Urban planning, demographic analysis, service area planning */

WITH ranked_tracts AS (
  -- Rank census tracts by population within each state
  SELECT 
    statefp,
    countyfp,
    tractce,
    population,
    latitude,
    longitude,
    ROW_NUMBER() OVER (PARTITION BY statefp ORDER BY population DESC) as pop_rank
  FROM mimi_ws_1.census.centerofpop_tr
),

state_stats AS (
  -- Calculate state-level population statistics
  SELECT
    statefp,
    COUNT(*) as tract_count,
    SUM(population) as total_state_pop,
    AVG(population) as avg_tract_pop
  FROM mimi_ws_1.census.centerofpop_tr
  GROUP BY statefp
)

-- Main analysis combining tract and state data
SELECT
  r.statefp,
  r.countyfp,
  r.tractce,
  r.population,
  r.latitude,
  r.longitude,
  r.pop_rank,
  s.total_state_pop,
  s.avg_tract_pop,
  ROUND(100.0 * r.population / s.total_state_pop, 2) as pct_of_state_pop
FROM ranked_tracts r
JOIN state_stats s ON r.statefp = s.statefp
WHERE r.pop_rank <= 10  -- Show top 10 most populated tracts per state
ORDER BY r.statefp, r.pop_rank;

/* How this query works:
- Creates a CTE to rank tracts by population within each state
- Calculates state-level statistics in a separate CTE
- Joins the data to show context and relative populations
- Filters to top 10 tracts per state for focused analysis

Assumptions and limitations:
- Assumes current population data is accurate and complete
- Limited to geographic analysis without demographic breakdowns
- Does not account for tract size/density
- Top 10 cutoff is arbitrary and can be adjusted

Possible extensions:
1. Add population density calculations using tract geographic data
2. Include year-over-year population changes if historical data available
3. Add demographic breakdowns if available in related tables
4. Calculate distance from population centers to key infrastructure
5. Group by county level for intermediate geographic analysis
6. Add filters for specific regions or population thresholds
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:44:15.230169
    - Additional Notes: The query provides a multi-state population analysis at the census tract level, ranking tracts by population and calculating state-level statistics. The default output shows the top 10 most populated tracts per state with their geographic coordinates and relative population metrics. The 10-tract limit can be adjusted by modifying the WHERE clause.
    
    */