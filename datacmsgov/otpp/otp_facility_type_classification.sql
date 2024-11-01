-- OTP Provider Facility Type Analysis
-- 
-- Business Purpose:
-- - Identify different facility types and treatment settings based on provider names
-- - Support care model analysis by understanding provider organization types
-- - Enable targeted partnerships based on facility characteristics
-- - Guide policy decisions around different treatment delivery models

WITH provider_categories AS (
  SELECT 
    -- Identify facility type based on name patterns
    CASE 
      WHEN LOWER(provider_name) LIKE '%hospital%' THEN 'Hospital-Based'
      WHEN LOWER(provider_name) LIKE '%clinic%' THEN 'Clinical Setting'
      WHEN LOWER(provider_name) LIKE '%center%' THEN 'Treatment Center'
      WHEN LOWER(provider_name) LIKE '%health%' THEN 'Healthcare Facility'
      ELSE 'Other Treatment Facility'
    END AS facility_type,
    
    -- Current vs historical providers
    CASE 
      WHEN medicare_id_effective_date >= DATE_SUB(CURRENT_DATE(), 365) THEN 'New Provider'
      ELSE 'Established Provider' 
    END AS provider_status,
    
    *
  FROM mimi_ws_1.datacmsgov.otpp
  WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.otpp)
)

SELECT
  facility_type,
  provider_status,
  COUNT(DISTINCT npi) as provider_count,
  COUNT(DISTINCT state) as states_served,
  ROUND(AVG(DATEDIFF(CURRENT_DATE(), medicare_id_effective_date))) as avg_days_enrolled
FROM provider_categories
GROUP BY facility_type, provider_status
ORDER BY provider_count DESC;

-- How this works:
-- 1. Creates categories based on provider name patterns to identify facility types
-- 2. Labels providers as new or established based on enrollment date
-- 3. Aggregates metrics by facility type and status
-- 4. Only uses most recent data snapshot via _input_file_date filter

-- Assumptions & Limitations:
-- - Facility type categorization based on name patterns may not be 100% accurate
-- - New vs established provider cutoff at 1 year is somewhat arbitrary
-- - Does not account for facilities that may have changed names/categories
-- - Simple text matching may miss some specialized facility types

-- Possible Extensions:
-- 1. Add more granular facility type categories based on additional keywords
-- 2. Include geographic analysis of facility types by state/region
-- 3. Analyze correlation between facility types and longevity in program
-- 4. Compare facility type distributions in urban vs rural areas
-- 5. Track changes in facility type mix over time using historical snapshots

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:16:14.621981
    - Additional Notes: The facility type classification logic relies on keyword matching in provider names which may need periodic updates to maintain accuracy as new naming patterns emerge. Consider enhancing the CASE logic with additional keywords or implementing a more sophisticated classification system for production use.
    
    */