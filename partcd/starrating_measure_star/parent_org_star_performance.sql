-- Title: Parent Organization Performance Trend Analysis for Medicare Contracts
--
-- Business Purpose:
-- - Track star rating performance trends across major parent organizations
-- - Identify which parent organizations are consistently delivering high quality care
-- - Support strategic partnership and competitive analysis decisions
-- - Help understand market consolidation impacts on quality metrics
--
-- Created: 2024
--

WITH yearly_parent_performance AS (
  -- Calculate average star ratings by parent org and year
  SELECT 
    performance_year,
    parent_organization,
    COUNT(DISTINCT contract_id) as number_of_contracts,
    ROUND(AVG(CAST(measure_value AS FLOAT)), 2) as avg_star_rating,
    COUNT(DISTINCT measure_code) as measures_reported
  FROM mimi_ws_1.partcd.starrating_measure_star
  WHERE 
    measure_value IS NOT NULL
    AND parent_organization IS NOT NULL
    -- Focus on recent 3 years for trending
    AND performance_year >= YEAR(CURRENT_DATE) - 3
  GROUP BY 
    performance_year,
    parent_organization
),

parent_ranking AS (
  -- Identify top performing parent organizations
  SELECT
    parent_organization,
    ROUND(AVG(avg_star_rating), 2) as three_year_avg_rating,
    SUM(number_of_contracts) as total_contracts,
    COUNT(DISTINCT performance_year) as years_reported
  FROM yearly_parent_performance
  GROUP BY parent_organization
  HAVING COUNT(DISTINCT performance_year) = 3  -- Must have all 3 years of data
)

-- Final output combining metrics and rankings
SELECT 
  y.performance_year,
  y.parent_organization,
  y.number_of_contracts,
  y.avg_star_rating,
  r.three_year_avg_rating,
  y.measures_reported
FROM yearly_parent_performance y
INNER JOIN parent_ranking r 
  ON y.parent_organization = r.parent_organization
WHERE r.three_year_avg_rating >= 4.0  -- Focus on high performers
ORDER BY 
  r.three_year_avg_rating DESC,
  y.performance_year DESC,
  y.avg_star_rating DESC;

-- How this query works:
-- 1. First CTE calculates yearly performance metrics for each parent organization
-- 2. Second CTE identifies consistently high-performing parent organizations
-- 3. Final query joins these together to show detailed trends for top performers
--
-- Assumptions & Limitations:
-- - Assumes measure_value can be averaged meaningfully
-- - Limited to parent orgs with 3 consecutive years of data
-- - Does not weight by contract size or beneficiary count
-- - May miss newer market entrants due to history requirement
--
-- Possible Extensions:
-- 1. Add year-over-year change calculations
-- 2. Include contract count growth rates
-- 3. Segment by geographic regions
-- 4. Add specific measure domain performance
-- 5. Include market share analysis
-- 6. Add statistical significance testing for rating changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:34:58.014625
    - Additional Notes: Query focuses on parent organizations with consistent 3-year history of high performance (4+ stars). Results exclude newer market entrants and smaller organizations that may not have complete historical data. Consider runtime performance with large datasets as it performs multiple aggregations.
    
    */