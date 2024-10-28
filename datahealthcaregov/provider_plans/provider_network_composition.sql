
/*******************************************************************************
Title: Healthcare Provider Network Analysis - Core Metrics
 
Business Purpose:
- Analyze provider participation across health insurance networks
- Understand network composition and provider distribution
- Support network adequacy and access to care analysis

Created: 2024
*******************************************************************************/

-- Main query to analyze provider network participation and composition
WITH provider_metrics AS (
  -- Get distinct provider counts and network tier distribution
  SELECT 
    plan_id,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN network_tier = 'preferred' THEN npi END) as preferred_providers,
    provider_type,
    years
  FROM mimi_ws_1.datahealthcaregov.provider_plans
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datahealthcaregov.provider_plans)
  GROUP BY plan_id, provider_type, years
)

SELECT 
  plan_id,
  provider_type,
  provider_count,
  preferred_providers,
  ROUND(preferred_providers/CAST(provider_count AS DOUBLE) * 100, 1) as pct_preferred,
  years
FROM provider_metrics
WHERE provider_count > 0
ORDER BY provider_count DESC, plan_id
LIMIT 100;

/*******************************************************************************
How this query works:
1. Uses CTE to calculate provider metrics per plan
2. Focuses on most recent data snapshot
3. Calculates key network composition metrics
4. Returns top 100 results ordered by provider count

Assumptions & Limitations:
- Assumes network_tier values include 'preferred' designation
- Limited to most recent data snapshot
- May not reflect full provider specialties/subspecialties
- Geographic distribution not included in core metrics

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Trend analysis across multiple time periods
3. Provider specialty mix analysis
4. Network adequacy calculations by geography/specialty
5. Comparative analysis between different plan types
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:20:09.146810
    - Additional Notes: Query focuses on current network composition metrics and assumes 'preferred' is a valid network_tier value. For complete network analysis, consider adding provider specialty and geographic dimensions. Performance may be impacted with large datasets due to distinct count operations.
    
    */