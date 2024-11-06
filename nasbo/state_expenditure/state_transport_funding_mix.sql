-- state_transportation_infrastructure.sql
-- Business Purpose: Analyze transportation investment strategies across states by comparing
-- operational vs capital spending patterns, funding source mix, and total infrastructure commitment.
-- This helps identify states making significant transportation investments and their funding approaches,
-- which is crucial for infrastructure planning and policy decisions.

WITH yearly_transport_metrics AS (
    -- Calculate key transportation metrics by state for the most recent year
    SELECT 
        state,
        year,
        -- Operating expenditure breakdown
        trans_gf + trans_ff + trans_of + trans_bf AS total_operating,
        -- Capital expenditure breakdown  
        trcap_gf + trcap_ff + trcap_of + trcap_bf AS total_capital,
        -- Funding source percentages for total transportation
        ROUND(100.0 * (trans_gf + trcap_gf) / NULLIF((trans_tot + trcap_tot), 0), 1) AS pct_general_funds,
        ROUND(100.0 * (trans_ff + trcap_ff) / NULLIF((trans_tot + trcap_tot), 0), 1) AS pct_federal_funds,
        ROUND(100.0 * (trans_of + trcap_of) / NULLIF((trans_tot + trcap_tot), 0), 1) AS pct_other_funds,
        ROUND(100.0 * (trans_bf + trcap_bf) / NULLIF((trans_tot + trcap_tot), 0), 1) AS pct_bond_funds
    FROM mimi_ws_1.nasbo.state_expenditure
    WHERE year = (SELECT MAX(year) FROM mimi_ws_1.nasbo.state_expenditure)
)

SELECT 
    state,
    -- Total spending metrics
    total_operating + total_capital AS total_transport_spend,
    ROUND(100.0 * total_capital / NULLIF((total_operating + total_capital), 0), 1) AS pct_capital_spending,
    -- Funding source breakdown
    pct_general_funds,
    pct_federal_funds,
    pct_other_funds,
    pct_bond_funds
FROM yearly_transport_metrics
WHERE state NOT IN ('District of Columbia', 'Guam', 'Puerto Rico', 'Virgin Islands')
ORDER BY total_transport_spend DESC
LIMIT 15;

/* How it works:
1. Creates a CTE to calculate key transportation metrics for most recent year
2. Combines operating and capital expenditures across funding sources
3. Calculates percentage breakdowns for funding sources and capital vs operating
4. Returns top 15 states by total transportation spending with detailed breakdowns

Assumptions & Limitations:
- Focuses on most recent year only
- Excludes territories and DC for state-to-state comparison
- Assumes reported data is complete and accurate
- Does not account for state size, population, or existing infrastructure
- Does not consider multi-year capital projects or funding cycles

Possible Extensions:
1. Add year-over-year growth rates in transportation spending
2. Include per capita calculations using population data
3. Compare transportation spending to total state budget
4. Analyze seasonal patterns in transportation spending
5. Add correlation with economic indicators or infrastructure quality metrics
6. Include geographic region grouping for regional patterns
7. Add weather/climate factors that might impact transportation needs
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:05:22.210791
    - Additional Notes: Query analyzes both operational and capital transportation spending, providing insights into state infrastructure investment strategies through funding source composition. May need adjustment for states with biennial budgets or significant year-end spending variations.
    
    */