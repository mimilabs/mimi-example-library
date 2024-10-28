
/* Medicare Provider Order & Referral Analysis
 
This query analyzes the distribution and capabilities of Medicare providers
who can order and refer services, focusing on their authorization levels
across different Medicare service types (Part B, DME, Home Health, etc.).

Business Purpose:
- Understand provider coverage and capabilities in the Medicare system
- Identify potential gaps in service coverage
- Support provider network planning and analysis
*/

WITH provider_summary AS (
  -- Get latest data by finding max input file date
  SELECT * 
  FROM mimi_ws_1.datacmsgov.orderandreferring
  WHERE _input_file_date = (
    SELECT MAX(_input_file_date) 
    FROM mimi_ws_1.datacmsgov.orderandreferring
  )
)

SELECT
  -- Count total providers
  COUNT(DISTINCT npi) as total_providers,
  
  -- Calculate percentages authorized for each service type
  ROUND(100.0 * SUM(CASE WHEN partb = 'Y' THEN 1 ELSE 0 END)/COUNT(*),1) as pct_partb_auth,
  ROUND(100.0 * SUM(CASE WHEN dme = 'Y' THEN 1 ELSE 0 END)/COUNT(*),1) as pct_dme_auth,
  ROUND(100.0 * SUM(CASE WHEN hha = 'Y' THEN 1 ELSE 0 END)/COUNT(*),1) as pct_hha_auth,
  ROUND(100.0 * SUM(CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END)/COUNT(*),1) as pct_pmd_auth,
  ROUND(100.0 * SUM(CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END)/COUNT(*),1) as pct_hospice_auth,

  -- Calculate providers authorized for all services
  SUM(CASE WHEN partb = 'Y' AND dme = 'Y' AND hha = 'Y' 
           AND pmd = 'Y' AND hospice = 'Y' THEN 1 ELSE 0 END) as full_auth_providers

FROM provider_summary;

/* How this query works:
1. Creates a CTE with only the most recent data
2. Calculates overall provider counts and percentages authorized for each service
3. Identifies providers with full authorization across all services

Assumptions & Limitations:
- Assumes 'Y' indicates authorization for a service
- Based only on most recent data snapshot
- Does not account for geographic distribution
- Does not track changes over time

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Track authorization trends over time using historical snapshots
3. Break down by provider specialties if that data becomes available
4. Analyze combinations of service authorizations
5. Add provider name analysis for duplicate detection
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:45:01.882108
    - Additional Notes: Query focuses on current authorization rates across Medicare service types. Consider that percentages are rounded to 1 decimal place and results are limited to most recent data snapshot only. For time-series analysis, query would need modification to handle multiple _input_file_date values.
    
    */