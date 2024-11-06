-- Health System Home Health Organization Service Mix Analysis

-- Business Purpose:
-- - Analyze the diversity of home health services offered within health systems
-- - Identify systems with comprehensive vs specialized service offerings 
-- - Support strategic planning for service line expansion and network optimization
-- - Reveal market positioning through service mix patterns

WITH base_metrics AS (
  -- Calculate service type counts and percentages per health system
  SELECT 
    health_sys_id,
    health_sys_name,
    health_sys_state,
    COUNT(DISTINCT compendium_hh_id) as total_orgs,
    COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home health' THEN compendium_hh_id END) as home_health_count,
    COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'hospice' THEN compendium_hh_id END) as hospice_count,
    COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home dialysis' THEN compendium_hh_id END) as dialysis_count,
    ROUND(COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home health' THEN compendium_hh_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT compendium_hh_id), 0), 1) as home_health_pct,
    ROUND(COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'hospice' THEN compendium_hh_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT compendium_hh_id), 0), 1) as hospice_pct,
    ROUND(COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home dialysis' THEN compendium_hh_id END) * 100.0 / 
          NULLIF(COUNT(DISTINCT compendium_hh_id), 0), 1) as dialysis_pct
  FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
  WHERE health_sys_id IS NOT NULL
  GROUP BY 1,2,3
)

SELECT
  health_sys_name,
  health_sys_state,
  total_orgs,
  home_health_count,
  hospice_count,
  dialysis_count,
  home_health_pct,
  hospice_pct,
  dialysis_pct,
  -- Categorize service mix strategy
  CASE 
    WHEN home_health_pct >= 80 THEN 'Home Health Focused'
    WHEN hospice_pct >= 80 THEN 'Hospice Focused'
    WHEN dialysis_pct >= 80 THEN 'Dialysis Focused'
    WHEN total_orgs >= 10 AND 
         home_health_count >= 2 AND 
         hospice_count >= 2 AND 
         dialysis_count >= 2 THEN 'Comprehensive Provider'
    ELSE 'Mixed Services'
  END as service_strategy
FROM base_metrics
ORDER BY total_orgs DESC, health_sys_name;

-- How the Query Works:
-- 1. Creates base metrics CTE to calculate counts and percentages for each service type by health system
-- 2. Main query adds service strategy classification based on service mix patterns
-- 3. Results show health system profile with organization counts, service percentages, and strategic categorization

-- Assumptions and Limitations:
-- - Assumes current data represents active organizations and relationships
-- - Service strategy categories are simplified; real-world strategies may be more nuanced
-- - Does not account for service volume or quality metrics
-- - Geographic market considerations not included in strategy classification

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to track service mix changes
-- 2. Include geographic market concentration in strategy classification
-- 3. Cross-reference with quality metrics or financial data
-- 4. Add corporate parent type influence on service mix
-- 5. Calculate market share by service type within geographic regions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:17:53.689341
    - Additional Notes: The query provides executive-level insights into health system service portfolios and strategic positioning. Note that the service strategy thresholds (80% for focused categories, minimum 10 organizations and 2 of each type for comprehensive) are configurable parameters that may need adjustment based on specific analysis needs or market conditions.
    
    */