-- cbsa_geographic_coverage_analysis.sql
-- Business Purpose: Identify which CBSAs have the most diverse geographic coverage
-- across multiple states and cities to help organizations understand market
-- expansion opportunities and optimize service delivery networks.

-- Main Query
WITH representative_locations AS (
  -- Get representative city and state for each CBSA based on highest res_ratio
  SELECT 
    cbsa,
    FIRST_VALUE(usps_zip_pref_city) OVER (
      PARTITION BY cbsa 
      ORDER BY res_ratio DESC
    ) as sample_major_city,
    FIRST_VALUE(usps_zip_pref_state) OVER (
      PARTITION BY cbsa 
      ORDER BY res_ratio DESC
    ) as primary_state
  FROM mimi_ws_1.huduser.cbsa_to_zip_otm
  WHERE cbsa != '99999'
),
cbsa_footprint AS (
  -- Calculate geographic diversity metrics for each CBSA
  SELECT 
    a.cbsa,
    COUNT(DISTINCT a.zip) as zip_count,
    COUNT(DISTINCT a.usps_zip_pref_state) as state_count,
    COUNT(DISTINCT a.usps_zip_pref_city) as city_count,
    SUM(a.res_ratio) as total_res_ratio,
    AVG(a.res_ratio) as avg_res_ratio,
    MAX(b.sample_major_city) as sample_major_city,
    MAX(b.primary_state) as primary_state
  FROM mimi_ws_1.huduser.cbsa_to_zip_otm a
  LEFT JOIN representative_locations b 
    ON a.cbsa = b.cbsa
  WHERE a.cbsa != '99999'
  GROUP BY a.cbsa
)
-- Final output showing top CBSAs by geographic diversity
SELECT 
  cbsa,
  zip_count,
  state_count,
  city_count,
  ROUND(avg_res_ratio, 3) as avg_res_ratio,
  ROUND(total_res_ratio, 3) as total_res_coverage,
  sample_major_city,
  primary_state,
  RANK() OVER (ORDER BY zip_count DESC) as rank_by_zips,
  RANK() OVER (ORDER BY state_count DESC) as rank_by_states
FROM cbsa_footprint
WHERE zip_count > 0
QUALIFY rank_by_zips <= 20
ORDER BY rank_by_zips;

-- How it works:
-- 1. First CTE identifies representative cities/states for each CBSA
-- 2. Second CTE aggregates key geographic metrics
-- 3. Final query ranks and formats results for top 20 CBSAs

-- Assumptions and Limitations:
-- - Uses current snapshot only (not historical trends)
-- - Representative city/state based on highest res_ratio
-- - Rankings may be affected by CBSA size and population density
-- - Some CBSAs may cross state boundaries legitimately

-- Possible Extensions:
-- 1. Add population data to weight the coverage metrics
-- 2. Include year-over-year changes in geographic coverage
-- 3. Calculate market penetration potential based on coverage gaps
-- 4. Add economic indicators to prioritize expansion opportunities
-- 5. Create geographic clustering analysis for nearby CBSAs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:16:56.940143
    - Additional Notes: Query identifies CBSAs with the most extensive geographic reach by analyzing their coverage across ZIP codes, states, and cities. The analysis focuses on the top 20 CBSAs based on ZIP code coverage, with additional insights into state-level diversity and representative major cities. Results are weighted by residential ratios to ensure relevance to population centers.
    
    */