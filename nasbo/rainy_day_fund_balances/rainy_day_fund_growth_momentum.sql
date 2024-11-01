-- State Rainy Day Fund Growth Momentum Analysis
-- Business Purpose: Identify states showing consistent positive growth in their rainy day fund balances,
-- which indicates improving fiscal health and risk management capabilities. This helps stakeholders
-- assess which states are building financial resilience over time.

WITH annual_growth AS (
    -- Calculate year-over-year growth rates for each state
    SELECT 
        state,
        year,
        balance_in_dollars,
        LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year) AS prev_year_balance,
        ((balance_in_dollars - LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year)) / 
         NULLIF(LAG(balance_in_dollars) OVER (PARTITION BY state ORDER BY year), 0)) * 100 as growth_rate
    FROM mimi_ws_1.nasbo.rainy_day_fund_balances
    WHERE year >= 2019  -- Focus on recent years including pre/post COVID
),

growth_metrics AS (
    -- Calculate average growth rate and consistency metrics
    SELECT 
        state,
        AVG(growth_rate) as avg_growth_rate,
        COUNT(*) as years_of_data,
        COUNT(CASE WHEN growth_rate > 0 THEN 1 END) as positive_growth_years,
        MAX(balance_in_dollars) as current_balance
    FROM annual_growth
    WHERE growth_rate IS NOT NULL
    GROUP BY state
)

SELECT 
    state,
    ROUND(avg_growth_rate, 2) as avg_annual_growth_pct,
    positive_growth_years,
    years_of_data - 1 as total_years_analyzed,
    ROUND((positive_growth_years::FLOAT / (years_of_data - 1)) * 100, 1) as growth_consistency_pct,
    ROUND(current_balance, 1) as latest_balance_mm
FROM growth_metrics
WHERE years_of_data > 2  -- Ensure we have enough data points
ORDER BY avg_growth_rate DESC;

-- How it works:
-- 1. Creates annual_growth CTE to calculate year-over-year growth rates
-- 2. Creates growth_metrics CTE to aggregate growth statistics
-- 3. Final output shows average growth rate, consistency metrics, and current balance
-- 4. Orders results by average growth rate to highlight fastest-growing states

-- Assumptions and Limitations:
-- - Assumes positive growth rates are desirable without considering optimal fund sizes
-- - Does not account for state size or economy in growth rate calculations
-- - Missing or zero values might affect growth rate calculations
-- - Recent years focus might miss longer-term trends
-- - Growth rates might be affected by one-time events or policy changes

-- Possible Extensions:
-- 1. Add population-adjusted metrics to compare states of different sizes
-- 2. Include economic indicators to correlate growth with state economic health
-- 3. Add volatility metrics to assess growth stability
-- 4. Compare growth rates against regional averages
-- 5. Incorporate general fund size to contextualize growth rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:27:51.289655
    - Additional Notes: Query focuses on fiscal years 2019 onward to capture recent growth trends and includes built-in data quality checks through the years_of_data > 2 filter. The growth_consistency_pct metric provides additional context beyond simple growth rates, helping identify states with sustained vs volatile growth patterns.
    
    */