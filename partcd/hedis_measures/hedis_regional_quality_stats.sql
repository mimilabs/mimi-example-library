-- hedis_measure_geographic_impact.sql

-- Purpose: Analyze geographic variation in HEDIS measure performance to identify
-- regional patterns in healthcare quality and inform targeted improvement strategies
--
-- Business Value:
-- - Understand regional disparities in healthcare quality delivery
-- - Guide resource allocation for quality improvement initiatives
-- - Support strategic planning for market expansion
-- - Inform provider network development strategies

WITH measure_stats AS (
  -- Calculate average performance by measure and state
  SELECT 
    SUBSTRING(contract_number, 1, 2) as state_code,
    measure_code,
    measure_name,
    hedis_year,
    COUNT(DISTINCT contract_number) as contract_count,
    AVG(rate) as avg_rate,
    STDDEV(rate) as rate_std_dev,
    MIN(rate) as min_rate,
    MAX(rate) as max_rate
  FROM mimi_ws_1.partcd.hedis_measures
  WHERE rate IS NOT NULL 
    AND hedis_year >= 2020  -- Focus on recent years
  GROUP BY 1,2,3,4
),

state_rankings AS (
  -- Rank states by performance for each measure
  SELECT 
    state_code,
    measure_code,
    measure_name,
    hedis_year,
    avg_rate,
    contract_count,
    RANK() OVER (PARTITION BY measure_code, hedis_year ORDER BY avg_rate DESC) as state_rank
  FROM measure_stats
  WHERE contract_count >= 3  -- Ensure sufficient sample size
)

-- Final output showing top and bottom performing states by measure
SELECT 
  measure_code,
  measure_name,
  hedis_year,
  MAX(CASE WHEN state_rank <= 3 THEN state_code || ': ' || ROUND(avg_rate,2) || '%' END) as top_3_states,
  MAX(CASE WHEN state_rank >= (SELECT COUNT(*) - 2 FROM state_rankings s2 
           WHERE s2.measure_code = sr.measure_code AND s2.hedis_year = sr.hedis_year)
      THEN state_code || ': ' || ROUND(avg_rate,2) || '%' END) as bottom_3_states,
  ROUND(AVG(avg_rate), 2) as national_avg,
  MAX(contract_count) as max_contracts_per_state
FROM state_rankings sr
GROUP BY measure_code, measure_name, hedis_year
ORDER BY measure_code, hedis_year DESC;

-- How it works:
-- 1. First CTE calculates state-level statistics for each measure
-- 2. Second CTE ranks states by their average performance
-- 3. Final query identifies top and bottom performing states with their rates
-- 4. Results include national averages for context

-- Assumptions and limitations:
-- - Requires at least 3 contracts per state for inclusion
-- - Uses state code from first two characters of contract number
-- - Focuses on recent years (2020+)
-- - Does not account for differences in population demographics
-- - Does not consider statistical significance of differences

-- Possible extensions:
-- 1. Add year-over-year change in state rankings
-- 2. Include population size or demographic adjustments
-- 3. Add geographic clustering analysis
-- 4. Incorporate cost data to analyze quality/cost relationships
-- 5. Add filtering for specific measure categories or disease states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:59:29.406822
    - Additional Notes: Query calculates state-level HEDIS performance metrics, identifying high and low performing regions. Requires minimum of 3 contracts per state for statistical relevance. State codes are derived from contract numbers. Limited to data from 2020 onwards.
    
    */