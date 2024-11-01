-- Geographic Distribution and Efficiency Analysis of Teaching Hospitals
-- 
-- Business Purpose:
-- This query analyzes the geographic concentration and operational efficiency
-- of teaching hospitals by examining the relationship between bed capacity,
-- resident counts, and Medicare GME payments. This helps healthcare administrators
-- and policymakers understand resource utilization patterns and identify potential
-- areas for program optimization.

WITH recent_data AS (
  -- Get the most recent fiscal year's data
  SELECT DISTINCT fiscal_year 
  FROM mimi_ws_1.grahamcenter.gme
  ORDER BY fiscal_year DESC
  LIMIT 1
),

hospital_metrics AS (
  -- Calculate key efficiency metrics per hospital
  SELECT 
    h.st,
    h.hospital_name,
    h.num_of_beds,
    h.num_of_ime_ftes,
    h.gme,
    -- Calculate residents per bed ratio
    ROUND(CAST(h.num_of_ime_ftes AS FLOAT) / NULLIF(h.num_of_beds, 0), 3) AS residents_per_bed,
    -- Calculate GME payment per resident
    ROUND(h.gme / NULLIF(h.num_of_ime_ftes, 0), 2) AS payment_per_resident
  FROM mimi_ws_1.grahamcenter.gme h
  INNER JOIN recent_data r ON h.fiscal_year = r.fiscal_year
  WHERE h.num_of_beds > 0 
    AND h.num_of_ime_ftes > 0
)

SELECT 
  st,
  COUNT(DISTINCT hospital_name) as num_hospitals,
  ROUND(AVG(num_of_beds), 0) as avg_beds,
  ROUND(AVG(num_of_ime_ftes), 1) as avg_residents,
  ROUND(AVG(residents_per_bed), 3) as avg_residents_per_bed,
  ROUND(AVG(payment_per_resident), 2) as avg_payment_per_resident,
  ROUND(SUM(gme)/1000000, 2) as total_gme_payments_millions
FROM hospital_metrics
GROUP BY st
HAVING num_hospitals >= 3  -- Filter to states with meaningful sample sizes
ORDER BY total_gme_payments_millions DESC;

-- How this query works:
-- 1. Identifies the most recent fiscal year in the dataset
-- 2. Calculates operational metrics for each hospital
-- 3. Aggregates results by state to show geographic patterns
-- 4. Filters to states with at least 3 teaching hospitals for statistical relevance
--
-- Assumptions and Limitations:
-- - Uses IME FTE count as proxy for total residents
-- - Assumes current bed counts are representative of capacity
-- - Limited to states with multiple teaching hospitals
-- - Does not account for hospital size or specialty mix
--
-- Possible Extensions:
-- - Add year-over-year trend analysis
-- - Include specialty mix analysis (primary care vs specialty ratios)
-- - Add urban/rural location analysis
-- - Incorporate quality metrics or patient outcome data
-- - Add hospital ownership type analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:42:02.371927
    - Additional Notes: The query provides geographic efficiency metrics while filtering out hospitals with zero beds or residents to avoid division by zero errors. Results are limited to states with at least 3 teaching hospitals to ensure statistical relevance. The residents_per_bed and payment_per_resident calculations serve as key efficiency indicators for resource allocation analysis.
    
    */