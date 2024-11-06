/* Hospital Balance Sheet Analysis and Financial Health

Business Purpose: This analysis examines hospitals' financial position and stability through balance sheet metrics to:
- Assess liquidity and solvency positions
- Evaluate capital structure and long-term financial health
- Compare working capital management across hospital types
- Identify potential financial risks and opportunities

The query focuses on key balance sheet ratios and metrics that indicate financial strength and stability.
*/

-- Main query analyzing hospital balance sheet metrics and financial position
SELECT
  state,
  provider_type,
  type_of_control,
  COUNT(*) as hospital_count,
  
  -- Liquidity metrics
  AVG(cash_on_hand_and_in_banks / NULLIF(total_current_liabilities, 0)) as avg_cash_ratio,
  AVG((total_current_assets - inventory) / NULLIF(total_current_liabilities, 0)) as avg_quick_ratio,
  AVG(total_current_assets / NULLIF(total_current_liabilities, 0)) as avg_current_ratio,
  
  -- Solvency metrics  
  AVG(total_liabilities / NULLIF(total_assets, 0)) as avg_debt_to_assets_ratio,
  AVG(total_fund_balances / NULLIF(total_assets, 0)) as avg_equity_ratio,
  
  -- Asset composition
  AVG(total_fixed_assets / NULLIF(total_assets, 0)) as avg_fixed_asset_ratio,
  AVG(accounts_receivable / NULLIF(total_current_assets, 0)) as avg_ar_to_current_assets

FROM mimi_ws_1.cmsdataresearch.costreport_sas_hos
WHERE 
  -- Focus on most recent fiscal year
  fy_end_dt >= '2020-01-01'
  -- Exclude invalid/missing values
  AND total_assets > 0
  AND total_current_assets > 0
  AND total_current_liabilities > 0

GROUP BY 
  state,
  provider_type,
  type_of_control

HAVING COUNT(*) >= 5  -- Only include groups with sufficient sample size

ORDER BY 
  state,
  provider_type,
  type_of_control;

/* How this query works:
1. Calculates key balance sheet ratios at hospital level
2. Aggregates metrics by state, provider type and control type
3. Filters for recent data and valid values
4. Only includes groupings with 5+ hospitals for statistical validity

Key assumptions and limitations:
- Assumes balance sheet data is reported consistently across hospitals
- Zero values in denominators handled via NULLIF
- Does not account for seasonality or point-in-time nature of balance sheets
- Some ratios may be skewed by outliers
- Limited to basic balance sheet metrics

Possible extensions:
1. Add trending over multiple years to see changes in financial position
2. Include more detailed asset/liability composition analysis
3. Add statistical measures like median and percentiles for each metric
4. Compare metrics against industry benchmarks
5. Incorporate income statement metrics for fuller financial analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:18:33.277805
    - Additional Notes: Query provides a comprehensive view of hospital financial stability through balance sheet ratios. Note that results are most meaningful for general acute care hospitals, as specialty facilities may have significantly different balance sheet structures. Minimum group size of 5 hospitals may exclude some rural or specialized provider categories.
    
    */