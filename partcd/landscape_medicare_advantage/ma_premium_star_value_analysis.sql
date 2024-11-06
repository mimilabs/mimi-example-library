-- Medicare Advantage Premium Tier and Star Rating Impact Analysis
--
-- Business Purpose:
-- This analysis helps Medicare Advantage organizations and healthcare strategists understand:
-- 1. Distribution of plans across premium tiers and their correlation with star ratings
-- 2. Market positioning opportunities based on premium-quality relationships
-- 3. Premium strategy effectiveness in different regions
-- 4. Quality-cost trade-offs in plan design

WITH premium_tiers AS (
    SELECT 
        organization_name,
        type_of_medicare_health_plan,
        state,
        CASE 
            WHEN monthly_consolidated_premium_includes_part_c_d = 0 THEN 'Zero Premium'
            WHEN monthly_consolidated_premium_includes_part_c_d <= 50 THEN 'Low Premium ($1-50)'
            WHEN monthly_consolidated_premium_includes_part_c_d <= 100 THEN 'Medium Premium ($51-100)'
            ELSE 'High Premium (>$100)'
        END as premium_tier,
        overall_star_rating,
        COUNT(*) as plan_count,
        AVG(monthly_consolidated_premium_includes_part_c_d) as avg_premium,
        AVG(CAST(overall_star_rating as FLOAT)) as avg_star_rating
    FROM mimi_ws_1.partcd.landscape_medicare_advantage
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.landscape_medicare_advantage)
        AND overall_star_rating IS NOT NULL
    GROUP BY 1,2,3,4,5
)

SELECT 
    organization_name,
    state,
    premium_tier,
    type_of_medicare_health_plan,
    plan_count,
    ROUND(avg_premium, 2) as avg_premium,
    ROUND(avg_star_rating, 2) as avg_star_rating,
    -- Calculate market positioning score
    ROUND((avg_star_rating * 100) / NULLIF(avg_premium + 1, 0), 2) as value_score
FROM premium_tiers
WHERE plan_count >= 3  -- Focus on significant market presence
ORDER BY value_score DESC, plan_count DESC
LIMIT 100;

-- How this query works:
-- 1. Creates premium tiers based on monthly premium ranges
-- 2. Aggregates plans by organization, state, and premium tier
-- 3. Calculates average premiums and star ratings for each group
-- 4. Computes a value score that balances quality (stars) against cost (premium)
-- 5. Filters for meaningful market presence (3+ plans)

-- Assumptions and limitations:
-- 1. Uses most recent data snapshot only
-- 2. Assumes star ratings are comparable across different plan types
-- 3. Simplified premium tier categorization
-- 4. Value score is a basic metric that may need refinement
-- 5. Excludes plans without star ratings

-- Possible extensions:
-- 1. Add year-over-year premium tier migration analysis
-- 2. Include drug benefit type analysis within premium tiers
-- 3. Add geographic market concentration metrics
-- 4. Incorporate MOOP analysis for total cost perspective
-- 5. Add competitor analysis within premium tiers
-- 6. Compare value scores across different market types (urban vs rural)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:08:23.825670
    - Additional Notes: Query focuses on value proposition analysis by combining premium tiers with star ratings. The value_score metric provides a simplified way to identify plans that balance quality and cost. Consider adjusting the plan_count >= 3 filter based on specific market analysis needs.
    
    */