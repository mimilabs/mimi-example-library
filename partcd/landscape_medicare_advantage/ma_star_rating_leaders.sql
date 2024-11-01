-- Medicare Advantage Star Rating and Market Coverage Analysis
-- Business Purpose: 
-- This analysis helps healthcare organizations and policymakers understand:
-- 1. Plan quality distribution through star ratings across different plan types
-- 2. Market penetration of high-performing plans (4+ stars)
-- 3. Competitive landscape for quality-based performance
-- Key stakeholders: Health plan executives, Provider networks, Policy makers

WITH star_rating_summary AS (
    -- Aggregate star ratings by plan type and organization
    SELECT 
        type_of_medicare_health_plan,
        organization_name,
        COUNT(DISTINCT contract_id) as total_contracts,
        COUNT(DISTINCT CASE WHEN overall_star_rating >= 4 THEN contract_id END) as high_performing_contracts,
        ROUND(AVG(overall_star_rating), 2) as avg_star_rating,
        COUNT(DISTINCT state) as states_served
    FROM mimi_ws_1.partcd.landscape_medicare_advantage
    WHERE overall_star_rating IS NOT NULL 
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.landscape_medicare_advantage)
    GROUP BY 1, 2
),

org_rankings AS (
    -- Rank organizations by high-performing contracts
    SELECT 
        *,
        RANK() OVER (PARTITION BY type_of_medicare_health_plan 
                     ORDER BY high_performing_contracts DESC) as rank_in_type
    FROM star_rating_summary
    WHERE total_contracts >= 5  -- Focus on organizations with meaningful presence
)

-- Final output combining key metrics
SELECT 
    type_of_medicare_health_plan as plan_type,
    organization_name,
    total_contracts,
    high_performing_contracts,
    ROUND(100.0 * high_performing_contracts / total_contracts, 1) as pct_high_performing,
    avg_star_rating,
    states_served,
    rank_in_type
FROM org_rankings
WHERE rank_in_type <= 5  -- Top 5 organizations per plan type
ORDER BY plan_type, rank_in_type;

-- How this query works:
-- 1. First CTE aggregates star rating metrics by plan type and organization
-- 2. Second CTE ranks organizations within each plan type
-- 3. Final query presents top performers with key quality metrics

-- Assumptions and Limitations:
-- 1. Uses most recent data snapshot only
-- 2. Requires organizations to have at least 5 contracts for meaningful comparison
-- 3. Star ratings are treated as numeric values
-- 4. Null star ratings are excluded

-- Possible Extensions:
-- 1. Add year-over-year trending of star ratings
-- 2. Include premium analysis for high-performing plans
-- 3. Add geographic concentration analysis
-- 4. Incorporate beneficiary enrollment data if available
-- 5. Add market share analysis by star rating tiers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:13:18.317740
    - Additional Notes: Query focuses on quality leadership across Medicare Advantage plan types, requiring minimum of 5 contracts per organization for inclusion. Star rating calculations exclude plans with null ratings. Results show top 5 organizations per plan type based on high-performing contracts (4+ stars).
    
    */