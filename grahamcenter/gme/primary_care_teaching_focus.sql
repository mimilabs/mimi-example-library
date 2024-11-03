-- Teaching Hospital Primary Care Focus Analysis
--
-- Business Purpose: 
-- Analyzes teaching hospitals' emphasis on primary care education by examining the ratio
-- of primary care to total residents and corresponding Medicare funding allocations.
-- This helps identify institutions that are contributing most significantly to
-- addressing primary care physician shortages.

-- Main Query
WITH latest_data AS (
  SELECT DISTINCT fiscal_year
  FROM mimi_ws_1.grahamcenter.gme 
  WHERE fiscal_year > 0
  ORDER BY fiscal_year DESC
  LIMIT 1
)

SELECT 
  hospital_name,
  st AS state,
  -- Calculate primary care focus metrics
  prim_care_fte AS primary_care_residents,
  ROUND(prim_care_fte / NULLIF(prim_care_fte + non_prim_care_fte, 0) * 100, 1) AS primary_care_percentage,
  -- Calculate funding metrics
  ROUND(dme / NULLIF(prim_care_fte + non_prim_care_fte, 0), 0) AS dme_per_resident,
  ROUND(gme / NULLIF(num_of_beds, 0), 0) AS gme_per_bed,
  -- Include key capacity indicators
  num_of_beds AS total_beds,
  prim_care_fte + non_prim_care_fte AS total_residents
FROM mimi_ws_1.grahamcenter.gme g
JOIN latest_data l ON g.fiscal_year = l.fiscal_year
WHERE prim_care_fte > 0  -- Focus on hospitals with primary care programs
ORDER BY primary_care_percentage DESC, total_residents DESC
LIMIT 50;

-- How it works:
-- 1. Identifies the most recent fiscal year in the dataset
-- 2. Calculates primary care concentration and funding efficiency metrics
-- 3. Returns top 50 hospitals ranked by primary care focus and program size
--
-- Assumptions and Limitations:
-- - Assumes current fiscal year data is complete and accurate
-- - Does not account for program quality or outcomes
-- - Limited to hospitals with active primary care programs
-- - Funding metrics may be affected by regional cost variations
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis of primary care focus
-- 2. Include geographic clustering analysis
-- 3. Incorporate quality metrics if available
-- 4. Add filters for hospital size or specific states
-- 5. Compare primary care vs specialty care funding efficiency

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:58:31.526476
    - Additional Notes: Query filters for active primary care programs which may exclude some teaching hospitals. The primary_care_percentage calculation assumes FTE counts are accurate and up-to-date. Performance may be impacted when analyzing very large datasets due to the window function used to find the latest fiscal year.
    
    */