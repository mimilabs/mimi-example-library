/*
Hospital Financial Health Key Performance Metrics Analysis

Business Purpose:
This analysis examines key financial health indicators across hospitals to identify:
- Operating efficiency and financial sustainability
- Working capital management
- Financial leverage and debt management 
- Cash flow and liquidity position

The insights help:
- Healthcare investors evaluate hospital financial stability
- Hospital administrators benchmark performance
- Policy makers understand hospital sector financial health
- Market researchers analyze healthcare provider economics
*/

WITH financial_metrics AS (
  SELECT
    hospital_name,
    state,
    city,
    -- Liquidity metrics
    cash_on_hand_and_in_banks / NULLIF(total_current_liabilities, 0) as cash_ratio,
    total_current_assets / NULLIF(total_current_liabilities, 0) as current_ratio,
    
    -- Operating efficiency 
    total_income / NULLIF(total_assets, 0) as asset_turnover,
    net_patient_revenue / NULLIF(less_total_operating_expense, 0) as operating_margin,
    
    -- Leverage metrics
    total_liabilities / NULLIF(total_assets, 0) as debt_ratio,
    
    -- Scale indicators
    total_assets,
    net_patient_revenue,
    fy_end_dt
  FROM mimi_ws_1.cmsdataresearch.costreport_sas_hos
  WHERE total_assets > 0 
    AND fy_end_dt >= '2020-01-01'
)

SELECT
  state,
  COUNT(DISTINCT hospital_name) as hospital_count,
  ROUND(AVG(cash_ratio), 2) as avg_cash_ratio,
  ROUND(AVG(current_ratio), 2) as avg_current_ratio, 
  ROUND(AVG(asset_turnover), 2) as avg_asset_turnover,
  ROUND(AVG(operating_margin), 2) as avg_operating_margin,
  ROUND(AVG(debt_ratio), 2) as avg_debt_ratio,
  ROUND(AVG(total_assets)/1000000, 1) as avg_total_assets_millions,
  ROUND(AVG(net_patient_revenue)/1000000, 1) as avg_net_patient_revenue_millions
FROM financial_metrics
GROUP BY state
HAVING hospital_count >= 5
ORDER BY avg_operating_margin DESC;

/*
How This Query Works:
1. Creates a CTE with key financial ratios calculated for each hospital
2. Aggregates metrics by state while filtering for meaningful sample sizes
3. Orders results by operating margin to highlight best/worst performing states

Assumptions & Limitations:
- Assumes recent data (2020+) is most relevant for current analysis
- Excludes hospitals with zero/negative total assets
- Requires minimum 5 hospitals per state for meaningful averages
- Does not account for hospital size/type differences within states

Possible Extensions:
1. Add year-over-year trend analysis:
   - Include prior years and calculate growth rates
   - Show changes in financial health over time

2. Segment analysis:
   - Break down by hospital type, size, urban/rural
   - Compare metrics across different hospital characteristics

3. Risk analysis:
   - Add metrics for financial distress prediction
   - Flag hospitals with concerning metric combinations

4. Regional clustering:
   - Group nearby states to identify regional patterns
   - Account for cross-border hospital competition
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:17:24.046950
    - Additional Notes: Query calculates key financial health indicators including liquidity, efficiency and leverage ratios at the state level. Only includes post-2020 data and states with 5+ hospitals. Dollar amounts are displayed in millions. Results are ordered by operating margin to highlight states with strongest financial performance.
    
    */