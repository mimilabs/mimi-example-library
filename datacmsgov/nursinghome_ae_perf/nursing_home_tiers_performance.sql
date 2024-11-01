-- nursing_home_performance_comparison.sql
--
-- Business Purpose:
-- Analyze and compare nursing home affiliated entities based on size, market presence,
-- and key resident care outcomes. This helps identify market leaders and benchmark
-- performance across the industry to inform strategic partnerships, investments,
-- and quality improvement initiatives.

WITH entity_size_tiers AS (
  SELECT
    affiliated_entity,
    number_of_facilities,
    number_of_states_and_territories_with_operations,
    CASE 
      WHEN number_of_facilities >= 100 THEN 'Large (100+ facilities)'
      WHEN number_of_facilities >= 50 THEN 'Medium (50-99 facilities)'
      ELSE 'Small (<50 facilities)'
    END AS size_tier
  FROM mimi_ws_1.datacmsgov.nursinghome_ae_perf
),

performance_metrics AS (
  SELECT 
    affiliated_entity,
    average_overall_5star_rating,
    average_percentage_of_shortstay_residents_who_made_improvements_in_function,
    average_percentage_of_longstay_residents_whose_need_for_help_with_activities_of_daily_living_has_increased,
    total_amount_of_fines_in_dollars/NULLIF(number_of_facilities, 0) as fine_dollars_per_facility
  FROM mimi_ws_1.datacmsgov.nursinghome_ae_perf
)

SELECT 
  e.size_tier,
  e.affiliated_entity,
  e.number_of_facilities,
  e.number_of_states_and_territories_with_operations,
  p.average_overall_5star_rating,
  ROUND(p.average_percentage_of_shortstay_residents_who_made_improvements_in_function, 1) as pct_shortstay_improvement,
  ROUND(p.average_percentage_of_longstay_residents_whose_need_for_help_with_activities_of_daily_living_has_increased, 1) as pct_longstay_adl_decline,
  ROUND(p.fine_dollars_per_facility, 0) as fine_dollars_per_facility
FROM entity_size_tiers e
JOIN performance_metrics p ON e.affiliated_entity = p.affiliated_entity
WHERE e.number_of_facilities >= 10  -- Focus on entities with meaningful scale
ORDER BY 
  e.size_tier,
  p.average_overall_5star_rating DESC,
  e.number_of_facilities DESC;

-- How this query works:
-- 1. Creates size tiers based on number of facilities
-- 2. Calculates key performance metrics including star ratings and resident outcomes
-- 3. Joins and filters to show only entities with 10+ facilities
-- 4. Orders results by size tier and quality metrics

-- Assumptions and limitations:
-- - Requires at least 10 facilities for meaningful comparison
-- - Averages may mask facility-level variation
-- - Does not account for regional differences
-- - Financial metrics limited to regulatory fines

-- Possible extensions:
-- 1. Add geographic concentration analysis
-- 2. Include staffing metrics correlation
-- 3. Trend analysis across multiple time periods
-- 4. Peer group benchmarking within size tiers
-- 5. Add COVID-19 vaccination rate comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:19:27.349407
    - Additional Notes: Query provides a tiered analysis of nursing home entities, focusing on facilities with 10+ locations. Performance metrics include star ratings, resident improvement rates, and regulatory fines. Size tiers are defined as Large (100+), Medium (50-99), and Small (<50) facilities.
    
    */