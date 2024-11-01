-- Title: Medicare Part B NOC Drug Dosage Value Analysis

-- Business Purpose:
-- - Identify and analyze NOC drugs with multiple dosage forms to support formulary decisions
-- - Highlight cost variations across different dosage strengths
-- - Enable price-per-unit comparisons for more informed purchasing decisions
-- - Support negotiations with pharmaceutical suppliers based on dosage value analysis

-- Main Query
WITH base_dosage_analysis AS (
  SELECT 
    drug_generic_name_trade_name,
    COUNT(DISTINCT dosage) as dosage_forms,
    MIN(payment_limit) as min_payment,
    MAX(payment_limit) as max_payment,
    AVG(payment_limit) as avg_payment
  FROM mimi_ws_1.cmspayment.partb_drug_noc_pricing
  WHERE mimi_src_file_date >= DATE_SUB(CURRENT_DATE, 365)  -- Last 12 months
  GROUP BY drug_generic_name_trade_name
  HAVING COUNT(DISTINCT dosage) > 1  -- Only drugs with multiple dosages
),
drug_details AS (
  SELECT 
    drug_generic_name_trade_name,
    dosage_forms,
    min_payment,
    max_payment,
    avg_payment,
    (max_payment - min_payment) / min_payment * 100 as price_spread_pct
  FROM base_dosage_analysis
)
SELECT 
  drug_generic_name_trade_name,
  dosage_forms,
  ROUND(min_payment, 2) as lowest_price,
  ROUND(max_payment, 2) as highest_price,
  ROUND(avg_payment, 2) as average_price,
  ROUND(price_spread_pct, 1) as price_spread_percentage
FROM drug_details
WHERE price_spread_pct > 20  -- Focus on significant price variations
ORDER BY price_spread_pct DESC
LIMIT 20;

-- How the Query Works:
-- 1. Creates base analysis of drugs with multiple dosage forms in the last 12 months
-- 2. Calculates min, max, and average payments for each drug
-- 3. Computes price spread percentage between highest and lowest dosage forms
-- 4. Filters to show drugs with >20% price variation
-- 5. Returns top 20 drugs with highest price spread

-- Assumptions and Limitations:
-- - Assumes current dosage forms are representative of typical options
-- - Limited to last 12 months of data
-- - Does not account for specific indications or therapeutic equivalence
-- - Price spread may be influenced by package sizes or concentrations
-- - Does not consider utilization volume

-- Possible Extensions:
-- 1. Add therapeutic category grouping for category-level analysis
-- 2. Include time-based trend analysis of price spreads
-- 3. Incorporate dosage unit normalization for better comparison
-- 4. Add filters for specific drug types or payment thresholds
-- 5. Create views for different spread thresholds (10%, 50%, etc.)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:29:50.850483
    - Additional Notes: Query focuses on pricing variations across different dosage forms of the same drug, helping identify potential cost optimization opportunities. The 20% price spread threshold and 12-month lookback period can be adjusted based on specific analysis needs.
    
    */