-- Home Health Agency Claims - Patient Diagnosis Patterns Analysis
-- ====================================================================

/* Business Purpose:
   This query analyzes patterns in primary diagnoses for home health patients to:
   1. Identify the most common conditions requiring home health services
   2. Understand average costs and visit patterns by diagnosis
   3. Support care management program development
   4. Guide resource allocation and staffing decisions
*/

WITH diagnosis_grouping AS (
    -- Group claims by primary diagnosis and calculate key metrics
    SELECT 
        prncpal_dgns_cd,
        COUNT(DISTINCT bene_id) as unique_patients,
        COUNT(DISTINCT clm_id) as total_claims,
        AVG(clm_hha_tot_visit_cnt) as avg_visits_per_claim,
        AVG(clm_pmt_amt) as avg_payment_per_claim,
        SUM(clm_pmt_amt) as total_payments,
        AVG(DATEDIFF(clm_thru_dt, clm_from_dt)) as avg_episode_length
    FROM mimi_ws_1.synmedpuf.hha
    WHERE prncpal_dgns_cd IS NOT NULL
    GROUP BY prncpal_dgns_cd
),
ranked_diagnoses AS (
    -- Rank diagnoses by frequency and add cumulative percentages
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_claims DESC) as diagnosis_rank,
        SUM(total_claims) OVER (ORDER BY total_claims DESC) / 
            SUM(total_claims) OVER () * 100 as cumulative_pct
    FROM diagnosis_grouping
)
SELECT 
    diagnosis_rank,
    prncpal_dgns_cd as diagnosis_code,
    unique_patients,
    total_claims,
    ROUND(avg_visits_per_claim, 1) as avg_visits,
    ROUND(avg_payment_per_claim, 2) as avg_payment,
    ROUND(total_payments, 2) as total_payments,
    ROUND(avg_episode_length, 1) as avg_episode_days,
    ROUND(cumulative_pct, 1) as cumulative_pct
FROM ranked_diagnoses
WHERE diagnosis_rank <= 20  -- Focus on top 20 diagnoses
ORDER BY diagnosis_rank;

/* How this query works:
   1. First CTE groups claims by primary diagnosis and calculates key utilization metrics
   2. Second CTE ranks diagnoses and adds cumulative percentages
   3. Final SELECT formats results and limits to top 20 diagnoses

   Assumptions and Limitations:
   - Uses principal diagnosis only, not secondary diagnoses
   - Assumes diagnosis codes are standardized (ICD-9 or ICD-10)
   - Does not account for seasonal variations
   - Limited to basic utilization metrics

   Possible Extensions:
   1. Add diagnosis code descriptions through a lookup table
   2. Include year-over-year trend analysis
   3. Add geographic analysis by provider state
   4. Incorporate patient demographics
   5. Compare outcomes across different diagnoses
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:28:17.358500
    - Additional Notes: Query provides a top-20 ranking of home health diagnoses with utilization metrics. Note that diagnosis codes will need interpretation through a medical coding reference for meaningful business insights. Consider adding diagnosis descriptions via a lookup table for better readability.
    
    */