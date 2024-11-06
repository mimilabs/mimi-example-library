-- Medicare Outpatient Claims: Provider Performance and Cost Analysis

/*
Business Purpose:
Analyze provider performance and cost efficiency in Medicare outpatient services by:
- Identifying top providers by total claim volume and total charges
- Calculating average payment and charge metrics per provider
- Providing insights into provider-level Medicare outpatient service economics
*/

WITH provider_performance AS (
    -- Aggregate claims data at the provider level
    SELECT 
        org_npi_num AS provider_npi,
        COUNT(DISTINCT clm_id) AS total_claims,
        SUM(clm_tot_chrg_amt) AS total_charges,
        SUM(clm_pmt_amt) AS total_payments,
        AVG(clm_pmt_amt) AS avg_payment_per_claim,
        AVG(clm_tot_chrg_amt) AS avg_charge_per_claim
    FROM mimi_ws_1.synmedpuf.outpatient
    WHERE org_npi_num IS NOT NULL
    GROUP BY org_npi_num
),
provider_ranking AS (
    -- Rank providers by total claims and charges
    SELECT 
        provider_npi,
        total_claims,
        total_charges,
        total_payments,
        avg_payment_per_claim,
        avg_charge_per_claim,
        DENSE_RANK() OVER (ORDER BY total_claims DESC) AS claims_volume_rank,
        DENSE_RANK() OVER (ORDER BY total_charges DESC) AS charges_volume_rank
    FROM provider_performance
)

-- Select top 50 providers by claims volume with performance metrics
SELECT 
    provider_npi,
    total_claims,
    total_charges,
    total_payments,
    avg_payment_per_claim,
    avg_charge_per_claim,
    claims_volume_rank,
    charges_volume_rank
FROM provider_ranking
WHERE claims_volume_rank <= 50
ORDER BY total_claims DESC, total_charges DESC;

/*
Query Mechanics:
1. Aggregates outpatient claims by provider NPI 
2. Calculates key performance metrics
3. Ranks providers by claims and charges volume
4. Returns top 50 providers with detailed metrics

Assumptions and Limitations:
- Requires valid/non-null provider NPI
- Uses synthetic data, not real Medicare claims
- Rankings based on total claims count and charges

Potential Extensions:
- Add geographic filtering (prvdr_state_cd)
- Include diagnosis or procedure type analysis
- Incorporate time-based trending analysis
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:55:22.200593
    - Additional Notes: Query uses synthetic Medicare outpatient data to rank providers by claims volume and calculate key financial metrics. Requires valid provider NPI and uses DENSE_RANK for ranking. Results limited to top 50 providers by claims count.
    
    */