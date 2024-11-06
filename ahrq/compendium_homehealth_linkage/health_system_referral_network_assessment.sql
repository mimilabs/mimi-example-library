
-- Home Health Organization Referral Network Value Assessment
-- Business Purpose:
-- Quantify potential patient referral volume and strategic network connectivity
-- Identify high-value health systems with extensive home health organization partnerships
-- Support strategic planning for healthcare network expansion and service integration

WITH home_health_system_summary AS (
    -- Aggregate home health organization metrics per health system
    SELECT 
        health_sys_name,
        health_sys_state,
        COUNT(DISTINCT compendium_hh_id) AS total_home_health_orgs,
        COUNT(DISTINCT home_health_care_org_type) AS unique_service_types,
        COUNT(DISTINCT corp_parent_id) AS distinct_corporate_parents,
        
        -- Calculate potential referral network complexity
        CASE 
            WHEN COUNT(DISTINCT compendium_hh_id) > 10 THEN 'High Complexity'
            WHEN COUNT(DISTINCT compendium_hh_id) BETWEEN 5 AND 10 THEN 'Medium Complexity'
            ELSE 'Low Complexity'
        END AS referral_network_complexity
    
    FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
    WHERE health_sys_name IS NOT NULL
    GROUP BY health_sys_name, health_sys_state
),

network_value_ranking AS (
    -- Rank health systems by referral network potential
    SELECT 
        health_sys_name,
        health_sys_state,
        total_home_health_orgs,
        unique_service_types,
        referral_network_complexity,
        RANK() OVER (ORDER BY total_home_health_orgs DESC) AS network_size_rank
    
    FROM home_health_system_summary
)

-- Final output highlighting strategic network insights
SELECT 
    health_sys_name,
    health_sys_state,
    total_home_health_orgs,
    unique_service_types,
    referral_network_complexity,
    network_size_rank
FROM network_value_ranking
WHERE network_size_rank <= 25
ORDER BY total_home_health_orgs DESC, unique_service_types DESC;

-- Query Mechanics:
-- 1. Aggregates home health organization data by health system
-- 2. Calculates network complexity based on organization count
-- 3. Ranks health systems by total home health organizations
-- 4. Outputs top 25 systems with highest referral potential

-- Assumptions and Limitations:
-- - Assumes geographic proximity implies referral likelihood
-- - Relies on current snapshot of health system affiliations
-- - May not capture informal or recent partnership arrangements

-- Potential Extensions:
-- 1. Incorporate patient volume estimates
-- 2. Add financial performance metrics
-- 3. Analyze referral patterns by service type


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:11:07.445603
    - Additional Notes: Provides strategic insights into home health organization networks, focusing on referral complexity and potential. Requires periodic updates to maintain relevance of network mapping.
    
    */