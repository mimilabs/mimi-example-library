-- Title: Medicare Advantage Employer Group Plan Market Analysis

-- Business Purpose:
-- Analyzes the prevalence and distribution of Employer Group Health Plans (EGHP) 
-- in the Medicare Advantage market to:
-- - Identify markets with high EGHP penetration
-- - Compare EGHP vs non-EGHP plan characteristics
-- - Support strategic decisions about employer partnerships
-- - Guide market expansion strategies

WITH eghp_summary AS (
    -- Calculate EGHP metrics by state
    SELECT 
        stcd,
        contract_year,
        COUNT(DISTINCT CASE WHEN eghp_flag = 'Y' THEN contract_id END) as eghp_contracts,
        COUNT(DISTINCT contract_id) as total_contracts,
        COUNT(DISTINCT CASE WHEN eghp_flag = 'Y' THEN county_code END) as eghp_counties,
        COUNT(DISTINCT county_code) as total_counties,
        COUNT(DISTINCT CASE WHEN eghp_flag = 'Y' THEN plan_id END) as eghp_plans,
        COUNT(DISTINCT plan_id) as total_plans
    FROM mimi_ws_1.partcd.pbp_plan_area
    WHERE contract_year >= 2022
    GROUP BY stcd, contract_year
)

SELECT 
    stcd as state_code,
    contract_year,
    eghp_contracts,
    total_contracts,
    ROUND(eghp_contracts * 100.0 / total_contracts, 1) as eghp_contract_pct,
    eghp_counties,
    total_counties,
    ROUND(eghp_counties * 100.0 / total_counties, 1) as eghp_county_coverage_pct,
    eghp_plans,
    total_plans,
    ROUND(eghp_plans * 100.0 / total_plans, 1) as eghp_plan_pct
FROM eghp_summary
WHERE total_contracts >= 5  -- Filter for meaningful market size
ORDER BY eghp_contract_pct DESC, state_code;

-- How it works:
-- 1. Creates a CTE to aggregate EGHP metrics by state and year
-- 2. Calculates distinct counts of contracts, counties, and plans for both EGHP and overall
-- 3. Computes percentage metrics to show EGHP market penetration
-- 4. Filters for states with meaningful market presence
-- 5. Orders results to highlight states with highest EGHP penetration

-- Assumptions and Limitations:
-- - Assumes eghp_flag accurately identifies employer group plans
-- - Does not account for plan enrollment numbers
-- - May include inactive or pending contracts
-- - Limited to recent years (2022+)

-- Possible Extensions:
-- 1. Add trend analysis by comparing year-over-year changes
-- 2. Include plan type distribution within EGHP vs non-EGHP
-- 3. Incorporate contract organization types
-- 4. Add geographic region groupings for regional analysis
-- 5. Compare partial vs full county coverage patterns
-- 6. Analyze correlation with benefit coverage types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:03:11.742860
    - Additional Notes: Query focuses on state-level EGHP penetration metrics using three key dimensions (contracts, counties, plans). Results are most meaningful for recent years (2022+) and states with at least 5 total contracts. Performance may be impacted when analyzing multiple years simultaneously due to the wide aggregation scope.
    
    */