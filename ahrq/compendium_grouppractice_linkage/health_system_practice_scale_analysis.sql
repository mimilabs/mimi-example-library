-- Title: Health System Group Practice Size and Distribution Analysis

-- Business Purpose:
-- This query analyzes the scale and geographic distribution of physician group practices
-- across health systems to understand:
-- 1. Market concentration of healthcare delivery
-- 2. Provider workforce composition (physicians vs advanced practice providers)
-- 3. Regional presence of health systems
-- This information is valuable for strategic planning, market analysis, and care delivery optimization.

WITH practice_metrics AS (
  -- Calculate key metrics for each health system
  SELECT 
    health_sys_id,
    health_sys_name,
    state_md_ppas,
    COUNT(DISTINCT tin_name) as practice_count,
    SUM(md_do_md_ppas) as total_physicians,
    SUM(np_pa_md_ppas) as total_advanced_practitioners,
    SUM(service_lines_md_ppas) as total_service_lines
  FROM mimi_ws_1.ahrq.compendium_grouppractice_linkage
  WHERE health_sys_id IS NOT NULL 
    AND ma_only_tin = 0  -- Exclude Medicare Advantage only practices
  GROUP BY health_sys_id, health_sys_name, state_md_ppas
)

SELECT 
  health_sys_name,
  state_md_ppas,
  practice_count,
  total_physicians,
  total_advanced_practitioners,
  ROUND(total_advanced_practitioners::FLOAT / NULLIF(total_physicians,0), 2) as app_to_physician_ratio,
  total_service_lines,
  ROUND(total_service_lines::FLOAT / NULLIF(total_physicians,0), 0) as services_per_physician
FROM practice_metrics
WHERE total_physicians > 0  -- Focus on active systems with physicians
ORDER BY total_physicians DESC
LIMIT 50;

-- How it works:
-- 1. Creates a CTE to aggregate metrics at the health system and state level
-- 2. Calculates key operational ratios (APP to physician, services per physician)
-- 3. Filters for meaningful comparisons (active systems with physicians)
-- 4. Orders by total physicians to show largest systems first

-- Assumptions and Limitations:
-- 1. Relies on accuracy of physician and APP counts in source data
-- 2. Excludes Medicare Advantage only practices which may undercount some systems
-- 3. Service line counts may vary by billing practices
-- 4. Point-in-time snapshot based on source data date

-- Possible Extensions:
-- 1. Add year-over-year comparison by incorporating mimi_src_file_date
-- 2. Include geographic concentration analysis using state distribution
-- 3. Add market share calculations using service_lines
-- 4. Incorporate practice size tiers for segmentation analysis
-- 5. Add comparison to regional/national benchmarks
-- 6. Include analysis of independent practices (where health_sys_id is null)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:12:34.238357
    - Additional Notes: Query focuses on operational scale metrics of health systems by aggregating their affiliated physician practices. Results are limited to top 50 systems by physician count. Medicare Advantage-only practices are excluded. Service line metrics may need adjustment based on specific analysis needs as billing practices can vary significantly across systems.
    
    */