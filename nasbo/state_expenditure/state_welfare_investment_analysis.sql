-- state_social_welfare_funding.sql
-- Business Purpose: Analyze overall public assistance spending (TANF + Other Cash Assistance) 
-- trends across states to understand social welfare investment patterns and identify states
-- with comprehensive support systems. This helps policymakers evaluate social safety net 
-- effectiveness and resource allocation.

WITH welfare_totals AS (
  SELECT 
    year,
    state,
    -- Combine TANF and other cash assistance for total welfare spending
    (tanf_tot + otca_tot) as total_welfare_spending,
    -- Calculate state vs federal share
    (tanf_gf + tanf_of + otca_gf + otca_of) as state_welfare_share,
    (tanf_ff + otca_ff) as federal_welfare_share
  FROM mimi_ws_1.nasbo.state_expenditure
  WHERE year >= 2019 -- Focus on recent years post-COVID
),

state_metrics AS (
  SELECT
    state,
    ROUND(AVG(total_welfare_spending), 2) as avg_annual_spending,
    ROUND(AVG(state_welfare_share/total_welfare_spending), 3) as avg_state_share_pct,
    ROUND(AVG(federal_welfare_share/total_welfare_spending), 3) as avg_federal_share_pct
  FROM welfare_totals
  GROUP BY state
)

SELECT 
  state,
  avg_annual_spending as avg_annual_welfare_spending_millions,
  avg_state_share_pct * 100 as state_funding_percentage,
  avg_federal_share_pct * 100 as federal_funding_percentage
FROM state_metrics
WHERE avg_annual_spending > 0 -- Exclude states with missing/zero data
ORDER BY avg_annual_spending DESC
LIMIT 15;

-- How it works:
-- 1. Creates a CTE to combine TANF and other cash assistance spending
-- 2. Calculates state vs federal funding shares
-- 3. Aggregates to get average metrics per state
-- 4. Returns top 15 states by total welfare spending with funding breakdowns

-- Assumptions & Limitations:
-- - Focuses only on direct cash assistance programs (TANF + Other Cash)
-- - Excludes other forms of public assistance like food stamps, housing subsidies
-- - State-level aggregation masks county/local variation
-- - Recent years only (2019+) to focus on current patterns
-- - Does not account for population differences between states

-- Possible Extensions:
-- 1. Add year-over-year trending analysis
-- 2. Incorporate population data to calculate per-capita spending
-- 3. Compare welfare spending to poverty rates or unemployment
-- 4. Add seasonal/quarterly analysis where available
-- 5. Include additional program categories like Medicaid
-- 6. Create regional groupings for geographic analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:59:27.513224
    - Additional Notes: Query provides insights into social welfare funding patterns across states, focusing on cash assistance programs. Note that the 15-state limit in results may need adjustment based on specific analysis needs, and the 2019+ timeframe could be modified to capture different historical periods. Consider adding WHERE clauses to filter out territories if analysis should focus only on U.S. states.
    
    */