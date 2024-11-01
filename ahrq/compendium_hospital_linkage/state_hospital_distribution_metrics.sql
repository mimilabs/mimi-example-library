-- Title: Geographic Distribution and Concentration of Hospital Resources Analysis

-- Business Purpose:
-- This analysis examines the regional distribution of hospital resources and market concentration
-- by state. This helps:
-- 1. Identify underserved areas and potential expansion opportunities
-- 2. Understand market dynamics for strategic planning
-- 3. Support healthcare access equity initiatives
-- 4. Guide resource allocation decisions

WITH state_metrics AS (
    -- Calculate key metrics by state
    SELECT 
        hospital_state,
        COUNT(DISTINCT health_sys_id) as num_health_systems,
        COUNT(DISTINCT compendium_hospital_id) as num_hospitals,
        SUM(hos_beds) as total_beds,
        ROUND(AVG(hos_beds), 0) as avg_beds_per_hospital,
        SUM(hos_dsch) as total_discharges,
        -- Calculate market concentration - hospitals per health system
        ROUND(COUNT(DISTINCT compendium_hospital_id)::FLOAT / 
              NULLIF(COUNT(DISTINCT health_sys_id), 0), 2) as hospitals_per_system
    FROM mimi_ws_1.ahrq.compendium_hospital_linkage
    WHERE hospital_state IS NOT NULL 
    AND acutehosp_flag = 1  -- Focus on acute care hospitals
    GROUP BY hospital_state
),
state_rankings AS (
    -- Add rankings for key metrics
    SELECT *,
        RANK() OVER (ORDER BY total_beds DESC) as rank_by_beds,
        RANK() OVER (ORDER BY hospitals_per_system DESC) as rank_by_concentration
    FROM state_metrics
)
SELECT 
    hospital_state as state,
    num_health_systems,
    num_hospitals,
    total_beds,
    avg_beds_per_hospital,
    total_discharges,
    hospitals_per_system as market_concentration,
    rank_by_beds as bed_capacity_rank,
    rank_by_concentration as concentration_rank
FROM state_rankings
ORDER BY total_beds DESC;

-- How it works:
-- 1. First CTE aggregates key metrics by state
-- 2. Second CTE adds rankings for comparative analysis
-- 3. Final query presents results ordered by total bed capacity

-- Assumptions and Limitations:
-- 1. Focuses only on acute care hospitals (acutehosp_flag = 1)
-- 2. Assumes current data represents typical market conditions
-- 3. Does not account for population differences between states
-- 4. Market concentration metric may oversimplify complex relationships

-- Possible Extensions:
-- 1. Add population-adjusted metrics using census data
-- 2. Include year-over-year trend analysis
-- 3. Add geographic clustering analysis for multi-state health systems
-- 4. Incorporate financial metrics for market value assessment
-- 5. Add competitive intensity metrics based on hospital proximity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:26:04.338457
    - Additional Notes: Query provides state-level healthcare market analysis with focus on resource distribution and market concentration. Note that results may need population adjustment for meaningful state-to-state comparisons. Consider running this analysis for specific regions or timeframes by adding appropriate WHERE clauses.
    
    */