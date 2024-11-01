-- state_medicaid_funding_analysis.sql
-- Business Purpose: Analyze Medicaid spending patterns across states to understand the distribution
-- of funding sources and identify states with highest reliance on federal vs state funding.
-- This helps policymakers and healthcare organizations understand funding variations and dependencies.

WITH medicaid_metrics AS (
    -- Calculate key Medicaid funding metrics for each state's most recent year
    SELECT 
        state,
        year,
        mcaid_tot as total_medicaid_spending,
        mcaid_ff as federal_medicaid_spending,
        mcaid_gf + mcaid_of as state_medicaid_spending,
        ROUND(mcaid_ff / mcaid_tot * 100, 1) as federal_funding_pct,
        ROUND((mcaid_gf + mcaid_of) / mcaid_tot * 100, 1) as state_funding_pct
    FROM mimi_ws_1.nasbo.state_expenditure
    WHERE year = (SELECT MAX(year) FROM mimi_ws_1.nasbo.state_expenditure)
)

SELECT 
    state,
    year,
    total_medicaid_spending,
    federal_medicaid_spending,
    state_medicaid_spending,
    federal_funding_pct,
    state_funding_pct,
    -- Categorize states by federal funding dependency
    CASE 
        WHEN federal_funding_pct >= 70 THEN 'High Federal Dependency'
        WHEN federal_funding_pct >= 60 THEN 'Moderate Federal Dependency'
        ELSE 'Low Federal Dependency'
    END as funding_dependency_category
FROM medicaid_metrics
WHERE state NOT IN ('Total', 'Average')
ORDER BY federal_funding_pct DESC;

-- How this query works:
-- 1. Creates a CTE to calculate key Medicaid funding metrics for the most recent year
-- 2. Calculates total, federal, and state Medicaid spending
-- 3. Computes percentage distribution between federal and state funding
-- 4. Categorizes states based on their federal funding dependency
-- 5. Excludes aggregate rows and sorts by federal funding percentage

-- Assumptions and Limitations:
-- - Assumes most recent year data is complete and accurate
-- - Combines general funds and other state funds for total state contribution
-- - Does not account for population differences between states
-- - Does not consider historical trends or year-over-year changes
-- - Bond funding for Medicaid is typically minimal and excluded from percentage calculations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to identify shifting funding patterns
-- 2. Incorporate population data to calculate per-capita spending
-- 3. Add correlation analysis with state economic indicators
-- 4. Include analysis of specific Medicaid program components
-- 5. Compare states within similar population or geographic regions
-- 6. Add pandemic impact analysis by comparing pre/post 2020 patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:10:12.570680
    - Additional Notes: Query focuses on federal vs state Medicaid funding ratios and categorizes states by dependency level. Best for annual strategic planning and federal funding relationship analysis. Requires current year data to be complete in the dataset for accurate results.
    
    */