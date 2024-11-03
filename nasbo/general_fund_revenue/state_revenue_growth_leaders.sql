-- top_10_state_revenue_growth.sql

-- Business Purpose:
-- - Identify states with strongest total revenue growth trends
-- - Highlight potential best practices from high-growth states
-- - Support strategic planning and revenue enhancement initiatives
-- - Enable benchmarking against top performing states

WITH total_revenue AS (
  -- Calculate total revenue and year-over-year growth by state
  SELECT 
    state,
    fiscal_year,
    (sales + pit + cit + all_other) as total_revenue,
    LAG(sales + pit + cit + all_other) OVER (PARTITION BY state ORDER BY fiscal_year) as prev_year_revenue
  FROM mimi_ws_1.nasbo.general_fund_revenue
  WHERE fiscal_year >= 2018  -- Focus on recent 5-year trend
    AND fiscal_year <= 2022  -- Use complete years only
    AND state NOT IN ('District of Columbia', 'Guam', 'Puerto Rico', 'Virgin Islands')  -- Focus on 50 states
),

growth_metrics AS (
  -- Calculate compound annual growth rate (CAGR) for each state
  SELECT
    state,
    MIN(fiscal_year) as start_year,
    MAX(fiscal_year) as end_year,
    MIN(CASE WHEN fiscal_year = 2018 THEN total_revenue END) as base_revenue,
    MAX(CASE WHEN fiscal_year = 2022 THEN total_revenue END) as final_revenue,
    POWER((MAX(CASE WHEN fiscal_year = 2022 THEN total_revenue END) / 
           MIN(CASE WHEN fiscal_year = 2018 THEN total_revenue END)), 1.0/4) - 1 as cagr
  FROM total_revenue
  GROUP BY state
  HAVING base_revenue IS NOT NULL AND final_revenue IS NOT NULL
)

-- Select and rank top performing states
SELECT 
  state,
  ROUND(base_revenue, 0) as revenue_2018_mm,
  ROUND(final_revenue, 0) as revenue_2022_mm,
  ROUND((final_revenue - base_revenue), 0) as absolute_growth_mm,
  ROUND(cagr * 100, 1) as cagr_pct
FROM growth_metrics
WHERE cagr IS NOT NULL
ORDER BY cagr DESC
LIMIT 10;

-- How it works:
-- 1. Calculates total revenue by combining all revenue sources for each state/year
-- 2. Computes 5-year compound annual growth rate (CAGR) for each state
-- 3. Ranks states by CAGR to identify top performers
-- 4. Shows both absolute growth and percentage growth metrics

-- Assumptions & Limitations:
-- - Uses 2018-2022 timeframe to avoid COVID-19 disruption in earlier years
-- - Excludes territories and DC to focus on state comparison
-- - Does not adjust for inflation or population changes
-- - Assumes continuity in reporting methods across years

-- Possible Extensions:
-- 1. Add regional grouping to identify geographic patterns
-- 2. Include population-adjusted metrics
-- 3. Break down growth by revenue source
-- 4. Add economic indicators (GDP, employment) correlation
-- 5. Implement inflation adjustment for real growth calculation

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:34:56.347173
    - Additional Notes: Query identifies top performing states by revenue growth using CAGR methodology. Five-year window (2018-2022) chosen to minimize COVID-19 distortions while maintaining recent relevance. Results useful for benchmarking and identifying successful revenue management strategies.
    
    */