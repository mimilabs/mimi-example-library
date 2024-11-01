-- Medicare Service Activity Timeline Analysis
-- 
-- Business Purpose: 
-- Examines service code effective dates and lifecycles to identify trends in
-- how Medicare services evolve over time. This helps healthcare organizations
-- understand service introduction patterns and plan for future changes in
-- Medicare coverage and reimbursement.

WITH active_services AS (
  -- Get currently active services by comparing dates
  SELECT 
    hcpcs_cd,
    rbcs_cat_desc,
    rbcs_subcat_desc,
    hcpcs_cd_add_dt,
    COALESCE(hcpcs_cd_end_dt, '9999-12-31') as end_date,
    DATEDIFF(
      COALESCE(hcpcs_cd_end_dt, CURRENT_DATE()), 
      hcpcs_cd_add_dt
    ) as service_days_active
  FROM mimi_ws_1.datacmsgov.betos
  WHERE hcpcs_cd_add_dt IS NOT NULL
),

timeline_stats AS (
  -- Calculate key timeline metrics per category
  SELECT
    rbcs_cat_desc,
    COUNT(DISTINCT hcpcs_cd) as total_services,
    AVG(service_days_active) as avg_service_lifetime,
    MIN(hcpcs_cd_add_dt) as earliest_service,
    MAX(CASE WHEN end_date = '9999-12-31' THEN hcpcs_cd_add_dt END) as latest_active_addition
  FROM active_services
  GROUP BY rbcs_cat_desc
)

-- Final output with key timeline insights
SELECT
  rbcs_cat_desc as service_category,
  total_services,
  ROUND(avg_service_lifetime/365, 1) as avg_years_active,
  earliest_service as category_first_service,
  latest_active_addition as most_recent_addition,
  DATEDIFF(latest_active_addition, earliest_service)/365 as category_age_years
FROM timeline_stats
WHERE total_services > 10  -- Focus on established categories
ORDER BY total_services DESC;

-- How the Query Works:
-- 1. Creates active_services CTE to normalize service dates and calculate duration
-- 2. Aggregates timeline statistics by category in timeline_stats CTE
-- 3. Produces final summary showing service category evolution metrics
--
-- Assumptions & Limitations:
-- - Assumes NULL end dates indicate currently active services
-- - Limited to services with valid add dates
-- - Categories with fewer than 10 services are filtered out
-- - Does not account for temporary gaps in service availability
--
-- Possible Extensions:
-- - Add year-over-year trend analysis of service additions/removals
-- - Include subcategory level analysis
-- - Compare service lifetimes across different RBCS major indicators
-- - Add geographic analysis if location data becomes available
-- - Analyze seasonal patterns in service additions/removals

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:09:11.947467
    - Additional Notes: Query requires date handling capabilities and assumes '9999-12-31' as a valid future date. Performance may be impacted with very large datasets due to date calculations. Consider adding indexes on hcpcs_cd_add_dt and hcpcs_cd_end_dt for better performance.
    
    */