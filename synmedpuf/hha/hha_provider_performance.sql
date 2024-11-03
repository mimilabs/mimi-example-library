-- Home Health Agency Claims - Provider Performance Analysis
-- ========================================================

/* Business Purpose:
   This query analyzes HHA provider performance to identify:
   1. Provider service volumes and financial efficiency
   2. Geographic distribution of high-performing providers
   3. Average payment amounts and total charges by provider
   
   Key metrics help identify opportunities for network optimization
   and benchmark provider performance.
*/

WITH provider_metrics AS (
  -- Calculate key metrics by provider
  SELECT 
    prvdr_num,
    prvdr_state_cd,
    COUNT(DISTINCT bene_id) as total_patients,
    COUNT(DISTINCT clm_id) as total_claims,
    AVG(clm_pmt_amt) as avg_payment_per_claim,
    AVG(clm_tot_chrg_amt) as avg_charges_per_claim,
    AVG(clm_hha_tot_visit_cnt) as avg_visits_per_claim,
    SUM(clm_pmt_amt) as total_payments,
    SUM(clm_tot_chrg_amt) as total_charges,
    -- Calculate payment ratio as efficiency metric
    ROUND(SUM(clm_pmt_amt) / NULLIF(SUM(clm_tot_chrg_amt), 0), 3) as payment_to_charge_ratio
  FROM mimi_ws_1.synmedpuf.hha
  WHERE prvdr_num IS NOT NULL
  GROUP BY prvdr_num, prvdr_state_cd
),

provider_rankings AS (
  -- Add rankings based on volume and efficiency
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY total_patients DESC) as volume_rank,
    ROW_NUMBER() OVER (ORDER BY payment_to_charge_ratio DESC) as efficiency_rank
  FROM provider_metrics
)

-- Final output with key performance indicators
SELECT
  pr.*,
  CASE 
    WHEN volume_rank <= 10 AND efficiency_rank <= 10 THEN 'Top Performer'
    WHEN volume_rank <= 10 THEN 'High Volume'
    WHEN efficiency_rank <= 10 THEN 'High Efficiency'
    ELSE 'Standard'
  END as performance_tier
FROM provider_rankings pr
WHERE total_patients >= 5  -- Filter out very low volume providers
ORDER BY total_patients DESC;

/* How this query works:
   1. First CTE aggregates key metrics by provider
   2. Second CTE adds performance rankings
   3. Final SELECT adds performance categorization
   
   Assumptions and Limitations:
   - Requires valid provider numbers
   - Payment to charge ratio assumes charges are consistently recorded
   - Rankings may be affected by provider size/scope
   - Synthetic data may not reflect real-world patterns
   
   Possible Extensions:
   1. Add temporal trending by including date dimensions
   2. Include quality metrics like readmissions
   3. Add patient demographic analysis by provider
   4. Incorporate diagnosis mix complexity
   5. Compare performance across geographic regions
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:49:13.199123
    - Additional Notes: Query expects minimum of 5 patients per provider for meaningful analysis. Payment-to-charge ratios may be zero if total charges are null. Performance tier calculations assume normal distribution of provider volumes.
    
    */