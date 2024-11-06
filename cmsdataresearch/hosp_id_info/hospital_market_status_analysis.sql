-- hospital_operational_status_cost_insights.sql
-- Business Purpose: Analyze hospital operational status to understand market dynamics, 
-- potential investment opportunities, and healthcare infrastructure trends

WITH hospital_status_summary AS (
    -- Group hospitals by operational status and control type
    SELECT 
        status, 
        ctrl_type, 
        COUNT(DISTINCT provider_number) AS total_hospitals,
        COUNT(DISTINCT state) AS states_represented
    FROM mimi_ws_1.cmsdataresearch.hosp_id_info
    GROUP BY status, ctrl_type
),

regional_status_distribution AS (
    -- Analyze status distribution by state to identify regional healthcare market variations
    SELECT 
        state, 
        status, 
        COUNT(DISTINCT provider_number) AS hospital_count,
        ROUND(COUNT(DISTINCT provider_number) / SUM(COUNT(DISTINCT provider_number)) OVER (PARTITION BY state) * 100, 2) AS percent_of_state_hospitals
    FROM mimi_ws_1.cmsdataresearch.hosp_id_info
    GROUP BY state, status
)

-- Primary query to extract actionable market insights
SELECT 
    hss.status,
    hss.ctrl_type,
    hss.total_hospitals,
    hss.states_represented,
    rsd.state,
    rsd.hospital_count AS state_hospital_count,
    rsd.percent_of_state_hospitals
FROM hospital_status_summary hss
JOIN regional_status_distribution rsd ON hss.status = rsd.status
WHERE hss.total_hospitals > 10  -- Focus on statistically significant groups
ORDER BY hss.total_hospitals DESC, rsd.hospital_count DESC
LIMIT 100;

-- Query Mechanics:
-- 1. Creates a summary of hospital operational status and control type
-- 2. Calculates state-level hospital status distribution
-- 3. Joins summaries to provide comprehensive market insights

-- Assumptions and Limitations:
-- - Data represents a specific snapshot in time
-- - Assumes provider_number is unique identifier
-- - May not capture real-time hospital status changes

-- Potential Extensions:
-- 1. Add time-series analysis of hospital status changes
-- 2. Incorporate additional financial or performance metrics
-- 3. Create predictive models for hospital market trends

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:14:51.484778
    - Additional Notes: Query provides insights into hospital operational status across different control types and states. Uses two Common Table Expressions (CTEs) to analyze hospital distribution and regional variations. Recommended for strategic healthcare market research and infrastructure planning.
    
    */