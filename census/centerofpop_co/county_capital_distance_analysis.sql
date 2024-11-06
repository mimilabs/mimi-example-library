-- County Population Distribution and Distance Analysis
-- -------------------------------------------------------------------------------
-- Business Purpose: Analyzes the relationship between county population size and 
-- distance from state capitals to identify potential service coverage gaps and
-- resource allocation needs.
-- This information is valuable for:
-- - Planning regional service delivery networks
-- - Understanding population accessibility challenges
-- - Optimizing resource distribution across counties

WITH state_capitals AS (
  -- Approximate coordinates for state capitals (sample for illustration)
  SELECT 
    stname,
    CASE 
      WHEN stname = 'California' THEN 38.5816
      WHEN stname = 'Texas' THEN 30.2672
      WHEN stname = 'Florida' THEN 30.4383
      ELSE NULL
    END as capital_lat,
    CASE 
      WHEN stname = 'California' THEN -121.4944
      WHEN stname = 'Texas' THEN -97.7431
      WHEN stname = 'Florida' THEN -84.2807
      ELSE NULL
    END as capital_long
  FROM mimi_ws_1.census.centerofpop_co
  GROUP BY stname
)

SELECT 
  c.stname,
  c.couname,
  c.population,
  c.latitude,
  c.longitude,
  -- Calculate approximate distance from state capital (in degrees)
  ROUND(SQRT(POWER(c.latitude - sc.capital_lat, 2) + 
       POWER(c.longitude - sc.capital_long, 2)), 2) as dist_from_capital,
  -- Categorize counties by population size
  CASE 
    WHEN c.population >= 1000000 THEN 'Large'
    WHEN c.population >= 100000 THEN 'Medium'
    ELSE 'Small'
  END as population_category
FROM mimi_ws_1.census.centerofpop_co c
LEFT JOIN state_capitals sc ON c.stname = sc.stname
WHERE c.stname IN ('California', 'Texas', 'Florida')  -- Limiting to sample states
ORDER BY c.stname, c.population DESC;

-- Query Explanation:
-- 1. Creates a CTE with state capital coordinates (sample data)
-- 2. Joins county population centers with state capitals
-- 3. Calculates approximate distance from state capital
-- 4. Categorizes counties by population size
-- 5. Orders results by state and population

-- Assumptions and Limitations:
-- - Uses simplified distance calculation (not accounting for Earth's curvature)
-- - Limited to select states for demonstration
-- - State capital coordinates are approximated
-- - Assumes current population distribution patterns

-- Possible Extensions:
-- 1. Add more sophisticated distance calculations using haversine formula
-- 2. Include demographic factors for more detailed analysis
-- 3. Add temporal analysis comparing multiple census years
-- 4. Incorporate additional geographic features (major cities, highways)
-- 5. Expand analysis to include economic indicators or service availability metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:57:44.434813
    - Additional Notes: Query focuses on analyzing spatial relationships between county population centers and state capitals for CA, TX, and FL only. The distance calculations are simplified and should be enhanced with proper geographic formulas for production use. State capital coordinates are hardcoded and should be replaced with actual reference data for full implementation.
    
    */