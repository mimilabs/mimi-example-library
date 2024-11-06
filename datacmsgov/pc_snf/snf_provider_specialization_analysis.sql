-- Title: SNF Provider Type Classification and Specialty Focus Analysis

-- Business Purpose:
-- This analysis examines the provider type distribution across SNFs to:
-- 1. Understand the specialization patterns in SNF services
-- 2. Identify potential gaps in specialized care availability
-- 3. Help healthcare organizations target service expansion opportunities
-- 4. Support strategic planning for specialized care programs

WITH provider_type_summary AS (
  -- Calculate counts and percentages for each provider type
  SELECT 
    provider_type_code,
    provider_type_text,
    COUNT(*) as facility_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage,
    COUNT(DISTINCT state) as states_present,
    COUNT(DISTINCT npi) as unique_providers
  FROM mimi_ws_1.datacmsgov.pc_snf
  WHERE provider_type_code IS NOT NULL
  GROUP BY 1, 2
),

state_coverage AS (
  -- Analyze state-level distribution of provider types
  SELECT 
    state,
    COUNT(DISTINCT provider_type_code) as unique_provider_types,
    COUNT(*) as total_facilities
  FROM mimi_ws_1.datacmsgov.pc_snf
  GROUP BY 1
)

-- Combine results with state coverage insights
SELECT 
  p.provider_type_code,
  p.provider_type_text,
  p.facility_count,
  p.percentage as pct_of_total_facilities,
  p.states_present,
  p.unique_providers,
  ROUND(p.facility_count / p.states_present, 2) as avg_facilities_per_state,
  -- Identify provider types with broad vs concentrated geographic presence
  CASE 
    WHEN p.states_present >= 40 THEN 'Nationwide'
    WHEN p.states_present >= 25 THEN 'Regional'
    ELSE 'Limited'
  END as geographic_presence
FROM provider_type_summary p
ORDER BY p.facility_count DESC;

-- How this query works:
-- 1. Creates a summary of provider types with counts and percentages
-- 2. Analyzes state-level distribution separately
-- 3. Combines the information to show both volume and geographic spread
-- 4. Categorizes provider types based on their geographic presence

-- Assumptions and Limitations:
-- 1. Assumes provider_type_code and provider_type_text are relatively stable
-- 2. Does not account for seasonal variations in facility operations
-- 3. Geographic presence categorization thresholds are arbitrary and may need adjustment
-- 4. Does not consider population density or demographic needs

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating incorporation_date
-- 2. Include proprietary_nonprofit status to analyze ownership patterns
-- 3. Cross-reference with demographic data to identify underserved areas
-- 4. Add facility size metrics if available
-- 5. Incorporate quality metrics to assess performance by provider type
-- 6. Include zip code level analysis for more granular geographic insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:19:10.100217
    - Additional Notes: The query focuses on provider type distribution patterns and may need index optimization for large datasets. Geographic presence thresholds (40 states for nationwide, 25 for regional) should be adjusted based on specific business requirements. Consider adding WHERE clauses to filter specific time periods if analyzing temporal patterns.
    
    */