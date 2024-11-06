-- Title: Medicare Advantage Star Rating Performance Analysis

/*
Business Purpose:
This query analyzes the performance trends of Medicare Advantage organizations
by examining their Star Ratings and HEDIS measures over time. The analysis helps:
1. Identify top performing parent organizations
2. Track year-over-year performance changes
3. Support strategic market analysis for healthcare organizations

Key metrics:
- Number of contracts per parent organization
- Average measure values by parent organization
- Year-over-year trends
*/

WITH parent_org_performance AS (
    -- Aggregate performance metrics by parent organization and year
    SELECT 
        parent_organization,
        performance_year,
        COUNT(DISTINCT contract_id) as contract_count,
        AVG(CAST(measure_value_raw AS FLOAT)) as avg_measure_value,
        COUNT(DISTINCT measure_code) as measure_count
    FROM mimi_ws_1.partcd.starrating_display_hedis_measure
    WHERE 
        measure_value_raw IS NOT NULL
        AND parent_organization IS NOT NULL
        AND performance_year >= 2020  -- Focus on recent years
    GROUP BY parent_organization, performance_year
),

yearly_comparison AS (
    -- Calculate year-over-year changes
    SELECT 
        p.*,
        LAG(avg_measure_value) OVER (
            PARTITION BY parent_organization 
            ORDER BY performance_year
        ) as prev_year_value,
        contract_count - LAG(contract_count) OVER (
            PARTITION BY parent_organization 
            ORDER BY performance_year
        ) as contract_count_change
    FROM parent_org_performance p
)

-- Final output with performance metrics and changes
SELECT 
    parent_organization,
    performance_year,
    contract_count,
    ROUND(avg_measure_value, 2) as avg_measure_value,
    ROUND(avg_measure_value - prev_year_value, 2) as year_over_year_change,
    contract_count_change,
    measure_count
FROM yearly_comparison
WHERE contract_count >= 5  -- Focus on organizations with significant presence
ORDER BY 
    performance_year DESC,
    contract_count DESC,
    avg_measure_value DESC;

/*
How it works:
1. First CTE aggregates key metrics by parent organization and year
2. Second CTE calculates year-over-year changes using window functions
3. Final query filters and formats results for analysis

Assumptions and Limitations:
- Assumes measure_value_raw can be cast to FLOAT
- Limited to organizations with 5+ contracts for statistical significance
- Treats all measures equally in averaging (no weighting)
- Does not distinguish between different types of measures

Possible Extensions:
1. Add measure type analysis (HEDIS vs Display measures)
2. Include geographic analysis by joining with contract service area data
3. Add performance quartile calculations
4. Create separate averages for clinical vs satisfaction measures
5. Add statistical significance testing for year-over-year changes
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:11:14.162518
    - Additional Notes: Query focuses on parent organization performance metrics requiring at least 5 contracts per organization. Raw measure values must be numeric for proper aggregation. Performance years are limited to 2020 onwards. Results include year-over-year changes in both measure values and contract counts, useful for tracking organizational growth and performance trends.
    
    */