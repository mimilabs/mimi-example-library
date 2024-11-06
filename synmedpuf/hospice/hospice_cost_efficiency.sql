/* hospice_cost_analysis.sql */

/* Business Purpose:
   Analyze hospice care costs and length of stay patterns to help:
   1. Healthcare payers optimize hospice benefit management
   2. Providers benchmark their costs against averages
   3. Identify opportunities for cost efficiency while maintaining quality care
*/

WITH hospice_stays AS (
    -- Calculate core metrics for each hospice stay
    SELECT 
        bene_id,
        clm_id,
        prvdr_num,
        prvdr_state_cd,
        clm_from_dt,
        clm_thru_dt,
        clm_pmt_amt,
        clm_tot_chrg_amt,
        prncpal_dgns_cd,
        DATEDIFF(clm_thru_dt, clm_from_dt) + 1 AS length_of_stay,
        clm_tot_chrg_amt / NULLIF(DATEDIFF(clm_thru_dt, clm_from_dt) + 1, 0) AS cost_per_day
    FROM mimi_ws_1.synmedpuf.hospice
    WHERE clm_from_dt IS NOT NULL 
    AND clm_thru_dt IS NOT NULL
),

provider_summary AS (
    -- Aggregate metrics by provider
    SELECT 
        prvdr_num,
        prvdr_state_cd,
        COUNT(DISTINCT bene_id) as total_patients,
        AVG(length_of_stay) as avg_length_of_stay,
        AVG(cost_per_day) as avg_cost_per_day,
        SUM(clm_pmt_amt) as total_medicare_payments,
        SUM(clm_tot_chrg_amt) as total_charges
    FROM hospice_stays
    GROUP BY prvdr_num, prvdr_state_cd
)

-- Final summary with cost efficiency metrics
SELECT 
    prvdr_state_cd,
    COUNT(DISTINCT prvdr_num) as provider_count,
    SUM(total_patients) as total_patients,
    ROUND(AVG(avg_length_of_stay), 1) as avg_length_of_stay_days,
    ROUND(AVG(avg_cost_per_day), 2) as avg_cost_per_day_dollars,
    ROUND(SUM(total_medicare_payments)/SUM(total_patients), 2) as avg_payment_per_patient,
    ROUND(AVG(total_medicare_payments/NULLIF(total_charges, 0)) * 100, 1) as avg_payment_to_charge_ratio
FROM provider_summary
GROUP BY prvdr_state_cd
HAVING provider_count >= 3  -- Ensure adequate sample size
ORDER BY avg_payment_per_patient DESC;

/* How it works:
   1. First CTE calculates key metrics for each hospice stay
   2. Second CTE aggregates data at the provider level
   3. Final query summarizes by state with cost efficiency metrics
   
   Assumptions and Limitations:
   - Assumes clm_from_dt and clm_thru_dt accurately represent care duration
   - Limited to Medicare fee-for-service claims
   - Does not account for severity mix or quality outcomes
   - State-level analysis may mask local market variations
   
   Possible Extensions:
   1. Add diagnosis mix analysis to understand cost variations
   2. Include quality metrics like readmission rates
   3. Analyze seasonal patterns in costs and utilization
   4. Compare urban vs rural cost patterns
   5. Track year-over-year cost trends
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:21:46.057538
    - Additional Notes: Query examines cost efficiency across hospice providers by calculating key financial metrics like cost per day, length of stay, and payment-to-charge ratios. State-level aggregation requires minimum of 3 providers per state to ensure statistical relevance. Results can help identify states with potentially inefficient cost structures or unusual payment patterns.
    
    */