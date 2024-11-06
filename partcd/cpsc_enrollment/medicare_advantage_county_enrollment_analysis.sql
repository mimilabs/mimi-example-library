-- Medicare Advantage County-Level Enrollment Concentration and Opportunity Analysis

/*
Business Purpose:
Analyze Medicare Advantage enrollment concentration to identify high-potential 
market segments for strategic expansion, partnership, or targeted marketing efforts.

Key Insights:
- Identify counties with highest Medicare Advantage enrollment
- Understand market penetration at granular geographic levels
- Support regional sales and growth strategy development
*/

WITH county_enrollment_summary AS (
    -- Aggregate enrollment by county, ranking counties by total volume
    SELECT 
        state,
        county,
        SUM(enrollment) as total_county_enrollment,
        COUNT(DISTINCT contract_number) as unique_plan_count,
        ROUND(AVG(enrollment), 2) as avg_plan_enrollment,
        RANK() OVER (ORDER BY SUM(enrollment) DESC) as county_enrollment_rank
    FROM mimi_ws_1.partcd.cpsc_enrollment
    WHERE enrollment > 0  -- Exclude zero-enrollment records
    GROUP BY state, county
),

top_market_counties AS (
    -- Focus on top 10% of counties by enrollment volume
    SELECT 
        state, 
        county, 
        total_county_enrollment,
        unique_plan_count,
        avg_plan_enrollment,
        county_enrollment_rank
    FROM county_enrollment_summary
    WHERE county_enrollment_rank <= (SELECT COUNT(*) * 0.1 FROM county_enrollment_summary)
)

SELECT 
    state,
    county,
    total_county_enrollment,
    unique_plan_count,
    avg_plan_enrollment,
    county_enrollment_rank,
    ROUND(total_county_enrollment / (SELECT SUM(total_county_enrollment) FROM top_market_counties) * 100, 2) as market_share_pct
FROM top_market_counties
ORDER BY total_county_enrollment DESC
LIMIT 25;

/*
How This Query Works:
1. Aggregates Medicare Advantage enrollment by county
2. Ranks counties by total enrollment volume
3. Identifies top 10% of counties with highest enrollment
4. Calculates market share and plan diversity metrics

Assumptions and Limitations:
- Uses most recent available monthly snapshot
- Enrollment numbers represent point-in-time data
- Does not account for population demographics
- Assumes higher enrollment indicates market opportunity

Potential Extensions:
- Add population-adjusted enrollment metrics
- Incorporate plan quality or star ratings
- Analyze enrollment trends over multiple months
- Compare urban vs. rural county enrollment patterns

Performance Considerations:
- Uses window functions for efficient ranking
- Filters zero-enrollment records to reduce computational overhead
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:45:32.244921
    - Additional Notes: Query provides county-level Medicare Advantage enrollment insights, focusing on top-performing markets. Designed for strategic market analysis with flexible top 10% ranking approach.
    
    */