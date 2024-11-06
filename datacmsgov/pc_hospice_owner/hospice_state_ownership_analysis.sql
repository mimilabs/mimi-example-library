
-- hospice_geographical_ownership_strategy.sql
/*
Business Purpose:
Analyze the geographical distribution and strategic ownership patterns of hospices
to understand potential market entry, expansion, and investment opportunities.

This query reveals how hospice ownership varies across different states, 
identifying potential regional market strategies and investment trends.
*/

WITH ownership_summary AS (
    -- Aggregate ownership details by state, focusing on strategic ownership characteristics
    SELECT 
        state_owner,
        COUNT(DISTINCT enrollment_id) AS total_hospices,
        
        -- Ownership type breakdown
        SUM(CASE WHEN type_owner = 'I' THEN 1 ELSE 0 END) AS individual_owned_hospices,
        SUM(CASE WHEN type_owner = 'O' THEN 1 ELSE 0 END) AS org_owned_hospices,
        
        -- Ownership structure insights
        ROUND(AVG(percentage_ownership), 2) AS avg_ownership_percentage,
        
        -- Strategic ownership indicators
        SUM(CASE WHEN created_for_acquisition_owner = 'Y' THEN 1 ELSE 0 END) AS acquisition_focused_hospices,
        SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) AS for_profit_hospices,
        SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) AS non_profit_hospices
    FROM 
        mimi_ws_1.datacmsgov.pc_hospice_owner
    WHERE 
        state_owner IS NOT NULL  -- Exclude records without state information
    GROUP BY 
        state_owner
)

SELECT 
    state_owner,
    total_hospices,
    individual_owned_hospices,
    org_owned_hospices,
    ROUND(individual_owned_hospices * 100.0 / total_hospices, 2) AS pct_individual_owned,
    ROUND(org_owned_hospices * 100.0 / total_hospices, 2) AS pct_org_owned,
    avg_ownership_percentage,
    acquisition_focused_hospices,
    for_profit_hospices,
    non_profit_hospices
FROM 
    ownership_summary
ORDER BY 
    total_hospices DESC
LIMIT 50;

/*
Query Mechanics:
- Aggregates hospice ownership data at the state level
- Provides comprehensive view of ownership distribution
- Calculates percentage of individual vs organizational ownership
- Identifies strategic ownership characteristics

Key Assumptions:
- Data represents current snapshot of hospice ownership
- State information is complete and accurate
- Percentages based on available records

Potential Extensions:
1. Add geographical clustering analysis
2. Integrate with performance or financial data
3. Create time-series analysis of ownership changes
4. Develop predictive models for market entry strategies

Recommended Next Steps:
- Validate data completeness
- Cross-reference with additional healthcare datasets
- Conduct deeper analysis of high-potential states
*/


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:09:02.471850
    - Additional Notes: Provides comprehensive state-level breakdown of hospice ownership. Requires complete and up-to-date state data for accurate insights. Best used for strategic market research and investment analysis.
    
    */