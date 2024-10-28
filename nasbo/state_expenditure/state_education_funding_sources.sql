
/*************************************************************************
Title: State Education Funding Analysis Across Sources
 
Business Purpose:
This query analyzes education spending patterns across states by funding source,
identifying how states balance general funds, federal funds and other sources
for both K-12 and higher education. This provides insights into:
- Education funding priorities and strategies
- Federal vs state funding reliance 
- Overall education investment trends
**************************************************************************/

WITH education_totals AS (
  -- Calculate total education spending and source percentages by state for latest year
  SELECT 
    state,
    year,
    -- K-12 education totals
    elsed_tot AS k12_total,
    ROUND(100.0 * elsed_gf/elsed_tot, 1) AS k12_pct_general_fund,
    ROUND(100.0 * elsed_ff/elsed_tot, 1) AS k12_pct_federal,
    ROUND(100.0 * (elsed_of + elsed_bf)/elsed_tot, 1) AS k12_pct_other,
    
    -- Higher ed totals  
    hgred_tot AS higher_ed_total,
    ROUND(100.0 * hgred_gf/hgred_tot, 1) AS higher_pct_general_fund,
    ROUND(100.0 * hgred_ff/hgred_tot, 1) AS higher_pct_federal,
    ROUND(100.0 * (hgred_of + hgred_bf)/hgred_tot, 1) AS higher_pct_other
  FROM mimi_ws_1.nasbo.state_expenditure
  WHERE year = (SELECT MAX(year) FROM mimi_ws_1.nasbo.state_expenditure)
)

SELECT
  state,
  -- K-12 metrics
  k12_total,
  k12_pct_general_fund,
  k12_pct_federal,
  k12_pct_other,
  
  -- Higher ed metrics
  higher_ed_total,
  higher_pct_general_fund, 
  higher_pct_federal,
  higher_pct_other,
  
  -- Total education investment
  k12_total + higher_ed_total AS total_education_spending

FROM education_totals
WHERE state NOT IN ('Guam', 'Puerto Rico', 'Virgin Islands')
ORDER BY total_education_spending DESC;

/*
HOW IT WORKS:
1. Creates CTE to calculate education spending metrics for most recent year
2. Computes percentages of funding from each source
3. Combines K-12 and higher ed spending
4. Filters out territories for US state comparison
5. Orders by total education investment

ASSUMPTIONS & LIMITATIONS:
- Uses most recent year only
- Combines bonds with "other" funding sources
- Does not account for state size/population
- Does not include capital expenditures
- Dollar amounts are in millions

POSSIBLE EXTENSIONS:
1. Add year-over-year trend analysis
2. Include per-capita calculations
3. Add capital expenditure analysis
4. Compare with outcomes metrics
5. Group states by funding strategy patterns
6. Add inflation adjustment
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:28:57.184460
    - Additional Notes: Query provides a snapshot of education funding composition across states for the most recent fiscal year. Particularly useful for comparing state vs federal funding reliance and total education investment. Note that results exclude U.S. territories and amounts are in millions of dollars. Consider adjusting for population size when comparing across states.
    
    */