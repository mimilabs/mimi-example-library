-- TITLE: FQHC Business Model and Service-Area Demographics Analysis

-- BUSINESS PURPOSE:
-- This analysis examines the relationship between FQHC business models and their service areas to:
-- - Compare urban vs rural FQHC service delivery strategies
-- - Identify relationships between business structures and service area characteristics
-- - Surface potential opportunities for optimizing healthcare delivery based on location
-- - Support strategic planning for new FQHC locations and service expansions

WITH urban_rural_classification AS (
  -- First classify locations as urban or rural based on city population density
  SELECT 
    state,
    city,
    COUNT(DISTINCT enrollment_id) as fqhc_count,
    CASE 
      WHEN COUNT(DISTINCT enrollment_id) >= 5 THEN 'Urban'
      ELSE 'Rural'
    END as location_type
  FROM mimi_ws_1.datacmsgov.pc_fqhc
  GROUP BY state, city
),

business_model_metrics AS (
  -- Analyze business model characteristics by location
  SELECT
    f.state,
    f.city,
    ur.location_type,
    f.organization_type_structure,
    f.proprietary_nonprofit,
    COUNT(DISTINCT f.enrollment_id) as facility_count,
    COUNT(DISTINCT f.npi) as unique_npi_count,
    COUNT(DISTINCT f.ccn) as unique_ccn_count
  FROM mimi_ws_1.datacmsgov.pc_fqhc f
  JOIN urban_rural_classification ur 
    ON f.state = ur.state 
    AND f.city = ur.city
  GROUP BY 
    f.state,
    f.city,
    ur.location_type,
    f.organization_type_structure,
    f.proprietary_nonprofit
)

-- Final analysis combining location and business characteristics
SELECT
  state,
  location_type,
  organization_type_structure,
  proprietary_nonprofit,
  COUNT(DISTINCT city) as served_cities,
  SUM(facility_count) as total_facilities,
  ROUND(AVG(unique_npi_count), 2) as avg_npis_per_city,
  ROUND(AVG(unique_ccn_count), 2) as avg_ccns_per_city
FROM business_model_metrics
GROUP BY 
  state,
  location_type,
  organization_type_structure,
  proprietary_nonprofit
ORDER BY 
  state,
  location_type,
  total_facilities DESC;

-- HOW IT WORKS:
-- 1. Creates an urban/rural classification based on FQHC density in each city
-- 2. Analyzes business model patterns including organization type and profit status
-- 3. Combines location and business characteristics to identify strategic patterns
-- 4. Provides metrics on service coverage and facility concentration

-- ASSUMPTIONS AND LIMITATIONS:
-- - Urban/rural classification is simplified based on FQHC count
-- - Does not account for population size or specific demographics
-- - Current quarter snapshot only - no historical trends
-- - Geographic boundaries may not perfectly align with service areas

-- POSSIBLE EXTENSIONS:
-- 1. Add demographic data to refine urban/rural classification
-- 2. Include distance calculations between facilities
-- 3. Incorporate time-based analysis using incorporation_date
-- 4. Add patient outcome metrics if available
-- 5. Include analysis of specific services offered
-- 6. Correlate with local healthcare market competition data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:36:17.934416
    - Additional Notes: The urban/rural classification threshold of 5 FQHCs per city is a simplified proxy that may need adjustment based on specific market conditions. Consider local population data for more accurate classifications. The query's performance may be impacted when analyzing large metropolitan areas with many facilities.
    
    */