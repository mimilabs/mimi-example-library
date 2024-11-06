-- Hospital GME Program Growth and Capacity Analysis
-- 
-- Business Purpose:
-- Examines teaching hospitals' expansion patterns and capacity utilization over time
-- by analyzing year-over-year changes in resident counts and bed utilization.
-- This helps identify growing/shrinking programs and capacity constraints
-- to inform workforce planning and resource allocation decisions.

WITH base_metrics AS (
  SELECT 
    fiscal_year,
    hospital_name,
    st,
    num_of_beds,
    num_of_dme_ftes,
    total_dme_resident_cap,
    -- Calculate capacity utilization
    ROUND(num_of_dme_ftes / NULLIF(total_dme_resident_cap, 0) * 100, 1) as cap_utilization_pct,
    -- Calculate residents per bed ratio
    ROUND(num_of_dme_ftes / NULLIF(num_of_beds, 0), 2) as residents_per_bed,
    gme as total_medicare_payments
  FROM mimi_ws_1.grahamcenter.gme
  WHERE fiscal_year >= 2018  -- Focus on recent years
    AND num_of_beds > 0      -- Exclude invalid records
),

yearly_changes AS (
  SELECT 
    fiscal_year,
    COUNT(DISTINCT hospital_name) as total_hospitals,
    SUM(num_of_dme_ftes) as total_residents,
    AVG(cap_utilization_pct) as avg_cap_utilization,
    AVG(residents_per_bed) as avg_residents_per_bed,
    SUM(total_medicare_payments) / 1000000 as total_payments_millions
  FROM base_metrics
  GROUP BY fiscal_year
)

SELECT 
  fiscal_year,
  total_hospitals,
  total_residents,
  ROUND(avg_cap_utilization, 1) as avg_cap_utilization_pct,
  ROUND(avg_residents_per_bed, 2) as avg_residents_per_bed,
  ROUND(total_payments_millions, 1) as total_payments_millions
FROM yearly_changes
ORDER BY fiscal_year;

-- How this works:
-- 1. base_metrics CTE calculates key program metrics for each hospital-year
-- 2. yearly_changes CTE aggregates these metrics by fiscal year
-- 3. Final query formats and presents the yearly trends

-- Assumptions & Limitations:
-- - Assumes num_of_beds > 0 represents valid hospital records
-- - Does not account for hospital mergers/closures
-- - Medicare payments may not represent total GME funding
-- - Cap utilization calculation assumes caps are accurately reported

-- Possible Extensions:
-- 1. Add state-level grouping to identify regional patterns
-- 2. Include year-over-year growth rates
-- 3. Segment analysis by hospital size or teaching intensity
-- 4. Add forecasting of future capacity needs
-- 5. Compare primary vs non-primary care program growth

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:53:31.102540
    - Additional Notes: The query focuses on institutional capacity metrics (bed utilization and resident counts) rather than financial aspects. The 2018 cutoff year should be adjusted based on data currency. Consider adding hospital size classification logic for more granular analysis.
    
    */