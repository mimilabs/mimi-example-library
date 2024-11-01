-- SNF Financial Performance Analysis - Operating Costs vs Revenue
-- ================================================================

-- Business Purpose:
-- ---------------
-- This query analyzes the financial performance of Skilled Nursing Facilities by:
-- - Identifying facilities with complete cost and revenue reporting
-- - Calculating key financial ratios
-- - Highlighting potential operational efficiency opportunities
-- - Supporting strategic planning and benchmarking

WITH base_facilities AS (
  -- Get facilities with complete financial reporting
  SELECT DISTINCT 
    rpt_rec_num,
    MAX(CASE WHEN wksht_cd = 'G0' AND line_num = 1 AND clmn_num = 1 
        THEN itm_alphnmrc_itm_txt END) as facility_name,
    MAX(CASE WHEN wksht_cd = 'G0' AND line_num = 2 AND clmn_num = 1 
        THEN itm_alphnmrc_itm_txt END) as provider_number
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
  WHERE wksht_cd = 'G0'
  GROUP BY rpt_rec_num
),

operating_costs AS (
  -- Extract total operating costs
  SELECT DISTINCT
    rpt_rec_num, 
    SUM(CASE WHEN wksht_cd = 'G2' AND line_num = 24 AND clmn_num = 1 
        THEN CAST(itm_alphnmrc_itm_txt AS FLOAT) ELSE 0 END) as total_operating_costs
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha 
  WHERE wksht_cd = 'G2'
  GROUP BY rpt_rec_num
),

total_revenue AS (
  -- Extract total revenue
  SELECT DISTINCT
    rpt_rec_num,
    SUM(CASE WHEN wksht_cd = 'G3' AND line_num = 1 AND clmn_num = 1 
        THEN CAST(itm_alphnmrc_itm_txt AS FLOAT) ELSE 0 END) as total_revenue
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
  WHERE wksht_cd = 'G3'
  GROUP BY rpt_rec_num
)

SELECT 
  f.facility_name,
  f.provider_number,
  c.total_operating_costs,
  r.total_revenue,
  ROUND((r.total_revenue - c.total_operating_costs) / NULLIF(r.total_revenue, 0) * 100, 2) as operating_margin_pct,
  ROUND(c.total_operating_costs / NULLIF(r.total_revenue, 0) * 100, 2) as cost_to_revenue_ratio_pct
FROM base_facilities f
LEFT JOIN operating_costs c ON f.rpt_rec_num = c.rpt_rec_num
LEFT JOIN total_revenue r ON f.rpt_rec_num = r.rpt_rec_num
WHERE r.total_revenue > 0 
  AND c.total_operating_costs > 0
ORDER BY operating_margin_pct DESC;

-- How the Query Works:
-- ------------------
-- 1. Creates CTE for base facility information from worksheet G0
-- 2. Extracts operating costs from worksheet G2
-- 3. Extracts revenue data from worksheet G3
-- 4. Joins the data and calculates key financial ratios
-- 5. Filters for facilities with valid financial data

-- Assumptions & Limitations:
-- ------------------------
-- - Assumes worksheets G0, G2, and G3 contain valid data
-- - Limited to facilities reporting both costs and revenue
-- - Does not account for one-time expenses or revenue
-- - Simple ratio analysis may not capture full financial complexity

-- Possible Extensions:
-- ------------------
-- 1. Add trend analysis by including reporting periods
-- 2. Break down costs by department or cost center
-- 3. Include quality metrics to analyze cost vs quality
-- 4. Add geographic analysis for regional benchmarking
-- 5. Incorporate bed size for size-adjusted comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:12:16.202248
    - Additional Notes: Query focuses on core profitability metrics using G-series worksheets. Results may be affected by reporting inconsistencies across facilities and should be validated against actual financial statements. Operating margin calculations assume standard cost reporting practices and may not reflect facility-specific accounting methods.
    
    */