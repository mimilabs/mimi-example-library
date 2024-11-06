-- population_by_state_summary.sql

-- Business Purpose:
-- - Provide a state-level population summary to support regional market analysis
-- - Enable quick comparison of total and average ZCTA populations across states
-- - Support initial market sizing and resource allocation decisions at the state level

WITH state_summary AS (
  -- Extract state from ZCTA and create state-level metrics
  SELECT 
    LEFT(zcta, 2) as state_prefix,
    COUNT(DISTINCT zcta) as zcta_count,
    SUM(tot_population_est) as total_state_pop,
    ROUND(AVG(tot_population_est), 0) as avg_zcta_pop,
    MIN(tot_population_est) as min_zcta_pop,
    MAX(tot_population_est) as max_zcta_pop
  FROM mimi_ws_1.census.pop_est_zcta
  WHERE year = 2020
  GROUP BY LEFT(zcta, 2)
)

-- Present results ordered by total population
SELECT 
  state_prefix,
  zcta_count,
  total_state_pop,
  avg_zcta_pop,
  min_zcta_pop,
  max_zcta_pop,
  -- Calculate percentage of ZCTAs relative to total
  ROUND(total_state_pop * 100.0 / SUM(total_state_pop) OVER (), 2) as pct_of_total_pop
FROM state_summary
ORDER BY total_state_pop DESC;

-- How this query works:
-- 1. Uses the first two digits of ZCTA to group data by state
-- 2. Calculates key population metrics for each state
-- 3. Adds percentage calculation to show relative population distribution
-- 4. Orders results by total population to highlight largest markets

-- Assumptions and Limitations:
-- - First two digits of ZCTA are used as state proxy (may not be perfect)
-- - Based on 2020 data only
-- - Does not account for cross-border ZCTAs
-- - Population counts are point-in-time estimates

-- Possible Extensions:
-- 1. Add state names lookup table for better readability
-- 2. Include year-over-year comparison if historical data available
-- 3. Add population density calculations using ZCTA geographic area
-- 4. Create population size tiers for market segmentation
-- 5. Include demographic or economic indicators for richer analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:32:19.963588
    - Additional Notes: The query uses ZCTA prefixes as a state proxy which may not be 100% accurate for states with shared prefix codes. Consider adding a proper state-to-ZCTA mapping table for production use.
    
    */