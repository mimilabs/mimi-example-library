/*
Title: Medicare Prescription Drug Cost and Utilization Analysis

Business Purpose:
This query analyzes prescription drug events to understand:
- Total prescription costs and patient payments
- Prescription volume and average supply duration
- Cost burden on patients
These insights help evaluate drug affordability and usage patterns among Medicare beneficiaries.
*/

WITH prescription_metrics AS (
    -- Calculate key metrics per drug
    SELECT 
        prod_srvc_id,
        COUNT(*) as prescription_count,
        COUNT(DISTINCT desynpuf_id) as patient_count,
        ROUND(AVG(days_suply_num), 1) as avg_days_supply,
        ROUND(SUM(tot_rx_cst_amt), 2) as total_cost,
        ROUND(SUM(ptnt_pay_amt), 2) as total_patient_paid,
        ROUND(AVG(ptnt_pay_amt / tot_rx_cst_amt) * 100, 1) as avg_patient_share_pct
    FROM mimi_ws_1.desynpuf.prescription_drug_events
    WHERE srvc_dt IS NOT NULL 
      AND tot_rx_cst_amt > 0
    GROUP BY prod_srvc_id
)

SELECT 
    prod_srvc_id,
    prescription_count,
    patient_count,
    avg_days_supply,
    total_cost,
    total_patient_paid,
    avg_patient_share_pct,
    -- Calculate rankings
    ROW_NUMBER() OVER (ORDER BY prescription_count DESC) as volume_rank,
    ROW_NUMBER() OVER (ORDER BY total_cost DESC) as cost_rank
FROM prescription_metrics
WHERE prescription_count >= 100  -- Focus on commonly prescribed drugs
ORDER BY prescription_count DESC
LIMIT 20;

/*
How it works:
1. Creates a CTE to aggregate metrics for each unique drug
2. Calculates volume, cost, and patient payment statistics
3. Ranks drugs by prescription volume and total cost
4. Returns top 20 most prescribed medications

Assumptions and Limitations:
- Assumes non-null service dates and positive costs
- Limited to 2008-2010 timeframe
- Synthetic data may not reflect real-world patterns
- Minimum threshold of 100 prescriptions filters out rare drugs

Possible Extensions:
1. Add temporal analysis to show seasonal patterns:
   - Group by MONTH(srvc_dt) and analyze monthly trends

2. Include patient demographic analysis:
   - Join with beneficiary table to analyze by age/gender

3. Analyze geographic patterns:
   - Join with beneficiary table to analyze by region

4. Compare year-over-year changes:
   - Group by YEAR(srvc_dt) to show annual trends

5. Analyze cost distribution:
   - Add percentile calculations for costs
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:55:24.592911
    - Additional Notes: Query focuses on medications with 100+ prescriptions which may exclude important but less frequently prescribed specialty drugs. Cost analysis assumes tot_rx_cst_amt values are consistent and properly recorded. The avg_patient_share_pct calculation may be skewed for drugs with extreme cost variations.
    
    */