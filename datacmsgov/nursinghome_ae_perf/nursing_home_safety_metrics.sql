-- nursing_home_resident_safety_outcomes.sql
-- Business Purpose: 
-- Analyze resident safety and adverse event patterns across nursing home affiliated entities
-- to identify organizations with concerning safety trends and those with best practices.
-- This helps prioritize oversight, intervention needs, and identify practices to replicate.

WITH safety_metrics AS (
  SELECT 
    affiliated_entity,
    number_of_facilities,
    -- Core safety indicators
    average_percentage_of_longstay_residents_experiencing_one_or_more_falls_with_major_injury as fall_rate,
    average_percentage_of_longstay_highrisk_residents_with_pressure_ulcers as pressure_ulcer_rate,
    average_percentage_of_longstay_residents_with_a_urinary_tract_infection as uti_rate,
    number_of_facilities_with_an_abuse_icon as abuse_cases,
    
    -- Calculate composite safety score (lower is better)
    (COALESCE(average_percentage_of_longstay_residents_experiencing_one_or_more_falls_with_major_injury, 0) +
     COALESCE(average_percentage_of_longstay_highrisk_residents_with_pressure_ulcers, 0) +
     COALESCE(average_percentage_of_longstay_residents_with_a_urinary_tract_infection, 0) +
     COALESCE(percentage_of_facilities_with_an_abuse_icon, 0)) / 4 as composite_safety_score
  FROM mimi_ws_1.datacmsgov.nursinghome_ae_perf
  WHERE number_of_facilities >= 5  -- Focus on entities with meaningful facility count
)

SELECT
  affiliated_entity,
  number_of_facilities,
  ROUND(fall_rate, 2) as fall_rate_pct,
  ROUND(pressure_ulcer_rate, 2) as pressure_ulcer_rate_pct, 
  ROUND(uti_rate, 2) as uti_rate_pct,
  abuse_cases,
  ROUND(composite_safety_score, 2) as composite_safety_score,
  
  -- Flag concerning entities (top quartile of composite score)
  CASE 
    WHEN composite_safety_score > PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY composite_safety_score) OVER ()
    THEN 'High Risk'
    ELSE 'Standard' 
  END as risk_category

FROM safety_metrics
ORDER BY composite_safety_score DESC
LIMIT 100;

-- How it works:
-- 1. Creates safety_metrics CTE to gather and calculate key resident safety indicators
-- 2. Calculates a composite safety score averaging key metrics
-- 3. Identifies high-risk entities based on composite score distribution
-- 4. Returns top 100 entities ordered by safety risk

-- Assumptions and Limitations:
-- - Equal weighting of safety metrics in composite score
-- - Focuses on entities with 5+ facilities for statistical relevance
-- - Missing values treated as 0 in composite score
-- - Limited to most recent data snapshot

-- Possible Extensions:
-- 1. Add trend analysis comparing metrics across time periods
-- 2. Incorporate staffing levels correlation with safety outcomes
-- 3. Add geographic analysis of safety patterns
-- 4. Include demographic and facility type adjustments
-- 5. Add statistical significance testing for risk identification

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:20:55.122081
    - Additional Notes: This query effectively highlights safety concerns across affiliated entities but should be used alongside facility-level reviews since averages can mask individual poor performers within a group. The composite score methodology may need adjustment based on organizational priorities and regional benchmarks.
    
    */