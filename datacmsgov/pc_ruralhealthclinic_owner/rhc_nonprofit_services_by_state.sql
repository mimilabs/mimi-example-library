-- rhc_nonprofit_services_analysis.sql

-- Business Purpose:
-- Analyze the prevalence and characteristics of non-profit RHC ownership to understand:
--   - Distribution of non-profit vs for-profit ownership models
--   - Geographic footprint of non-profit RHCs 
--   - Relationships between non-profit status and management/consulting services
-- Value for: Healthcare strategy teams, Policy makers, Non-profit healthcare networks

WITH nonprofit_summary AS (
  -- Get current snapshot of non-profit RHC ownership
  SELECT 
    state_owner,
    COUNT(DISTINCT enrollment_id) as total_rhcs,
    COUNT(DISTINCT CASE WHEN non_profit_owner = 'Y' THEN enrollment_id END) as nonprofit_rhcs,
    COUNT(DISTINCT CASE WHEN management_services_company_owner = 'Y' 
          AND non_profit_owner = 'Y' THEN enrollment_id END) as nonprofit_with_mgmt,
    COUNT(DISTINCT CASE WHEN consulting_firm_owner = 'Y' 
          AND non_profit_owner = 'Y' THEN enrollment_id END) as nonprofit_with_consulting
  FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic_owner)
  GROUP BY state_owner
)

SELECT
  state_owner,
  total_rhcs,
  nonprofit_rhcs,
  ROUND(100.0 * nonprofit_rhcs / total_rhcs, 1) as pct_nonprofit,
  nonprofit_with_mgmt,
  nonprofit_with_consulting,
  ROUND(100.0 * (nonprofit_with_mgmt + nonprofit_with_consulting) / nonprofit_rhcs, 1) 
    as pct_nonprofit_with_services
FROM nonprofit_summary
WHERE total_rhcs > 0
ORDER BY total_rhcs DESC;

-- How it works:
-- 1. Creates CTE to summarize RHC ownership metrics by state
-- 2. Filters to most recent data snapshot using mimi_src_file_date
-- 3. Calculates percentages of non-profit ownership and service utilization
-- 4. Returns state-level summary sorted by total RHC count

-- Assumptions & Limitations:
-- - Relies on accurate reporting of non-profit status
-- - Management and consulting relationships may be underreported
-- - Does not account for changes over time
-- - State-level analysis may mask local patterns

-- Possible Extensions:
-- 1. Add time series analysis to track non-profit growth trends
-- 2. Include additional service relationships like staffing/medical providers
-- 3. Analyze correlation between non-profit status and ownership percentages
-- 4. Compare rural vs urban distribution of non-profit RHCs
-- 5. Examine differences in ownership duration between profit/non-profit models

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:13:28.215341
    - Additional Notes: The query focuses on state-level non-profit RHC distribution and their use of management/consulting services. Key metrics include percentage of non-profit ownership and service utilization rates. For states with small RHC counts, percentages may be less meaningful due to small sample sizes.
    
    */