-- Health System Financial Performance and Market Presence Analysis
-- ========================================== 
-- Business Purpose: Analyze health systems' financial performance and market footprint to understand:
-- - Revenue generation and financial scale
-- - Geographic reach and market presence
-- - Ownership model correlation with financial metrics
-- - System complexity indicators (multistate operations, facility counts)

WITH system_financials AS (
    SELECT 
        health_sys_name,
        health_sys_state,
        sys_multistate,
        sys_ownership,
        -- Calculate key financial metrics
        ROUND(hos_net_revenue/1000000, 2) as net_revenue_millions,
        ROUND(hos_total_revenue/1000000, 2) as total_revenue_millions,
        -- Calculate operational scale metrics
        hosp_cnt,
        grp_cnt,
        -- Determine market presence indicators
        CASE 
            WHEN sys_multistate = 1 THEN 'Single State'
            WHEN sys_multistate = 2 THEN 'Two States'
            WHEN sys_multistate = 3 THEN 'Three+ States'
        END as geographic_reach,
        -- Map ownership types
        CASE sys_ownership
            WHEN 1 THEN 'Nonprofit'
            WHEN 2 THEN 'Church-operated'
            WHEN 3 THEN 'Public/Government'
            WHEN 5 THEN 'For-profit'
        END as ownership_type
    FROM mimi_ws_1.ahrq.compendium_us_health_systems
    WHERE hos_net_revenue > 0  -- Focus on systems with reported financials
)

SELECT 
    ownership_type,
    geographic_reach,
    COUNT(*) as system_count,
    ROUND(AVG(net_revenue_millions), 2) as avg_net_revenue_millions,
    ROUND(AVG(total_revenue_millions), 2) as avg_total_revenue_millions,
    ROUND(AVG(hosp_cnt), 1) as avg_hospital_count,
    ROUND(AVG(grp_cnt), 1) as avg_practice_group_count
FROM system_financials
GROUP BY ownership_type, geographic_reach
ORDER BY ownership_type, geographic_reach;

-- How this query works:
-- 1. Creates a CTE to prepare and transform key financial and operational metrics
-- 2. Calculates averages and counts grouped by ownership type and geographic reach
-- 3. Focuses on systems with valid financial reporting
-- 4. Provides a clear view of how system size and financial performance vary by ownership and geography

-- Assumptions and limitations:
-- - Assumes hos_net_revenue > 0 represents valid financial reporting
-- - Limited to systems that report financial data
-- - Geographic reach categories are simplified into three groups
-- - Ownership types are from reported hospital-level data

-- Possible extensions:
-- 1. Add year-over-year growth analysis if historical data is available
-- 2. Include market concentration analysis by state/region
-- 3. Add patient volume metrics (sys_dsch) to calculate revenue per discharge
-- 4. Incorporate insurance product offerings (sys_anyins_product) for vertical integration analysis
-- 5. Add analysis of teaching status impact on financial performance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:33:48.193609
    - Additional Notes: Query provides financial performance metrics segmented by ownership type and geographic reach, but requires systems to have valid financial reporting (non-zero net revenue). Revenue values are converted to millions for readability. Results are particularly useful for comparing business models across different types of health systems.
    
    */