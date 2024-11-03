-- top_zip_residential_market_segmentation.sql
-- =====================================================================
-- Business Purpose: 
-- This query identifies key ZIP codes with concentrated residential populations
-- across multiple Census tracts, helping target market outreach and network
-- development strategies. It reveals areas where residential addresses are
-- highly concentrated, suggesting dense population centers that may require
-- focused healthcare services and resources.
--
-- Key metrics:
-- - Total residential ratio across tracts
-- - Number of associated Census tracts per ZIP
-- - Average residential ratio per ZIP
-- - State-level market concentration
-- =====================================================================

WITH zip_summary AS (
  -- Calculate key metrics per ZIP code
  SELECT 
    zip,
    usps_zip_pref_state as state,
    COUNT(DISTINCT tract) as tract_count,
    SUM(res_ratio) as total_res_ratio,
    AVG(res_ratio) as avg_res_ratio
  FROM mimi_ws_1.huduser.zip_to_tract_otm
  GROUP BY zip, usps_zip_pref_state
),

state_rankings AS (
  -- Rank ZIPs within each state by residential concentration
  SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY total_res_ratio DESC) as state_rank,
    COUNT(*) OVER (PARTITION BY state) as zips_in_state
  FROM zip_summary
  WHERE tract_count >= 2  -- Focus on ZIPs with multiple tracts
)

SELECT 
  state,
  zip,
  tract_count,
  ROUND(total_res_ratio, 3) as total_res_ratio,
  ROUND(avg_res_ratio, 3) as avg_res_ratio,
  state_rank,
  zips_in_state
FROM state_rankings 
WHERE state_rank <= 10  -- Top 10 ZIPs per state
ORDER BY state, state_rank;

-- =====================================================================
-- How this query works:
-- 1. First CTE (zip_summary) aggregates residential metrics by ZIP code
-- 2. Second CTE (state_rankings) adds state-level rankings
-- 3. Final output shows top 10 residential ZIPs per state
--
-- Assumptions and limitations:
-- - Focuses only on residential ratios, not business or other address types
-- - Requires multiple Census tracts per ZIP for meaningful analysis
-- - Current threshold of top 10 per state may need adjustment
-- - Does not account for seasonal population variations
--
-- Possible extensions:
-- 1. Add population density metrics from Census data
-- 2. Include year-over-year comparison of residential ratios
-- 3. Incorporate demographic data for targeted program development
-- 4. Add geographic clustering analysis for regional planning
-- 5. Compare residential vs business ratio patterns
-- =====================================================================

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:02:04.610372
    - Additional Notes: Query optimizes for identifying high-density residential ZIP codes at the state level, particularly useful for market planning and resource allocation. Note that the minimum threshold of 2 tracts per ZIP may need adjustment based on specific geographic analysis needs, and the top 10 limit per state could be parameterized for different granularity requirements.
    
    */