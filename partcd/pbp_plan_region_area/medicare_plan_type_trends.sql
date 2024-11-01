-- Title: Medicare Plan Type Analysis By Year
-- Business Purpose: Analyze the evolution of Medicare plan types offered over time to identify 
-- market trends and shifts in plan design strategies. This helps stakeholders understand:
-- - Changes in plan type distribution
-- - Market entry/exit patterns
-- - Strategic shifts in plan offerings
-- Created: 2024-03-16

WITH plan_summary AS (
    -- Get distinct plan counts by type and year to avoid duplicates from regional entries
    SELECT 
        contract_year,
        pbp_a_plan_type,
        COUNT(DISTINCT CONCAT(contract_id, plan_id)) as plan_count
    FROM mimi_ws_1.partcd.pbp_plan_region_area
    WHERE contract_year >= 2020  -- Focus on recent years
        AND pbp_a_plan_type IS NOT NULL
    GROUP BY 
        contract_year,
        pbp_a_plan_type
),

yearly_totals AS (
    -- Calculate total plans per year for percentage calculation
    SELECT 
        contract_year,
        SUM(plan_count) as total_plans
    FROM plan_summary
    GROUP BY contract_year
)

SELECT 
    ps.contract_year,
    ps.pbp_a_plan_type as plan_type,
    ps.plan_count,
    yt.total_plans,
    ROUND(100.0 * ps.plan_count / yt.total_plans, 2) as percentage_of_total,
    -- Calculate year-over-year growth
    (ps.plan_count - LAG(ps.plan_count) OVER (
        PARTITION BY ps.pbp_a_plan_type 
        ORDER BY ps.contract_year)
    ) as yoy_change
FROM plan_summary ps
JOIN yearly_totals yt ON ps.contract_year = yt.contract_year
ORDER BY 
    ps.contract_year DESC,
    ps.plan_count DESC;

-- How the Query Works:
-- 1. First CTE creates a base summary of unique plans by type and year
-- 2. Second CTE calculates yearly totals for percentage calculations
-- 3. Main query joins these together and adds YoY growth calculations
-- 4. Results are ordered by year and plan count for easy trend spotting

-- Assumptions and Limitations:
-- - Uses contract_id + plan_id as unique plan identifier
-- - Excludes null plan types
-- - Starts from 2020 to focus on recent trends
-- - Assumes plan type classifications are consistent across years

-- Possible Extensions:
-- 1. Add regional breakdown to analyze geographic differences in plan type distribution
-- 2. Include organization type analysis to see which companies favor which plan types
-- 3. Add benefit coverage type dimension to see correlation with plan types
-- 4. Create market concentration metrics by plan type
-- 5. Add comparison of EGHP vs non-EGHP plan type distributions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:31:03.906656
    - Additional Notes: Query provides year-over-year analysis of Medicare plan type distributions. Note that results are most meaningful when comparing complete years, as partial year data may show incomplete plan counts. The YoY change calculation assumes consistent plan type categorization across years.
    
    */