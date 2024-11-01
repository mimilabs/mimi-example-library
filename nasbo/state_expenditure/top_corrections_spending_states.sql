-- state_corrections_spending_trends.sql
-- Business Purpose: Analyze trends in state corrections spending to understand fiscal priorities,
-- efficiency of resource allocation, and identify states with notable spending patterns.
-- This helps policymakers and analysts evaluate corrections policy effectiveness and budgeting.

WITH spending_summary AS (
    -- Calculate key metrics for corrections spending by state and year
    SELECT 
        year,
        state,
        corr_tot AS total_corrections,
        corr_gf AS general_fund_corrections,
        corr_tot / NULLIF(total_capi, 0) * 100 AS corrections_pct_total_budget,
        COALESCE(corr_gf / NULLIF(corr_tot, 0) * 100, 0) AS general_fund_pct
    FROM mimi_ws_1.nasbo.state_expenditure
    WHERE year >= 2018  -- Focus on recent 5 years
    AND state NOT IN ('Guam', 'Puerto Rico', 'Virgin Islands')  -- Focus on states only
),

ranked_states AS (
    -- Identify states with highest corrections spending
    SELECT 
        state,
        AVG(total_corrections) AS avg_annual_spending,
        AVG(corrections_pct_total_budget) AS avg_budget_pct,
        AVG(general_fund_pct) AS avg_gf_pct
    FROM spending_summary
    GROUP BY state
    ORDER BY avg_annual_spending DESC
    LIMIT 10
)

SELECT 
    r.state,
    ROUND(r.avg_annual_spending, 2) AS avg_annual_spending_millions,
    ROUND(r.avg_budget_pct, 2) AS pct_of_total_budget,
    ROUND(r.avg_gf_pct, 2) AS pct_from_general_fund
FROM ranked_states r
ORDER BY r.avg_annual_spending DESC;

-- How it works:
-- 1. Creates a base summary of corrections spending metrics by state and year
-- 2. Calculates multi-year averages and rankings for states
-- 3. Returns top 10 states by average annual corrections spending with key metrics

-- Assumptions and Limitations:
-- - Focuses on state-level spending only, excludes local corrections spending
-- - Does not account for differences in state population or incarceration rates
-- - Recent 5-year window may not capture longer-term trends
-- - Excludes U.S. territories for more direct state comparisons

-- Possible Extensions:
-- 1. Add year-over-year growth rates to identify spending trends
-- 2. Include population data to calculate per-capita spending
-- 3. Compare corrections capital vs. operating expenses
-- 4. Analyze relationship between corrections and public safety spending
-- 5. Compare corrections spending with education or healthcare investments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:13:14.351233
    - Additional Notes: Query identifies states allocating the highest share of resources to corrections, with metrics for general fund dependency and budget prioritization. Focuses on mainland US states from 2018 onward to ensure consistent comparison basis. Dollar amounts are in millions.
    
    */