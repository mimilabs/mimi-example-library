-- Network Tier Pricing Strategy Analysis
-- Business Purpose:
-- - Analyze network tier distribution to inform pricing and plan design
-- - Identify opportunities for value-based contracting
-- - Support competitive analysis of provider network structures
-- - Guide member engagement strategies based on provider access levels

-- Main Query
WITH tier_metrics AS (
    -- Calculate network tier distributions and provider counts
    SELECT 
        plan_id,
        network_tier,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT provider_type) as provider_type_count,
        -- Calculate percentage of providers in each tier
        COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER(PARTITION BY plan_id) as tier_percentage
    FROM mimi_ws_1.datahealthcaregov.provider_plans
    WHERE array_contains(years, YEAR(CURRENT_DATE)) -- Modified to handle array type
    GROUP BY plan_id, network_tier
),

plan_summary AS (
    -- Summarize plan-level metrics
    SELECT 
        plan_id,
        COUNT(DISTINCT network_tier) as tier_count,
        COUNT(DISTINCT npi) as total_providers
    FROM mimi_ws_1.datahealthcaregov.provider_plans
    WHERE array_contains(years, YEAR(CURRENT_DATE)) -- Modified to handle array type
    GROUP BY plan_id
)

-- Combine metrics for final analysis
SELECT 
    t.plan_id,
    t.network_tier,
    t.provider_count,
    t.provider_type_count,
    ROUND(t.tier_percentage, 2) as tier_percentage,
    p.tier_count as total_tiers,
    p.total_providers
FROM tier_metrics t
JOIN plan_summary p ON t.plan_id = p.plan_id
WHERE t.provider_count >= 100 -- Focus on significant provider networks
ORDER BY t.plan_id, t.tier_percentage DESC;

-- How this query works:
-- 1. Creates a CTE for tier-level metrics including provider counts and percentages
-- 2. Creates a CTE for plan-level summary metrics
-- 3. Joins the CTEs to produce a comprehensive view of network tier structure
-- 4. Uses array_contains() function to handle the years array field
-- 5. Filters for meaningful networks and sorts by plan and tier percentage

-- Assumptions and Limitations:
-- - Assumes years field is an array of integers
-- - Assumes network_tier field is consistently populated
-- - Limited to current year data
-- - Minimum threshold of 100 providers may need adjustment based on market
-- - Does not account for geographic distribution
-- - Network tier naming conventions may vary across plans

-- Possible Extensions:
-- 1. Add geographic analysis by incorporating provider location data
-- 2. Include trend analysis by comparing tier distributions across multiple years in the array
-- 3. Add provider specialty analysis within tiers
-- 4. Incorporate cost/reimbursement data to analyze tier pricing impacts
-- 5. Compare tier structures across similar plan types or market competitors
-- 6. Add member utilization patterns by network tier

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:47:38.612980
    - Additional Notes: Query focuses on current year network tier distribution patterns to support pricing strategies. Handles years as array type field. Requires minimum provider threshold of 100 which may need adjustment for smaller markets. Results are aggregated at the plan-tier level without geographic segmentation.
    
    */