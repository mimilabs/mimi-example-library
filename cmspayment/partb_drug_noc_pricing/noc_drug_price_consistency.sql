-- Title: Medicare Part B NOC Drug Pricing Consistency Check

-- Business Purpose:
-- - Identify potential data quality issues in NOC drug pricing submissions
-- - Support compliance monitoring of payment limit reporting
-- - Enable quick identification of unusual pricing patterns requiring review
-- - Help ensure accurate reimbursement calculations

-- Main Query
WITH latest_two_periods AS (
  SELECT DISTINCT
    mimi_src_file_date
  FROM mimi_ws_1.cmspayment.partb_drug_noc_pricing
  ORDER BY mimi_src_file_date DESC
  LIMIT 2
),

price_comparison AS (
  SELECT 
    a.drug_generic_name_trade_name,
    a.dosage,
    a.payment_limit as current_payment,
    a.mimi_src_file_date as current_period,
    b.payment_limit as previous_payment,
    b.mimi_src_file_date as previous_period,
    -- Calculate price change percentage
    ((a.payment_limit - b.payment_limit) / b.payment_limit) * 100 as price_change_pct
  FROM mimi_ws_1.cmspayment.partb_drug_noc_pricing a
  LEFT JOIN mimi_ws_1.cmspayment.partb_drug_noc_pricing b
    ON a.drug_generic_name_trade_name = b.drug_generic_name_trade_name
    AND a.dosage = b.dosage
    AND b.mimi_src_file_date = (SELECT MIN(mimi_src_file_date) FROM latest_two_periods)
  WHERE a.mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM latest_two_periods)
)

SELECT 
  drug_generic_name_trade_name,
  dosage,
  current_payment,
  previous_payment,
  price_change_pct,
  CASE 
    WHEN ABS(price_change_pct) > 20 THEN 'High Variation'
    WHEN ABS(price_change_pct) > 10 THEN 'Moderate Variation'
    ELSE 'Normal'
  END as variation_flag
FROM price_comparison
WHERE previous_payment IS NOT NULL
  AND price_change_pct IS NOT NULL
ORDER BY ABS(price_change_pct) DESC;

-- How the query works:
-- 1. Identifies the most recent two reporting periods
-- 2. Compares drug prices between these periods
-- 3. Calculates percentage change in payment limits
-- 4. Flags variations exceeding certain thresholds
-- 5. Returns results sorted by magnitude of price change

-- Assumptions and Limitations:
-- - Assumes at least two periods of data are available
-- - Focuses only on drugs present in both periods
-- - Does not account for seasonal pricing variations
-- - Thresholds (20% and 10%) are arbitrary and may need adjustment
-- - Does not consider dosage differences in variation analysis

-- Possible Extensions:
-- 1. Add moving average calculations over more periods
-- 2. Include volume or utilization data if available
-- 3. Add statistical outlier detection methods
-- 4. Incorporate therapeutic category analysis
-- 5. Add regulatory compliance thresholds for specific drug categories

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:13:08.342006
    - Additional Notes: Query focuses on period-over-period price variations for Medicare Part B NOC drugs, using a 20% threshold for high variations and 10% for moderate variations. Best used for monthly or quarterly compliance monitoring. Requires at least two reporting periods of data to function properly.
    
    */