
/*******************************************************************************
Title: State Revenue Source Analysis by Fiscal Year
 
Business Purpose:
- Analyze the composition of state general fund revenue sources over time
- Compare reliance on major tax categories (sales, personal income, corporate)
- Identify revenue trends and patterns across states
*******************************************************************************/

-- Calculate revenue totals and percentages by source for each state and fiscal year
WITH revenue_analysis AS (
  SELECT 
    fiscal_year,
    state,
    -- Calculate total revenue for each state-year
    sales + pit + cit + all_other as total_revenue,
    -- Calculate percentage contribution of each revenue source
    ROUND(100.0 * sales / (sales + pit + cit + all_other), 1) as sales_tax_pct,
    ROUND(100.0 * pit / (sales + pit + cit + all_other), 1) as personal_income_tax_pct,
    ROUND(100.0 * cit / (sales + pit + cit + all_other), 1) as corporate_income_tax_pct,
    ROUND(100.0 * all_other / (sales + pit + cit + all_other), 1) as other_revenue_pct
  FROM mimi_ws_1.nasbo.general_fund_revenue
  WHERE fiscal_year >= 2018  -- Focus on recent 5 years
)

SELECT
  fiscal_year,
  -- Revenue metrics across all states
  COUNT(DISTINCT state) as state_count,
  ROUND(AVG(total_revenue), 0) as avg_total_revenue_millions,
  -- Average percentage breakdown across states
  ROUND(AVG(sales_tax_pct), 1) as avg_sales_tax_pct,
  ROUND(AVG(personal_income_tax_pct), 1) as avg_personal_income_tax_pct,
  ROUND(AVG(corporate_income_tax_pct), 1) as avg_corporate_income_tax_pct,
  ROUND(AVG(other_revenue_pct), 1) as avg_other_revenue_pct
FROM revenue_analysis
GROUP BY fiscal_year
ORDER BY fiscal_year DESC;

/*******************************************************************************
How this query works:
1. Creates a CTE to calculate total revenue and percentage breakdowns by source
2. Aggregates across states to show average revenue composition by fiscal year
3. Focuses on recent 5 years to show current trends

Assumptions and Limitations:
- Assumes data quality and consistency across states
- Does not account for inflation adjustments
- Treats missing values as 0 in calculations
- Gaming revenue is included in all_other category

Possible Extensions:
1. Add regional groupings to compare revenue patterns by geography
2. Include year-over-year growth rates for each revenue source
3. Identify states most dependent on each revenue type
4. Compare pre/post COVID-19 revenue patterns
5. Add filters for specific states or revenue thresholds
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:15:02.744548
    - Additional Notes: This query focuses on recent fiscal years (2018 onward) and calculates state-level revenue percentages from major tax sources. Results show averages across all states, making it useful for understanding typical revenue patterns but potentially masking individual state variations. Consider adjusting the fiscal_year filter in the CTE for different time periods.
    
    */