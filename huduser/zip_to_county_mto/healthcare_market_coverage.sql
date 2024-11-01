-- Title: Healthcare Market Coverage Analysis Using ZIP-County Relationships
-- 
-- Business Purpose:
-- This analysis helps healthcare organizations understand their market coverage and
-- opportunities by analyzing the residential population distribution across counties.
-- Key use cases:
-- - Network adequacy assessment for managed care organizations
-- - Market expansion planning for healthcare providers
-- - Population health program targeting
-- - Service area analysis for CMS submissions

-- Main Query
WITH county_summary AS (
  -- Calculate county-level metrics
  SELECT 
    county,
    usps_zip_pref_state as state,
    COUNT(DISTINCT zip) as zip_count,
    ROUND(AVG(res_ratio), 3) as avg_residential_ratio,
    SUM(CASE WHEN res_ratio > 0.7 THEN 1 ELSE 0 END) as high_res_zip_count
  FROM mimi_ws_1.huduser.zip_to_county_mto
  GROUP BY county, usps_zip_pref_state
),

state_summary AS (
  -- Calculate state-level benchmarks
  SELECT 
    state,
    AVG(zip_count) as state_avg_zips_per_county,
    AVG(avg_residential_ratio) as state_avg_res_ratio
  FROM county_summary
  GROUP BY state
)

SELECT 
  cs.state,
  cs.county,
  cs.zip_count,
  cs.avg_residential_ratio,
  cs.high_res_zip_count,
  ROUND(cs.zip_count / ss.state_avg_zips_per_county, 2) as zip_coverage_index,
  ROUND(cs.avg_residential_ratio / ss.state_avg_res_ratio, 2) as residential_density_index
FROM county_summary cs
JOIN state_summary ss ON cs.state = ss.state
WHERE cs.zip_count >= 5  -- Focus on counties with meaningful ZIP coverage
ORDER BY cs.state, cs.zip_count DESC;

-- How this query works:
-- 1. Creates county_summary CTE to aggregate ZIP-level data to county level
-- 2. Creates state_summary CTE to establish state-level benchmarks
-- 3. Joins these together to create relative market coverage metrics
-- 4. Filters for counties with at least 5 ZIPs to focus on meaningful markets

-- Assumptions and Limitations:
-- - Residential ratio is used as a proxy for population density
-- - Analysis assumes current ZIP-county relationships are stable
-- - Does not account for demographic or socioeconomic factors
-- - May not reflect recent municipal boundary changes

-- Possible Extensions:
-- 1. Add healthcare facility counts per county for provider density analysis
-- 2. Include Medicare/Medicaid beneficiary data for program-specific targeting
-- 3. Incorporate drive time/distance analysis for network adequacy
-- 4. Add year-over-year trending for growing/shrinking markets
-- 5. Include metropolitan statistical area (MSA) classification

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:38:33.664295
    - Additional Notes: The query uses composite metrics (zip_coverage_index and residential_density_index) to identify high-potential healthcare markets. The threshold of 5 ZIPs per county may need adjustment based on specific regional characteristics. Consider adding population data for more accurate market sizing.
    
    */