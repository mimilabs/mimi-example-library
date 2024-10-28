
-- Title: Healthcare Provider Qualification Analysis 
-- 
-- Business Purpose:
-- This query analyzes healthcare provider qualifications to understand:
-- 1. The distribution of different types of credentials
-- 2. Active vs expired qualifications
-- 3. Trends in qualification adoption
-- This information helps identify workforce development needs and credential verification.

-- Main Query
WITH active_qualifications AS (
  SELECT 
    code_text,
    -- Check if qualification is currently active
    CASE 
      WHEN period_end IS NULL OR period_end > CURRENT_DATE() THEN 1
      ELSE 0 
    END as is_active,
    COUNT(DISTINCT npi) as provider_count
  FROM mimi_ws_1.nppes.fhir_qualification
  WHERE code_text IS NOT NULL
  GROUP BY 1, 2
)

SELECT
  code_text as credential_type,
  SUM(CASE WHEN is_active = 1 THEN provider_count ELSE 0 END) as active_providers,
  SUM(CASE WHEN is_active = 0 THEN provider_count ELSE 0 END) as inactive_providers,
  SUM(provider_count) as total_providers,
  ROUND(100.0 * SUM(CASE WHEN is_active = 1 THEN provider_count ELSE 0 END) / 
    SUM(provider_count), 2) as pct_active
FROM active_qualifications
GROUP BY 1
ORDER BY total_providers DESC
LIMIT 20;

-- How it works:
-- 1. Creates CTE to identify active vs inactive qualifications per provider
-- 2. Aggregates counts for each credential type
-- 3. Calculates percentage of active credentials
-- 4. Shows top 20 most common credentials

-- Assumptions & Limitations:
-- - Null period_end dates are considered active credentials
-- - Only analyzes qualifications with non-null code_text
-- - Limited to top 20 most common credentials
-- - Does not account for credential renewals or updates

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Analyze qualification trends over time using period_start dates
-- 3. Group similar credentials using LIKE or regex patterns
-- 4. Compare qualification distributions across specialties
-- 5. Identify providers with multiple active credentials
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:58:15.536300
    - Additional Notes: Query focuses on active vs inactive credential distribution and may have high resource usage on large datasets. Consider adding WHERE clauses to filter specific time periods or credential types if performance is a concern. The 20-row LIMIT may need adjustment based on specific analysis needs.
    
    */