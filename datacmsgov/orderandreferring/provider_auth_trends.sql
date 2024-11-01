-- Medicare Provider Temporal Authorization Trend Analysis

-- Business Purpose:
-- Analyzes changes in provider Medicare authorization patterns over time to:
-- - Track provider network stability and turnover
-- - Identify trends in service authorization changes
-- - Support workforce planning and network development
-- - Guide provider engagement strategies

-- Main Query
WITH provider_auth_snapshots AS (
  SELECT 
    _input_file_date,
    COUNT(DISTINCT npi) as total_providers,
    SUM(CASE WHEN partb = 'Y' THEN 1 ELSE 0 END) as partb_auth_count,
    SUM(CASE WHEN dme = 'Y' THEN 1 ELSE 0 END) as dme_auth_count,
    SUM(CASE WHEN hha = 'Y' THEN 1 ELSE 0 END) as hha_auth_count,
    SUM(CASE WHEN pmd = 'Y' THEN 1 ELSE 0 END) as pmd_auth_count,
    SUM(CASE WHEN hospice = 'Y' THEN 1 ELSE 0 END) as hospice_auth_count
  FROM mimi_ws_1.datacmsgov.orderandreferring
  GROUP BY _input_file_date
)

SELECT 
  _input_file_date,
  total_providers,
  -- Calculate authorization percentages
  ROUND(100.0 * partb_auth_count / total_providers, 2) as partb_auth_pct,
  ROUND(100.0 * dme_auth_count / total_providers, 2) as dme_auth_pct,
  ROUND(100.0 * hha_auth_count / total_providers, 2) as hha_auth_pct,
  ROUND(100.0 * pmd_auth_count / total_providers, 2) as pmd_auth_pct,
  ROUND(100.0 * hospice_auth_count / total_providers, 2) as hospice_auth_pct,
  -- Calculate week-over-week changes
  total_providers - LAG(total_providers) OVER (ORDER BY _input_file_date) as provider_count_change
FROM provider_auth_snapshots
ORDER BY _input_file_date;

-- How it works:
-- 1. Creates a CTE to aggregate provider counts and authorization counts by date
-- 2. Calculates percentages of providers with each authorization type
-- 3. Uses window functions to calculate week-over-week changes
-- 4. Orders results chronologically to show trends

-- Assumptions and Limitations:
-- - Assumes weekly data snapshots are complete and consistent
-- - Does not account for provider specialty or geographic distribution
-- - Week-over-week changes may be affected by data quality issues
-- - Historical data limited to available snapshot dates

-- Possible Extensions:
-- 1. Add rolling averages to smooth out weekly fluctuations
-- 2. Include specialty-specific trend analysis
-- 3. Add seasonality analysis for authorization changes
-- 4. Compare authorization patterns across different regions
-- 5. Create forecasting models for network planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:21:12.016720
    - Additional Notes: Query tracks temporal patterns in Medicare provider authorizations and network stability. Best used with at least 3 weeks of historical data for meaningful trend analysis. Results are aggregate-level and may mask individual provider-level changes.
    
    */