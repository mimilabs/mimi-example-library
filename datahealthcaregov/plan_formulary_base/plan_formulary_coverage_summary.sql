
/*******************************************************************************
Title: Healthcare Plan Drug Coverage Analysis
 
Business Purpose:
This query analyzes prescription drug coverage across health insurance plans by:
- Examining drug tier distributions
- Comparing copay vs coinsurance usage
- Evaluating mail order availability
- Tracking cost sharing requirements

This provides insights into plan affordability and coverage comprehensiveness.
*******************************************************************************/

-- Get most recent data file date
WITH latest_date AS (
  SELECT MAX(mimi_src_file_date) as max_date
  FROM mimi_ws_1.datahealthcaregov.plan_formulary_base
),

plan_summary AS (
  -- Aggregate key metrics at the plan level
  SELECT 
    plan_id,
    COUNT(DISTINCT drug_tier) as num_tiers,
    AVG(CASE WHEN mail_order = 'YES' THEN 1 ELSE 0 END) as mail_order_pct,
    AVG(CASE WHEN coinsurance_opt = 'YES' THEN 1 ELSE 0 END) as coinsurance_pct,
    AVG(CASE WHEN copay_opt = 'YES' THEN 1 ELSE 0 END) as copay_pct,
    AVG(COALESCE(coinsurance_rate, 0)) as avg_coinsurance,
    AVG(COALESCE(copay_amount, 0)) as avg_copay
  FROM mimi_ws_1.datahealthcaregov.plan_formulary_base f
  INNER JOIN latest_date d
  ON f.mimi_src_file_date = d.max_date
  GROUP BY plan_id
)

SELECT
  -- Calculate summary statistics across all plans
  COUNT(DISTINCT plan_id) as total_plans,
  ROUND(AVG(num_tiers),1) as avg_tiers_per_plan,
  ROUND(AVG(mail_order_pct)*100,1) as pct_drugs_mail_order,
  ROUND(AVG(coinsurance_pct)*100,1) as pct_drugs_with_coinsurance,
  ROUND(AVG(copay_pct)*100,1) as pct_drugs_with_copay,
  ROUND(AVG(avg_coinsurance),1) as typical_coinsurance_pct,
  ROUND(AVG(avg_copay),2) as typical_copay_amt
FROM plan_summary

/*
HOW IT WORKS:
1. Gets most recent data file date using mimi_src_file_date
2. Creates plan_summary CTE to aggregate metrics by plan
3. Calculates overall averages and percentages across plans
4. Filters for most recent data by joining with latest date

ASSUMPTIONS & LIMITATIONS:
- Assumes NULL values in cost sharing fields should be treated as 0
- Limited to point-in-time analysis based on mimi_src_file_date
- Averages may mask significant variation between plans
- Does not account for drug-specific differences

POSSIBLE EXTENSIONS:
1. Add trend analysis over time using mimi_src_file_date
2. Break down metrics by pharmacy_type
3. Compare metrics across different plan_id_types
4. Add drug tier distribution analysis
5. Identify outlier plans with unusual cost sharing patterns
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:54:47.540263
    - Additional Notes: Query aggregates drug coverage metrics across health plans using the most recent data snapshot, providing insights into tier structures, cost sharing methods, and mail order availability. Results are point-in-time and may not reflect current plan designs. All cost metrics are averages that could mask plan-level variations.
    
    */