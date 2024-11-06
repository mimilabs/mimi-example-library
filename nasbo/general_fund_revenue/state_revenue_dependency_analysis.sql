-- revenue_dependency_ratio.sql

-- Business Purpose:
-- - Calculate revenue dependency ratios to assess fiscal risk exposure
-- - Identify states overly reliant on single revenue sources
-- - Support state financial planning and risk management
-- - Guide revenue diversification strategies
-- - Benchmark states against peer averages

WITH revenue_totals AS (
  -- Calculate total revenue and source percentages for each state-year
  SELECT 
    fiscal_year,
    state,
    sales + pit + cit + all_other as total_revenue,
    sales / (sales + pit + cit + all_other) as sales_pct,
    pit / (sales + pit + cit + all_other) as pit_pct,
    cit / (sales + pit + cit + all_other) as cit_pct,
    all_other / (sales + pit + cit + all_other) as other_pct
  FROM mimi_ws_1.nasbo.general_fund_revenue
  WHERE fiscal_year >= 2018  -- Focus on recent 5 years
),

state_metrics AS (
  -- Calculate key dependency metrics by state
  SELECT
    state,
    ROUND(AVG(total_revenue), 0) as avg_total_revenue,
    ROUND(AVG(sales_pct) * 100, 1) as avg_sales_pct,
    ROUND(AVG(pit_pct) * 100, 1) as avg_pit_pct,
    ROUND(AVG(cit_pct) * 100, 1) as avg_cit_pct,
    ROUND(AVG(other_pct) * 100, 1) as avg_other_pct,
    ROUND(STDDEV(sales_pct) * 100, 1) as sales_volatility,
    ROUND(STDDEV(pit_pct) * 100, 1) as pit_volatility
  FROM revenue_totals
  GROUP BY state
)

-- Identify states with high dependency on single sources
SELECT
  state,
  avg_total_revenue,
  avg_sales_pct as sales_dependency_pct,
  avg_pit_pct as pit_dependency_pct,
  avg_cit_pct as cit_dependency_pct,
  avg_other_pct as other_dependency_pct,
  CASE 
    WHEN avg_sales_pct > 45 THEN 'High Sales Tax Dependency'
    WHEN avg_pit_pct > 45 THEN 'High PIT Dependency'
    WHEN avg_cit_pct > 15 THEN 'High CIT Dependency'
    WHEN avg_other_pct > 45 THEN 'High Other Dependency'
    ELSE 'Balanced Revenue Mix'
  END as dependency_flag,
  sales_volatility,
  pit_volatility
FROM state_metrics
ORDER BY 
  GREATEST(avg_sales_pct, avg_pit_pct, avg_cit_pct, avg_other_pct) DESC;

-- How it works:
-- 1. First CTE calculates revenue percentages by source for each state-year
-- 2. Second CTE computes multi-year averages and volatility metrics
-- 3. Final query identifies states with high dependency on specific sources
-- 4. Includes volatility measures to assess risk alongside dependency

-- Assumptions and Limitations:
-- - Uses 45% threshold for sales/PIT and 15% for CIT to flag high dependency
-- - Recent 5-year window may not capture longer-term trends
-- - Does not account for economic differences between states
-- - Volatility calculation requires multiple years of data
-- - All_other category may mask important revenue source details

-- Possible Extensions:
-- 1. Add peer group comparisons based on state size or region
-- 2. Include year-over-year trend analysis of dependency ratios
-- 3. Correlate dependency with economic stability metrics
-- 4. Add revenue source correlation analysis
-- 5. Create risk score combining dependency and volatility metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:34:52.244516
    - Additional Notes: Query assesses fiscal risk by calculating revenue dependency ratios and identifying states with high reliance on specific revenue sources. The 45% threshold for sales/PIT and 15% for CIT dependency flags were chosen based on typical state revenue patterns but may need adjustment for specific analysis needs. Consider local economic contexts when interpreting results.
    
    */