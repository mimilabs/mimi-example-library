-- Title: Medicare Advantage Plan Geographic Premium Concentration Analysis

/* 
Business Purpose:
Analyze the geographic concentration and premium characteristics of Medicare Advantage plans 
to provide insights for:
- Healthcare market strategy development
- Competitive intelligence for insurance providers
- Regional healthcare coverage planning
- Identifying potential market expansion opportunities
*/

WITH plan_premium_summary AS (
    -- Aggregate premium and plan details by state and county
    SELECT 
        state,
        county,
        organization_type,
        plan_type,
        COUNT(DISTINCT plan_id) AS total_plans,
        AVG(part_c_premium) AS avg_part_c_premium,
        AVG(part_d_total_premium) AS avg_part_d_total_premium,
        AVG(overall_star_rating) AS avg_star_rating,
        SUM(CASE WHEN special_needs_plan = 'Yes' THEN 1 ELSE 0 END) AS special_needs_plan_count
    FROM mimi_ws_1.partcd.landscape_plan_premium_report
    WHERE part_c_premium IS NOT NULL 
      AND part_d_total_premium IS NOT NULL
    GROUP BY 
        state, 
        county, 
        organization_type, 
        plan_type
),

premium_concentration AS (
    -- Identify areas with high plan density and premium variations
    SELECT 
        state,
        county,
        organization_type,
        plan_type,
        total_plans,
        avg_part_c_premium,
        avg_part_d_total_premium,
        avg_star_rating,
        special_needs_plan_count,
        NTILE(4) OVER (ORDER BY avg_part_c_premium) AS premium_quartile
    FROM plan_premium_summary
)

-- Primary analysis query
SELECT 
    state,
    COUNT(DISTINCT county) AS counties_covered,
    SUM(total_plans) AS total_plans_in_state,
    ROUND(AVG(avg_part_c_premium), 2) AS state_avg_part_c_premium,
    ROUND(AVG(avg_part_d_total_premium), 2) AS state_avg_part_d_total_premium,
    ROUND(AVG(avg_star_rating), 2) AS state_avg_star_rating,
    SUM(special_needs_plan_count) AS total_special_needs_plans,
    premium_quartile
FROM premium_concentration
GROUP BY 
    state, 
    premium_quartile
ORDER BY 
    total_plans_in_state DESC, 
    state_avg_part_c_premium DESC
LIMIT 50;

/* 
Query Functionality:
- Aggregates Medicare Advantage plan data at state and county levels
- Calculates key metrics: plan count, average premiums, star ratings
- Provides insights into geographic plan distribution and pricing

Assumptions and Limitations:
- Uses most recent data snapshot from the source file
- Assumes data completeness and accuracy
- Limited to plans with non-null premium information

Potential Query Extensions:
1. Add temporal analysis comparing year-over-year changes
2. Incorporate more granular organization type breakdowns
3. Include additional filtering for specific plan characteristics
4. Develop predictive models for premium trends
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:02:38.711053
    - Additional Notes: Query provides comprehensive geographic breakdown of Medicare Advantage plan characteristics, focusing on state-level premium, plan count, and star rating insights. Useful for market research and strategic planning in healthcare insurance.
    
    */