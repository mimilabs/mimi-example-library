-- fqhc_service_area_coverage.sql

-- Business Purpose:
-- Analyze FQHC geographic service area coverage to identify:
-- 1. Areas with multiple FQHCs potentially serving same populations
-- 2. Geographic distribution of ownership types across states
-- 3. Potential service gaps or overlaps in FQHC coverage
-- This helps inform healthcare access planning and resource allocation

WITH owner_summary AS (
  -- Get latest ownership data per FQHC
  SELECT 
    organization_name,
    state_owner,
    COUNT(DISTINCT associate_id) as fqhc_count,
    COUNT(DISTINCT associate_id_owner) as unique_owners,
    SUM(CASE WHEN type_owner = 'I' THEN 1 ELSE 0 END) as individual_owners,
    SUM(CASE WHEN type_owner = 'O' THEN 1 ELSE 0 END) as org_owners
  FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
  WHERE state_owner IS NOT NULL
  GROUP BY organization_name, state_owner
)

SELECT
  state_owner,
  COUNT(DISTINCT organization_name) as total_fqhcs,
  SUM(fqhc_count) as total_locations,
  ROUND(AVG(unique_owners), 2) as avg_owners_per_fqhc,
  SUM(individual_owners) as total_individual_owners,
  SUM(org_owners) as total_org_owners,
  -- Calculate service concentration
  ROUND(SUM(fqhc_count)::FLOAT / COUNT(DISTINCT organization_name), 2) as locations_per_fqhc
FROM owner_summary
GROUP BY state_owner
ORDER BY total_fqhcs DESC
LIMIT 20;

-- How it works:
-- 1. Creates CTE to summarize ownership patterns per FQHC organization and state
-- 2. Aggregates data to state level to show coverage metrics
-- 3. Calculates key ratios for service area analysis
-- 4. Limits to top 20 states by FQHC count for initial review

-- Assumptions & Limitations:
-- - Uses state_owner as proxy for service area
-- - Assumes current ownership data is representative
-- - Does not account for actual patient service areas
-- - Limited to high-level geographic analysis

-- Possible Extensions:
-- 1. Add county-level analysis for more granular coverage assessment
-- 2. Include population data to calculate FQHC per capita ratios
-- 3. Add year-over-year comparison to track coverage changes
-- 4. Incorporate quality metrics to assess service effectiveness
-- 5. Add distance calculations between FQHC locations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:55:17.784669
    - Additional Notes: Query focuses on FQHC density and ownership distribution at state level. Consider that the locations_per_fqhc metric may be influenced by state population density and rural/urban mix, which are not captured in this analysis. The limit of 20 states provides a high-level overview but may need adjustment for comprehensive analysis.
    
    */