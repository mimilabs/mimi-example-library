-- adi_national_vs_state_comparison.sql
-- Business Purpose: This query analyzes the relationship between national and state-level 
-- ADI rankings to help healthcare organizations:
-- 1. Understand relative deprivation within different geographic contexts
-- 2. Identify areas that may be overlooked when using only one ranking system
-- 3. Support more nuanced resource allocation and intervention planning
-- 4. Enable better risk adjustment for value-based care programs

WITH ranking_comparison AS (
  SELECT 
    -- Calculate differences between national and state rankings
    adi_natrank,
    adi_staternk,
    ABS(adi_natrank - adi_staternk) as rank_difference,
    
    -- Create meaningful categories for analysis
    CASE 
      WHEN adi_natrank > 75 AND adi_staternk > 75 THEN 'High Risk Both'
      WHEN adi_natrank < 25 AND adi_staternk < 25 THEN 'Low Risk Both'
      WHEN ABS(adi_natrank - adi_staternk) > 25 THEN 'Mixed Risk'
      ELSE 'Moderate Risk'
    END as risk_alignment,
    
    -- Extract state from FIPS code for grouping
    LEFT(fips, 2) as state_fips
  FROM mimi_ws_1.neighborhoodatlas.adi_censusblock
  WHERE adi_natrank IS NOT NULL 
    AND adi_staternk IS NOT NULL
)

SELECT 
  state_fips,
  risk_alignment,
  COUNT(*) as block_count,
  ROUND(AVG(rank_difference), 2) as avg_rank_difference,
  ROUND(AVG(adi_natrank), 2) as avg_national_rank,
  ROUND(AVG(adi_staternk), 2) as avg_state_rank
FROM ranking_comparison
GROUP BY state_fips, risk_alignment
ORDER BY state_fips, risk_alignment;

-- How this query works:
-- 1. Creates a CTE to calculate differences between national and state rankings
-- 2. Categorizes census blocks based on risk alignment patterns
-- 3. Groups results by state and risk alignment category
-- 4. Provides summary statistics for each group

-- Assumptions and Limitations:
-- 1. Assumes both national and state rankings are on same scale (0-100)
-- 2. Treats missing values as excluded from analysis
-- 3. Uses arbitrary thresholds (25, 75) for risk categorization
-- 4. State-level aggregation may mask important local variations

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating mimi_src_file_date
-- 2. Include additional geographic metadata for more granular analysis
-- 3. Create population-weighted versions of the calculations
-- 4. Add specific intervention recommendations based on risk patterns
-- 5. Integrate with other datasets (claims, quality measures) for impact analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:19:53.882193
    - Additional Notes: Query performs state-level analysis of ADI risk alignment patterns, comparing national vs state rankings. Best used for strategic planning and resource allocation across multiple states. May require additional geographic metadata for full context of state identifiers.
    
    */