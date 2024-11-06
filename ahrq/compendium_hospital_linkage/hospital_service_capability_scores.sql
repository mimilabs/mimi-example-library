-- Title: Critical Hospital Service Capabilities Analysis

-- Business Purpose:
-- Identifies hospitals with comprehensive service capabilities based on key operational metrics.
-- This analysis helps:
-- 1. Healthcare investors evaluate potential acquisition targets
-- 2. Insurance networks identify high-capability providers for network inclusion
-- 3. Health system executives benchmark their facilities against peers

SELECT 
    -- Core identifiers
    ccn,
    hospital_name,
    health_sys_name,
    hospital_state,
    
    -- Calculate composite service capability score
    CASE 
        WHEN hos_majteach = 1 THEN 2
        WHEN hos_res > 0 THEN 1 
        ELSE 0 
    END +
    CASE 
        WHEN hos_beds > 300 THEN 2
        WHEN hos_beds > 100 THEN 1
        ELSE 0
    END +
    CASE 
        WHEN hos_highdpp = 1 THEN 1
        ELSE 0
    END as capability_score,
    
    -- Key operational metrics
    hos_beds as total_beds,
    hos_res as resident_count,
    hos_dsch as annual_discharges,
    hos_ownership as ownership_type,
    hos_net_revenue as net_revenue

FROM mimi_ws_1.ahrq.compendium_hospital_linkage

-- Focus on acute care hospitals with complete data
WHERE acutehosp_flag = 1
    AND hos_beds IS NOT NULL 
    AND hos_dsch IS NOT NULL
    AND hos_net_revenue IS NOT NULL

-- Order by capability score and size
ORDER BY capability_score DESC, hos_beds DESC
LIMIT 100;

-- How the Query Works:
-- 1. Creates a composite capability score (0-5) based on:
--    - Teaching status (0-2 points)
--    - Hospital size by beds (0-2 points)
--    - High DSH status (0-1 points)
-- 2. Includes key operational metrics for context
-- 3. Filters for acute care hospitals with complete data
-- 4. Returns top 100 hospitals by capability score and size

-- Assumptions and Limitations:
-- 1. Assumes teaching status, bed size, and DSH status are key indicators of capability
-- 2. Limited to hospitals with complete data
-- 3. Scoring system is simplified and could be refined
-- 4. Current year data only - no temporal analysis

-- Possible Extensions:
-- 1. Add geographic clustering analysis
-- 2. Include financial performance metrics
-- 3. Compare system vs independent hospital capabilities
-- 4. Add specialty service line indicators
-- 5. Create peer groups for more nuanced benchmarking

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:42:54.605463
    - Additional Notes: The capability scoring system weighs teaching status (0-2), bed capacity (0-2), and DSH status (0-1) equally in determining overall hospital capability. Consider adjusting these weights based on specific analytical needs. The 100-record limit may need adjustment for comprehensive analysis.
    
    */