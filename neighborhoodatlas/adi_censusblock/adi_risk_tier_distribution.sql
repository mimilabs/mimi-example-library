-- adi_risk_stratification_scoring.sql
-- Business Purpose: 
-- This query creates a risk stratification scoring model using ADI data to help healthcare organizations:
-- 1. Identify high-risk populations for targeted interventions
-- 2. Allocate resources more effectively based on community needs
-- 3. Support value-based care initiatives through population health management

WITH risk_scores AS (
  SELECT 
    fips,
    adi_natrank,
    -- Create risk tiers based on national ADI rank
    CASE 
      WHEN adi_natrank >= 90 THEN 'Very High Risk'
      WHEN adi_natrank >= 75 THEN 'High Risk'
      WHEN adi_natrank >= 50 THEN 'Moderate Risk'
      WHEN adi_natrank >= 25 THEN 'Low Risk'
      ELSE 'Very Low Risk'
    END AS risk_tier,
    -- Assign numeric risk scores for analytics
    CASE 
      WHEN adi_natrank >= 90 THEN 5
      WHEN adi_natrank >= 75 THEN 4 
      WHEN adi_natrank >= 50 THEN 3
      WHEN adi_natrank >= 25 THEN 2
      ELSE 1
    END AS risk_score
  FROM mimi_ws_1.neighborhoodatlas.adi_censusblock
  WHERE adi_natrank IS NOT NULL
)

SELECT
  risk_tier,
  COUNT(*) as neighborhood_count,
  ROUND(AVG(adi_natrank), 2) as avg_adi_rank,
  ROUND(AVG(risk_score), 2) as avg_risk_score,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total
FROM risk_scores
GROUP BY risk_tier
ORDER BY avg_risk_score DESC;

-- How the Query Works:
-- 1. Creates risk tiers and scores based on national ADI rankings
-- 2. Groups neighborhoods by risk tier
-- 3. Calculates key metrics for each tier:
--    - Number of neighborhoods
--    - Average ADI rank
--    - Average risk score
--    - Percentage of total neighborhoods

-- Assumptions and Limitations:
-- 1. Assumes ADI rankings are current and complete
-- 2. Risk tier cutoffs are arbitrary and may need adjustment
-- 3. Does not account for state-specific variations
-- 4. Missing or null ADI values are excluded

-- Possible Extensions:
-- 1. Add geographic grouping (state/county level analysis)
-- 2. Incorporate temporal trends using mimi_src_file_date
-- 3. Compare national vs state-specific rankings
-- 4. Add additional SDOH factors for more complex risk scoring
-- 5. Create population-weighted risk scores using census data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:17:20.658141
    - Additional Notes: This query provides population health risk stratification based on ADI national rankings, with predefined risk tiers (Very High to Very Low). The scoring model uses percentile-based cutoffs (90th, 75th, 50th, 25th) to segment neighborhoods, which may need adjustment based on specific organizational needs or local population characteristics.
    
    */