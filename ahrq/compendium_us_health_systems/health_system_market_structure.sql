-- Health System Market Structure Analysis
-- ==============================================

-- Business Purpose: Analyze the market structure and consolidation patterns of U.S. health systems by examining:
-- - Multi-state presence and market reach
-- - System size tiers based on hospital counts
-- - Ownership concentration patterns
-- - Children's healthcare service capacity

WITH system_size_tiers AS (
  SELECT 
    CASE 
      WHEN hosp_cnt >= 20 THEN 'Large (20+ hospitals)'
      WHEN hosp_cnt >= 10 THEN 'Medium (10-19 hospitals)'
      WHEN hosp_cnt >= 5 THEN 'Small (5-9 hospitals)'
      ELSE 'Micro (1-4 hospitals)'
    END AS system_size_tier,
    COUNT(DISTINCT health_sys_id) as num_systems,
    SUM(hosp_cnt) as total_hospitals,
    SUM(sys_beds) as total_beds,
    AVG(CASE WHEN sys_multistate > 1 THEN 1 ELSE 0 END) as pct_multistate,
    AVG(CASE WHEN deg_children > 0 THEN 1 ELSE 0 END) as pct_with_childrens
  FROM mimi_ws_1.ahrq.compendium_us_health_systems
  GROUP BY 1
)

SELECT
  system_size_tier,
  num_systems,
  total_hospitals,
  total_beds,
  ROUND(100 * pct_multistate, 1) as pct_multistate_systems,
  ROUND(100 * pct_with_childrens, 1) as pct_with_childrens_hospitals,
  ROUND(100 * num_systems / SUM(num_systems) OVER (), 1) as pct_of_all_systems,
  ROUND(100 * total_hospitals / SUM(total_hospitals) OVER (), 1) as pct_of_all_hospitals
FROM system_size_tiers
ORDER BY 
  CASE system_size_tier
    WHEN 'Large (20+ hospitals)' THEN 1
    WHEN 'Medium (10-19 hospitals)' THEN 2
    WHEN 'Small (5-9 hospitals)' THEN 3
    ELSE 4
  END;

-- How this query works:
-- 1. Creates size tiers based on hospital count
-- 2. Calculates key metrics for each tier including system counts, hospital counts, and bed capacity
-- 3. Computes percentages for multi-state presence and children's hospital services
-- 4. Provides market share analysis for systems and hospitals

-- Assumptions and Limitations:
-- - Size tiers are defined arbitrarily and may need adjustment based on specific analysis needs
-- - Multi-state presence is simplified to yes/no rather than number of states
-- - Children's hospital presence is binary rather than measuring capacity
-- - Current year data only; doesn't show temporal trends

-- Possible Extensions:
-- 1. Add temporal analysis to show consolidation trends over time
-- 2. Include revenue analysis by size tier
-- 3. Add geographic concentration metrics
-- 4. Incorporate teaching status and specialty service lines
-- 5. Add market competition analysis using HHI or similar metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:33:57.852551
    - Additional Notes: The query segments health systems into size tiers and calculates market concentration metrics. It provides insights into system consolidation patterns and service distribution but may need tier definitions adjusted based on specific market analysis needs. Consider local market definitions and regulatory requirements when using for competitive analysis.
    
    */