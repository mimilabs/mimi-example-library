-- TITLE: Home Health Agency Financial Analysis - Balance Sheet Health Metrics

-- BUSINESS PURPOSE:
-- Analyze the financial health and stability of home health agencies through key balance sheet metrics:
-- - Working capital ratios to assess short-term liquidity
-- - Long-term debt leverage to evaluate financial risk
-- - Asset utilization efficiency over time
-- This enables identifying HHAs at financial risk and benchmarking performance.

WITH annual_metrics AS (
  SELECT 
    provider_ccn,
    hha_name,
    state_code,
    fiscal_year_end_date,
    
    -- Liquidity metrics
    total_current_assets,
    total_current_liabilities,
    CASE 
      WHEN total_current_liabilities > 0 
      THEN ROUND(total_current_assets / total_current_liabilities, 2)
      ELSE NULL 
    END as current_ratio,
    
    -- Leverage metrics 
    total_liabilities,
    total_assets,
    CASE
      WHEN total_assets > 0
      THEN ROUND(total_liabilities / total_assets * 100, 1) 
      ELSE NULL
    END as debt_to_assets_pct,
    
    -- Asset utilization
    gross_patient_revenues_total,
    CASE 
      WHEN total_assets > 0
      THEN ROUND(gross_patient_revenues_total / total_assets, 2)
      ELSE NULL 
    END as asset_turnover
    
  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hha
  WHERE fiscal_year_end_date IS NOT NULL
    AND total_assets > 0
)

SELECT
  state_code,
  fiscal_year_end_date,
  COUNT(DISTINCT provider_ccn) as hha_count,
  
  -- Liquidity stats
  ROUND(AVG(current_ratio), 2) as avg_current_ratio,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY current_ratio), 2) as median_current_ratio,
  
  -- Leverage stats  
  ROUND(AVG(debt_to_assets_pct), 1) as avg_debt_to_assets_pct,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY debt_to_assets_pct), 1) as median_debt_to_assets_pct,
  
  -- Asset utilization stats
  ROUND(AVG(asset_turnover), 2) as avg_asset_turnover,
  ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY asset_turnover), 2) as median_asset_turnover

FROM annual_metrics
GROUP BY state_code, fiscal_year_end_date
HAVING COUNT(DISTINCT provider_ccn) >= 5  -- Only show states with meaningful sample sizes
ORDER BY state_code, fiscal_year_end_date;

-- HOW IT WORKS:
-- 1. Calculates key financial ratios for each HHA using balance sheet data
-- 2. Aggregates metrics by state and year to show trends and benchmarks
-- 3. Uses medians to control for outliers when summarizing financial health
-- 4. Filters for meaningful sample sizes to ensure reliable comparisons

-- ASSUMPTIONS & LIMITATIONS:
-- - Requires accurate financial reporting by HHAs
-- - Balance sheet data point-in-time measures may miss seasonal variations
-- - Industry standard ratios may not apply equally across all HHA types/sizes
-- - Some HHAs may be missing financial data

-- POSSIBLE EXTENSIONS:
-- 1. Add trend analysis showing year-over-year changes in metrics
-- 2. Segment by HHA size (revenue bands) or ownership type
-- 3. Flag HHAs with concerning ratios for further investigation
-- 4. Compare metrics across geographic regions
-- 5. Correlate financial health with quality metrics
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:12:30.038382
    - Additional Notes: The query focuses on standard financial ratios (liquidity, leverage, efficiency) commonly used in healthcare financial analysis. The 5-provider minimum threshold per state may need adjustment based on specific analysis needs. Consider seasonality when interpreting results as fiscal year end dates vary across providers.
    
    */