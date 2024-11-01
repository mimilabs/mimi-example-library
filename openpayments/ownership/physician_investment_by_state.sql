-- geographic_investment_concentration.sql

-- Business Purpose: Analyze geographic concentration of physician investments in medical companies
-- to identify potential regional influence patterns, market opportunities, and risk areas.
-- This helps stakeholders understand where financial relationships between physicians and 
-- industry are most concentrated, informing market strategy and compliance monitoring.

WITH state_metrics AS (
    -- Calculate key metrics by state
    SELECT 
        recipient_state,
        COUNT(DISTINCT physician_profile_id) as physician_count,
        COUNT(DISTINCT submitting_applicable_manufacturer_or_applicable_gpo_name) as company_count,
        SUM(COALESCE(total_amount_invested_us_dollars, 0)) as total_investment,
        SUM(COALESCE(value_of_interest, 0)) as total_value
    FROM mimi_ws_1.openpayments.ownership
    WHERE recipient_state IS NOT NULL
        AND program_year >= 2020  -- Focus on recent years
    GROUP BY recipient_state
),
state_rankings AS (
    -- Add rankings to identify top states
    SELECT 
        *,
        ROUND(total_investment/NULLIF(physician_count, 0), 2) as avg_investment_per_physician,
        ROUND(total_value/NULLIF(physician_count, 0), 2) as avg_value_per_physician,
        RANK() OVER (ORDER BY total_investment DESC) as investment_rank,
        RANK() OVER (ORDER BY physician_count DESC) as physician_rank
    FROM state_metrics
)
SELECT 
    recipient_state as state,
    physician_count,
    company_count,
    total_investment,
    total_value,
    avg_investment_per_physician,
    avg_value_per_physician,
    investment_rank,
    physician_rank
FROM state_rankings
WHERE physician_count > 5  -- Filter out states with very few physicians
ORDER BY total_investment DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates key metrics by state
-- 2. Second CTE adds per-physician calculations and rankings
-- 3. Final query filters and presents results in a meaningful order

-- Assumptions:
-- 1. Recent data (2020+) is more relevant for current analysis
-- 2. States with very few physicians may not be statistically significant
-- 3. NULL values in investment amounts are treated as 0
-- 4. Only US states are considered (international locations excluded)

-- Limitations:
-- 1. Does not account for population differences between states
-- 2. Cannot capture unofficial or unreported relationships
-- 3. Doesn't consider cost of living differences between states
-- 4. May miss physicians practicing in multiple states

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Incorporate population normalization using census data
-- 3. Add metropolitan area breakdowns
-- 4. Include company sector/type analysis
-- 5. Add correlation with healthcare quality metrics
-- 6. Compare with Medicare spending patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:43:13.221403
    - Additional Notes: Query focuses on state-level aggregation of physician investments, providing insights into geographic distribution of healthcare industry financial relationships. Results are limited to states with >5 physicians to ensure statistical relevance. Consider adjusting the program_year filter (currently 2020+) based on analysis needs.
    
    */