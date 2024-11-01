-- Hospital Patient Care Capability Analysis
-- 
-- Business Purpose:
-- - Assess hospitals' comprehensive patient care capabilities through their service unit mix
-- - Identify facilities offering both acute and long-term care services
-- - Support strategic planning for healthcare networks and payers
-- - Guide referral network development based on service capabilities

WITH service_mix AS (
  -- Calculate service offering combinations per hospital
  SELECT 
    organization_name,
    state,
    proprietary_nonprofit,
    CASE WHEN subgroup_acute_care = 'Y' THEN 1 ELSE 0 END +
    CASE WHEN subgroup_longterm = 'Y' THEN 1 ELSE 0 END + 
    CASE WHEN subgroup_rehabilitation = 'Y' THEN 1 ELSE 0 END AS service_count,
    subgroup_acute_care,
    subgroup_longterm,
    subgroup_rehabilitation
  FROM mimi_ws_1.datacmsgov.pc_hospital
  WHERE organization_name IS NOT NULL
)

SELECT 
  state,
  proprietary_nonprofit AS ownership_type,
  -- Count facilities by service mix
  COUNT(*) as total_facilities,
  SUM(CASE WHEN service_count >= 2 THEN 1 ELSE 0 END) as multi_service_facilities,
  -- Calculate key service combinations
  SUM(CASE WHEN subgroup_acute_care = 'Y' AND subgroup_longterm = 'Y' THEN 1 ELSE 0 END) as acute_longterm_combo,
  SUM(CASE WHEN subgroup_acute_care = 'Y' AND subgroup_rehabilitation = 'Y' THEN 1 ELSE 0 END) as acute_rehab_combo,
  -- Calculate percentages for analysis
  ROUND(100.0 * SUM(CASE WHEN service_count >= 2 THEN 1 ELSE 0 END) / COUNT(*), 1) as pct_multi_service
FROM service_mix
GROUP BY state, proprietary_nonprofit
HAVING COUNT(*) >= 5  -- Focus on states with meaningful facility counts
ORDER BY total_facilities DESC, state;

-- How this query works:
-- 1. Creates a CTE to classify hospitals based on their service offerings
-- 2. Aggregates facilities by state and ownership type
-- 3. Calculates key metrics around service combinations
-- 4. Filters for statistically meaningful sample sizes
-- 5. Orders results to highlight largest markets first

-- Assumptions and Limitations:
-- - Service flags accurately reflect actual service delivery
-- - Minimum threshold of 5 facilities per state/ownership group
-- - Focus on acute, long-term, and rehab services as key indicators
-- - Current snapshot only - no historical trends

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating incorporation_date
-- 2. Include geographic clustering analysis using zip_code
-- 3. Correlate service mix with market demographics
-- 4. Add financial status analysis using proprietary/nonprofit status
-- 5. Incorporate bed count data if available in related tables

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:20:14.109621
    - Additional Notes: Query focuses on core service combinations (acute/long-term/rehab) and may not reflect full range of specialized services. Results are most meaningful for larger states with multiple facilities. Consider adding bed capacity metrics for more detailed analysis of service delivery capabilities.
    
    */