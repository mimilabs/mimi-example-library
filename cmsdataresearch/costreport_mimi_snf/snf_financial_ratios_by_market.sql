-- snf_financial_health_metrics.sql

-- Business Purpose:
-- Analyzes the financial health of Skilled Nursing Facilities (SNFs) by calculating key liquidity 
-- and solvency metrics. This helps identify facilities at financial risk and assess the overall
-- financial stability of the SNF market.

WITH facility_metrics AS (
  SELECT 
    facility_name,
    state_code,
    rural_versus_urban,
    fiscal_year_end_date,
    
    -- Calculate Current Ratio (Liquidity)
    ROUND(total_current_assets / NULLIF(total_current_liabilities, 0), 2) AS current_ratio,
    
    -- Calculate Days Cash on Hand
    ROUND(cash_on_hand_and_in_banks / (less_total_operating_expense / 365), 2) AS days_cash_on_hand,
    
    -- Calculate Debt to Equity Ratio
    ROUND(total_liabilities / NULLIF(total_fund_balances, 0), 2) AS debt_to_equity_ratio,
    
    -- Calculate Operating Margin
    ROUND((net_income_from_service_to_patients / NULLIF(net_patient_revenue, 0)) * 100, 2) AS operating_margin_pct,
    
    -- Key absolute values for context
    ROUND(total_assets/1000000, 2) AS total_assets_millions,
    ROUND(net_patient_revenue/1000000, 2) AS annual_revenue_millions
    
  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_snf
  WHERE fiscal_year_end_date >= '2020-01-01'
    AND total_assets > 0  -- Filter out facilities with missing/invalid financials
)

SELECT
  state_code,
  rural_versus_urban,
  COUNT(*) AS facility_count,
  
  -- Liquidity Metrics
  ROUND(AVG(current_ratio), 2) AS avg_current_ratio,
  ROUND(AVG(days_cash_on_hand), 0) AS avg_days_cash,
  
  -- Solvency & Profitability 
  ROUND(AVG(debt_to_equity_ratio), 2) AS avg_debt_to_equity,
  ROUND(AVG(operating_margin_pct), 1) AS avg_operating_margin_pct,
  
  -- Facility Size Metrics
  ROUND(AVG(total_assets_millions), 1) AS avg_total_assets_millions,
  ROUND(AVG(annual_revenue_millions), 1) AS avg_annual_revenue_millions

FROM facility_metrics
GROUP BY state_code, rural_versus_urban
HAVING facility_count >= 5  -- Only show markets with meaningful sample size
ORDER BY state_code, rural_versus_urban

-- How it works:
-- 1. CTE calculates key financial ratios for each facility
-- 2. Main query aggregates metrics by state and rural/urban designation
-- 3. Results show average financial health metrics for each market segment

-- Assumptions & Limitations:
-- - Relies on accurate financial reporting by facilities
-- - Does not account for seasonal variations
-- - May not capture all aspects of financial health
-- - Some facilities may have missing/invalid data

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include ownership type segmentation
-- 3. Add percentile rankings for each metric
-- 4. Incorporate quality metrics correlation
-- 5. Add filters for facility size/type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:24:11.751398
    - Additional Notes: Query analyzes financial health by calculating key ratios (liquidity, solvency, profitability) and aggregating by geographic market. Only includes facilities with data from 2020 onwards and requires minimum of 5 facilities per market segment for statistical relevance. Days cash on hand calculation uses operating expense as denominator which may need validation against facility-specific accounting practices.
    
    */