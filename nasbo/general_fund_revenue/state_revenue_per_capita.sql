-- state_revenue_efficiency.sql

-- Business Purpose:
-- - Calculate revenue per capita to measure tax collection efficiency
-- - Compare states' ability to generate revenue relative to population
-- - Identify states with strong/weak revenue generation capacity
-- - Support resource allocation and policy decisions

WITH state_population AS (
  -- Using 2022 estimated state populations as a baseline
  -- In practice, you would join to actual population data by year
  SELECT 
    state,
    CASE 
      WHEN state = 'California' THEN 39.03
      WHEN state = 'Texas' THEN 30.03
      WHEN state = 'Florida' THEN 22.24
      WHEN state = 'New York' THEN 19.84
      ELSE 5.00 -- Default population in millions for other states
    END AS population_millions
  FROM (SELECT DISTINCT state FROM mimi_ws_1.nasbo.general_fund_revenue)
),

revenue_totals AS (
  SELECT
    g.fiscal_year,
    g.state,
    -- Calculate total revenue
    (g.sales + g.pit + g.cit + g.all_other) as total_revenue,
    -- Calculate revenue per source
    g.sales as sales_revenue,
    g.pit as personal_income_revenue,
    g.cit as corporate_income_revenue,
    g.all_other as other_revenue,
    p.population_millions
  FROM mimi_ws_1.nasbo.general_fund_revenue g
  JOIN state_population p ON g.state = p.state
  WHERE g.fiscal_year >= 2020 -- Focus on recent years
)

SELECT
  fiscal_year,
  state,
  total_revenue,
  population_millions,
  -- Calculate per capita metrics
  ROUND(total_revenue / population_millions, 2) as revenue_per_capita,
  ROUND(100.0 * sales_revenue / total_revenue, 1) as sales_pct,
  ROUND(100.0 * personal_income_revenue / total_revenue, 1) as pit_pct,
  ROUND(100.0 * corporate_income_revenue / total_revenue, 1) as cit_pct
FROM revenue_totals
ORDER BY fiscal_year DESC, revenue_per_capita DESC;

-- How the Query Works:
-- 1. Creates a CTE with estimated population data
-- 2. Joins revenue data with population data
-- 3. Calculates total revenue and revenue per capita
-- 4. Computes percentage contribution of each revenue source
-- 5. Orders results by year and revenue per capita

-- Assumptions and Limitations:
-- 1. Uses simplified static population data (should be replaced with actual yearly data)
-- 2. Assumes consistent revenue reporting across states
-- 3. Does not account for cost of living differences between states
-- 4. Limited to recent years (2020+) for focused analysis

-- Possible Extensions:
-- 1. Add year-over-year growth rates in revenue per capita
-- 2. Include cost of living adjustments
-- 3. Add regional groupings for geographic comparison
-- 4. Compare against economic indicators (GDP, unemployment)
-- 5. Include efficiency ratios (collection costs vs revenue)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:10:41.118009
    - Additional Notes: Query uses simplified static population data which should be replaced with actual state population figures from a proper demographics table for production use. The default population of 5 million for unlisted states is a placeholder and should be updated with real data.
    
    */