-- Medicare Assistance Device Utilization and ADL Limitations Analysis
-- Business Purpose: This query analyzes assistive device usage patterns and their relationship to activities of daily living (ADL) limitations to:
-- 1. Guide medical equipment coverage decisions and inventory planning
-- 2. Identify opportunities for expanding home health support services
-- 3. Inform care management programs about key mobility and independence needs
-- 4. Support medical device manufacturers in product development and market sizing

WITH device_usage AS (
  -- Summarize assistive device usage by beneficiary
  SELECT 
    surveyyr,
    puf_id,
    SUM(CASE WHEN pufs049 = 1 THEN 1 ELSE 0 END) as uses_cane,
    SUM(CASE WHEN pufs050 = 1 THEN 1 ELSE 0 END) as uses_walker,
    SUM(CASE WHEN pufs051 = 1 THEN 1 ELSE 0 END) as uses_wheelchair,
    SUM(CASE WHEN pufs052 = 1 THEN 1 ELSE 0 END) as uses_scooter,
    SUM(CASE WHEN pufs053 = 1 THEN 1 ELSE 0 END) as uses_oxygen,
    SUM(CASE WHEN pufs054 = 1 THEN 1 ELSE 0 END) as uses_hospital_bed,
    COUNT(*) as total_devices_used
  FROM mimi_ws_1.datacmsgov.mcbs_summer
  GROUP BY surveyyr, puf_id
),

adl_summary AS (
  -- Calculate ADL limitation metrics
  SELECT
    surveyyr,
    puf_id,
    pufs047 as num_adl_difficulties,
    CASE 
      WHEN pufs013 IN (1,2) THEN 'Good to Excellent'
      WHEN pufs013 IN (3,4,5) THEN 'Fair to Poor'
      ELSE 'Unknown'
    END as health_status
  FROM mimi_ws_1.datacmsgov.mcbs_summer
)

SELECT
  d.surveyyr,
  a.health_status,
  COUNT(DISTINCT d.puf_id) as beneficiary_count,
  AVG(d.total_devices_used) as avg_devices_per_person,
  AVG(CAST(a.num_adl_difficulties AS FLOAT)) as avg_adl_difficulties,
  SUM(d.uses_cane) / COUNT(*) * 100 as pct_using_cane,
  SUM(d.uses_walker) / COUNT(*) * 100 as pct_using_walker,
  SUM(d.uses_wheelchair) / COUNT(*) * 100 as pct_using_wheelchair,
  SUM(d.uses_oxygen) / COUNT(*) * 100 as pct_using_oxygen
FROM device_usage d
JOIN adl_summary a ON d.puf_id = a.puf_id AND d.surveyyr = a.surveyyr
GROUP BY d.surveyyr, a.health_status
ORDER BY d.surveyyr DESC, a.health_status;

-- How it works:
-- 1. First CTE aggregates assistive device usage by beneficiary
-- 2. Second CTE summarizes ADL limitations and health status
-- 3. Main query joins these together to analyze relationships between device usage, ADL limitations and health status
-- 4. Results show trends over time and patterns by health status group

-- Assumptions and Limitations:
-- - Assumes device usage is accurately self-reported
-- - Limited to devices explicitly tracked in survey
-- - Does not account for multiple devices of same type
-- - May undercount temporary device usage

-- Possible Extensions:
-- 1. Add geographic analysis by census region
-- 2. Include cost analysis using claims data
-- 3. Segment by age groups or specific conditions
-- 4. Add analysis of unmet device needs
-- 5. Create predictive model for future device needs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:20:51.631061
    - Additional Notes: Query focuses on mobility and medical device usage patterns correlated with ADL limitations. Weight factors (pufswgt) are not currently applied but may be needed for accurate population-level estimates. The health status categorization is simplified into two main groups and may need refinement based on specific analysis needs.
    
    */