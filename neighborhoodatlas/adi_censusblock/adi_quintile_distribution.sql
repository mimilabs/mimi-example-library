-- national_adi_quintile_analysis.sql
-- Business Purpose: 
-- This query analyzes the distribution of neighborhoods across national ADI quintiles
-- to help healthcare organizations:
-- 1. Identify areas of highest socioeconomic need for targeted interventions
-- 2. Plan resource allocation for community health programs
-- 3. Support population health management initiatives
-- 4. Inform value-based care strategies

WITH quintile_summary AS (
  -- Calculate metrics for each national ADI quintile
  SELECT 
    CAST(nat_qdi AS INT) AS national_quintile,
    COUNT(*) AS neighborhood_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_neighborhoods,
    ROUND(AVG(adi_natrank), 2) AS avg_national_rank,
    MIN(adi_natrank) AS min_rank,
    MAX(adi_natrank) AS max_rank
  FROM mimi_ws_1.neighborhoodatlas.adi_censusblock
  WHERE nat_qdi IS NOT NULL
  GROUP BY nat_qdi
)

SELECT 
  national_quintile,
  neighborhood_count,
  pct_neighborhoods,
  avg_national_rank,
  min_rank,
  max_rank,
  -- Add interpretation labels for easier reporting
  CASE 
    WHEN CAST(national_quintile AS INT) = 1 THEN 'Least Disadvantaged'
    WHEN CAST(national_quintile AS INT) = 5 THEN 'Most Disadvantaged'
    ELSE 'Moderate'
  END AS quintile_interpretation
FROM quintile_summary
ORDER BY national_quintile;

-- How this query works:
-- 1. Creates a CTE to summarize key metrics for each national ADI quintile
-- 2. Calculates count and percentage of neighborhoods in each quintile
-- 3. Computes average, minimum and maximum national ranks within quintiles
-- 4. Adds interpretation labels for the extreme quintiles
-- 5. Orders results by quintile for clear presentation

-- Assumptions and Limitations:
-- 1. Assumes nat_qdi values are valid and range from 1-5
-- 2. Null values are excluded from the analysis
-- 3. National perspective only - does not account for state-level variations
-- 4. Point-in-time analysis based on most recent data load

-- Possible Extensions:
-- 1. Add year-over-year trend analysis if historical data available
-- 2. Include state-level breakdowns to compare regional patterns
-- 3. Correlate with specific health outcome measures
-- 4. Add geographic clustering analysis within quintiles
-- 5. Incorporate demographic data to analyze population characteristics by quintile

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:38:18.749260
    - Additional Notes: Query focuses on national-level ADI quintile distribution patterns. The explicit type casting (CAST AS INT) is required for proper comparison operations in Databricks SQL. Results are aggregated at the quintile level, providing a high-level view of neighborhood socioeconomic disparities across the US.
    
    */