
/*******************************************************************************
Title: SNF Claims Analysis - Key Metrics
 
Business Purpose:
This query analyzes Skilled Nursing Facility (SNF) claims data to derive key
business metrics around utilization, costs, and length of stay. These metrics
help understand SNF service patterns and financial impacts for Medicare patients.

Created: 2024-02
*******************************************************************************/

-- Main query to calculate key SNF metrics
SELECT 
    -- Time period metrics
    YEAR(clm_from_dt) as claim_year,
    COUNT(DISTINCT bene_id) as total_patients,
    
    -- Utilization metrics 
    COUNT(clm_id) as total_claims,
    AVG(clm_utlztn_day_cnt) as avg_length_of_stay,
    
    -- Financial metrics
    AVG(clm_pmt_amt) as avg_payment_per_claim,
    AVG(clm_tot_chrg_amt) as avg_total_charges,
    SUM(clm_pmt_amt) as total_payments,
    
    -- Patient status metrics
    COUNT(DISTINCT CASE WHEN ptnt_dschrg_stus_cd = '01' THEN clm_id END) as discharged_to_home,
    COUNT(DISTINCT CASE WHEN ptnt_dschrg_stus_cd = '30' THEN clm_id END) as still_patient

FROM mimi_ws_1.synmedpuf.snf

WHERE 
    -- Filter to claims with valid dates and amounts
    clm_from_dt IS NOT NULL
    AND clm_pmt_amt > 0

GROUP BY 
    YEAR(clm_from_dt)

ORDER BY 
    claim_year;

/*******************************************************************************
HOW THIS QUERY WORKS:
1. Groups SNF claims by year to show trends over time
2. Calculates key volume metrics (patients, claims)
3. Determines average length of stay and financial metrics
4. Tracks discharge status patterns

ASSUMPTIONS & LIMITATIONS:
- Assumes claim dates and payment amounts are valid
- Limited to basic metrics - does not include clinical outcomes
- Synthetic data may not perfectly reflect real-world patterns
- Does not account for incomplete years of data

POSSIBLE EXTENSIONS:
1. Add geographic analysis by provider_state_cd
2. Include diagnosis patterns using ICD codes
3. Compare metrics across different patient demographics
4. Add seasonal/monthly trending
5. Calculate readmission rates
6. Add quality metrics based on outcomes
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:52:39.487896
    - Additional Notes: This query provides a high-level overview of SNF utilization and cost trends by year. The metrics are aggregated at an annual level, which may mask seasonal variations. The payment analysis assumes all claims have valid payment amounts greater than zero, which could exclude denied or zero-payment claims that might be relevant for some analyses.
    
    */