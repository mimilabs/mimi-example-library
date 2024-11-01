-- Title: ZIP Code Market Concentration Analysis

-- Business Purpose:
-- Identifies concentrated markets where a small number of ZIP codes account for 
-- a large portion of residential addresses within counties. This analysis helps:
-- 1. Target marketing campaigns efficiently
-- 2. Optimize resource allocation for service delivery
-- 3. Identify high-impact geographic areas for business development

-- Main Query
WITH ranked_zips AS (
  -- Get latest data and calculate significance of each ZIP within its county
  SELECT 
    county,
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    res_ratio,
    -- Rank ZIPs within each county by residential concentration
    ROW_NUMBER() OVER (PARTITION BY county ORDER BY res_ratio DESC) as zip_rank,
    -- Running total of residential coverage
    SUM(res_ratio) OVER (PARTITION BY county ORDER BY res_ratio DESC) as cumulative_coverage
  FROM mimi_ws_1.huduser.county_to_zip 
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.county_to_zip)
),

county_summary AS (
  -- Identify counties where top 3 ZIPs cover >50% of residential addresses
  SELECT 
    county,
    COUNT(zip) as total_zips,
    SUM(CASE WHEN zip_rank <= 3 THEN res_ratio ELSE 0 END) as top3_coverage
  FROM ranked_zips
  GROUP BY county
  HAVING top3_coverage > 0.50
)

-- Final output showing concentrated markets
SELECT 
  r.county,
  r.zip,
  r.usps_zip_pref_city,
  r.usps_zip_pref_state,
  ROUND(r.res_ratio * 100, 1) as pct_county_coverage,
  r.zip_rank,
  s.total_zips as county_total_zips,
  ROUND(s.top3_coverage * 100, 1) as top3_pct_coverage
FROM ranked_zips r
JOIN county_summary s ON r.county = s.county
WHERE r.zip_rank <= 3
ORDER BY s.top3_coverage DESC, r.county, r.zip_rank;

-- How it works:
-- 1. First CTE ranks ZIP codes within each county by residential address concentration
-- 2. Second CTE identifies counties where top 3 ZIPs account for >50% of addresses
-- 3. Final query joins these together to show detailed breakdown of concentrated markets

-- Assumptions and Limitations:
-- 1. Uses residential address ratio as primary metric
-- 2. Focuses only on most recent data snapshot
-- 3. Assumes ZIP code boundaries are stable
-- 4. May not reflect seasonal population variations

-- Possible Extensions:
-- 1. Add year-over-year comparison to track market concentration trends
-- 2. Include business ratio analysis for commercial market concentration
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Incorporate demographic data to profile high-concentration areas
-- 5. Create market penetration opportunity scores based on concentration metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:23:44.169862
    - Additional Notes: Query identifies geographic markets where a few ZIP codes dominate the residential coverage of a county (>50% coverage by top 3 ZIPs). Best used for targeting high-impact areas and optimizing resource allocation. Results are based on latest available data snapshot only.
    
    */