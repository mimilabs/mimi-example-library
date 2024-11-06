-- teaching_hospital_impact_analysis.sql
-- 
-- Business Purpose:
-- Analyze the impact of teaching hospitals on Medicare spending by examining
-- Graduate Medical Education (GME) and Indirect Medical Education (IME) payments
-- This analysis helps:
-- 1. Understand the distribution of teaching hospital resources
-- 2. Identify areas that may need additional teaching hospital support
-- 3. Assess the financial impact of medical education on Medicare spending
--

WITH ranked_counties AS (
  SELECT 
    state,
    county,
    part_a_enrollment,
    part_a_ime,
    part_a_gme,
    -- Calculate teaching-related payments per enrollee
    ROUND(COALESCE(part_a_ime + part_a_gme, 0) / NULLIF(part_a_enrollment, 0), 2) as teaching_payment_per_enrollee,
    -- Calculate percentage of total Part A spending that goes to teaching
    ROUND(100.0 * (COALESCE(part_a_ime + part_a_gme, 0)) / NULLIF(part_a_total_reimbursement, 0), 2) as teaching_pct_of_total
  FROM mimi_ws_1.cmspayment.ffs_data
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.cmspayment.ffs_data)
    AND part_a_enrollment > 1000  -- Focus on counties with significant Medicare population
    AND (part_a_ime > 0 OR part_a_gme > 0)  -- Only include counties with teaching hospitals
),

summary_stats AS (
  SELECT 
    state,
    COUNT(DISTINCT county) as counties_with_teaching,
    ROUND(AVG(teaching_payment_per_enrollee), 2) as avg_teaching_payment,
    ROUND(AVG(teaching_pct_of_total), 2) as avg_teaching_pct
  FROM ranked_counties
  GROUP BY state
)

SELECT 
  s.*,
  RANK() OVER (ORDER BY avg_teaching_payment DESC) as teaching_payment_rank
FROM summary_stats s
WHERE counties_with_teaching >= 2  -- Focus on states with multiple teaching hospital locations
ORDER BY avg_teaching_payment DESC
LIMIT 20;

--
-- How this query works:
-- 1. First CTE identifies counties with teaching hospitals and calculates key metrics
-- 2. Second CTE aggregates to state level for broader patterns
-- 3. Final query ranks states by teaching hospital investment
--
-- Assumptions and limitations:
-- - Assumes teaching payments (IME + GME) indicate presence of teaching hospitals
-- - Limited to counties with >1000 Medicare enrollees for statistical significance
-- - Most recent data only; historical trends not included
-- - Does not account for hospital size or program quality
--
-- Possible extensions:
-- 1. Add year-over-year trending to track changes in teaching hospital investment
-- 2. Include Part B data to see full scope of academic medical center impact
-- 3. Cross-reference with physician shortage areas
-- 4. Add demographic factors to identify underserved populations
-- 5. Compare teaching vs non-teaching hospital costs in same geography

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:41:19.700858
    - Additional Notes: Query specifically focuses on Medicare's academic medicine footprint through IME/GME payments. Excludes smaller counties (<1000 enrollees) and may undercount teaching impacts in states with just one major academic medical center due to the two-county minimum filter. Best used for high-level strategic planning around academic medicine resource distribution.
    
    */