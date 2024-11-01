-- Title: Medication Adherence and Discontinuation Pattern Analysis
-- 
-- Business Purpose:
-- - Identify medications with high discontinuation rates
-- - Analyze typical duration patterns for key medications
-- - Support medication adherence improvement initiatives
-- - Help understand patient persistence with prescribed treatments
--
-- Created: 2024
-- Database: Databricks
-- Table: mimi_ws_1.synthea.medications

WITH medication_durations AS (
  SELECT 
    description,
    -- Calculate duration in days
    AVG(DATEDIFF(COALESCE(stop, CURRENT_DATE), start)) as avg_duration_days,
    -- Count total prescriptions
    COUNT(*) as total_prescriptions,
    -- Count discontinued (those with stop dates)
    COUNT(CASE WHEN stop IS NOT NULL THEN 1 END) as discontinued_count,
    -- Calculate discontinuation rate
    ROUND(COUNT(CASE WHEN stop IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as discontinuation_rate
  FROM mimi_ws_1.synthea.medications
  WHERE start IS NOT NULL
  GROUP BY description
  HAVING COUNT(*) >= 100  -- Focus on medications with significant prescription volume
),

ranked_medications AS (
  SELECT 
    *,
    -- Rank medications by discontinuation rate
    ROW_NUMBER() OVER (ORDER BY discontinuation_rate DESC) as rank_by_discontinuation
  FROM medication_durations
)

SELECT 
  description,
  total_prescriptions,
  ROUND(avg_duration_days, 1) as avg_duration_days,
  discontinued_count,
  discontinuation_rate
FROM ranked_medications
WHERE rank_by_discontinuation <= 20  -- Top 20 medications by discontinuation rate
ORDER BY discontinuation_rate DESC;

-- How this query works:
-- 1. First CTE calculates key metrics for each medication:
--    - Average duration of treatment
--    - Total prescription count
--    - Number of discontinued prescriptions
--    - Discontinuation rate
-- 2. Second CTE ranks medications by discontinuation rate
-- 3. Final SELECT returns the top 20 medications with highest discontinuation rates
--
-- Assumptions and Limitations:
-- - Assumes NULL stop date means medication is still active
-- - Requires at least 100 prescriptions per medication for meaningful analysis
-- - Does not account for seasonal variations or temporal trends
-- - Does not consider patient demographics or conditions
--
-- Possible Extensions:
-- 1. Add temporal trend analysis to see if discontinuation rates change over time
-- 2. Segment by patient age groups or conditions
-- 3. Compare discontinuation rates across different payers
-- 4. Add cost impact analysis of early discontinuation
-- 5. Include reason codes analysis for discontinuation patterns
-- 6. Add seasonality analysis for specific medications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:35:26.858014
    - Additional Notes: Query focuses on medications with 100+ prescriptions to ensure statistical significance. Current date is used as end date for active prescriptions, which may overestimate duration for recently prescribed medications. Consider adjusting the prescription volume threshold (100) based on your specific analysis needs.
    
    */