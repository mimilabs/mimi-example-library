-- rhc_ownership_consulting_impact.sql 

-- Business Purpose:
-- Analyze the role of consulting firms in Rural Health Clinic (RHC) operations to understand:
--   - Prevalence of consulting firm ownership/involvement
--   - Average ownership stakes held by consulting firms
--   - Geographic distribution of consultant-owned RHCs
-- This analysis helps identify:
--   1. Markets where consulting expertise is being leveraged
--   2. Potential correlation between consulting involvement and RHC performance
--   3. Opportunities for management service partnerships

WITH consulting_summary AS (
  -- Get base metrics for consulting firm involvement
  SELECT 
    state_owner,
    COUNT(DISTINCT enrollment_id) as total_rhcs,
    COUNT(DISTINCT CASE WHEN consulting_firm_owner = 'Y' THEN enrollment_id END) as consultant_owned_rhcs,
    AVG(CASE WHEN consulting_firm_owner = 'Y' THEN CAST(percentage_ownership AS FLOAT) END) as avg_consultant_ownership_pct
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner)
  GROUP BY state_owner
)

SELECT
  state_owner as state,
  total_rhcs,
  consultant_owned_rhcs,
  ROUND(100.0 * consultant_owned_rhcs / NULLIF(total_rhcs, 0), 1) as pct_consultant_owned,
  ROUND(avg_consultant_ownership_pct, 1) as avg_ownership_stake,
  -- Flag states with high consulting presence
  CASE WHEN (100.0 * consultant_owned_rhcs / NULLIF(total_rhcs, 0)) > 15.0 
       THEN 'High Consulting Presence' 
       ELSE 'Standard Market' END as market_classification
FROM consulting_summary
WHERE state_owner IS NOT NULL
ORDER BY pct_consultant_owned DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate consulting firm ownership metrics by state
-- 2. Calculates key metrics including percentage of consultant-owned RHCs
-- 3. Classifies markets based on consulting firm presence
-- 4. Uses the most recent data snapshot via mimi_src_file_date filter

-- Assumptions and Limitations:
-- - Relies on accurate flagging of consulting firm ownership
-- - Does not account for indirect consulting involvement through management agreements
-- - Cannot determine the impact of consulting ownership on RHC performance
-- - Limited to direct ownership relationships

-- Possible Extensions:
-- 1. Add temporal analysis to track consulting firm ownership trends
-- 2. Cross-reference with RHC performance metrics if available
-- 3. Include analysis of consulting firms' role combinations (ownership + management)
-- 4. Segment analysis by RHC size or rural vs. frontier locations
-- 5. Compare consulting ownership patterns with other facility types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:55:54.429950
    - Additional Notes: Query focuses on state-level analysis of consulting firm ownership in RHCs, using most recent data snapshot. Results may be incomplete if consulting relationships are not properly flagged in source data. Percentages will be null for states with zero RHCs.
    
    */