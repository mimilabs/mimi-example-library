
-- File: health_system_market_penetration_analysis.sql
-- Business Purpose: 
-- Analyze health system market penetration and geographic reach by evaluating 
-- the distribution of outpatient sites across different corporate parents, 
-- metropolitan areas, and healthcare market characteristics. This analysis 
-- helps strategic planning teams understand competitive positioning and 
-- potential expansion opportunities.

WITH market_penetration_metrics AS (
    -- Calculate site distribution metrics for each corporate parent
    SELECT 
        corp_parent_name,
        COUNT(DISTINCT compendium_os_id) AS total_outpatient_sites,
        COUNT(DISTINCT os_state) AS states_served,
        COUNT(DISTINCT cbsa_code) AS metro_areas_served,
        SUM(CASE WHEN rural_nonmsa = 1 THEN 1 ELSE 0 END) AS rural_sites,
        SUM(os_mds) AS total_physicians,
        
        -- Market concentration indicators
        ROUND(
            COUNT(DISTINCT compendium_os_id) * 100.0 / 
            (SELECT COUNT(DISTINCT compendium_os_id) FROM mimi_ws_1.ahrq.compendium_outpatient_linkage), 
            2
        ) AS market_site_percentage,
        
        -- Healthcare access metrics
        ROUND(
            SUM(CASE WHEN mua = 1 OR mup = 1 OR pchpsa = 1 THEN 1 ELSE 0 END) * 100.0 / 
            COUNT(DISTINCT compendium_os_id), 
            2
        ) AS underserved_site_percentage

    FROM mimi_ws_1.ahrq.compendium_outpatient_linkage
    WHERE corp_parent_name IS NOT NULL
    GROUP BY corp_parent_name
)

-- Rank corporate parents by market penetration and site diversity
SELECT 
    corp_parent_name,
    total_outpatient_sites,
    states_served,
    metro_areas_served,
    rural_sites,
    total_physicians,
    market_site_percentage,
    underserved_site_percentage,
    
    RANK() OVER (ORDER BY total_outpatient_sites DESC) AS site_count_rank,
    RANK() OVER (ORDER BY states_served DESC) AS geographic_reach_rank

FROM market_penetration_metrics
ORDER BY total_outpatient_sites DESC
LIMIT 50;

-- Query Execution Details:
-- 1. Calculates comprehensive market penetration metrics for each corporate parent
-- 2. Provides insights into geographic reach, site distribution, and healthcare access
-- 3. Ranks corporate parents by site count and geographic coverage

-- Key Assumptions:
-- - Data represents a specific time period snapshot
-- - Corporate parent information is complete and accurate
-- - Rural/underserved site indicators are reliable

-- Potential Extensions:
-- 1. Add time-series analysis to track market penetration changes
-- 2. Incorporate revenue or patient volume data for deeper insights
-- 3. Develop predictive models for market expansion strategies


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:25:24.633124
    - Additional Notes: Query provides a strategic view of healthcare corporate parent market distribution, analyzing site count, geographic reach, and healthcare access metrics. Useful for strategic planning and competitive market analysis.
    
    */