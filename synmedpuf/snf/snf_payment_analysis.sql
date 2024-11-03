-- snf_claims_payment_trends.sql

-- Business Purpose:
-- Analyze payment patterns and reimbursement trends for Skilled Nursing Facility (SNF) claims
-- to understand Medicare payment dynamics and identify potential revenue optimization opportunities.
-- This analysis helps facilities optimize their revenue cycle management and understand payment trends.

WITH monthly_payments AS (
    -- Calculate monthly payment metrics
    SELECT 
        DATE_TRUNC('month', clm_from_dt) AS claim_month,
        COUNT(DISTINCT bene_id) AS unique_patients,
        COUNT(DISTINCT clm_id) AS total_claims,
        SUM(clm_pmt_amt) AS total_payments,
        SUM(clm_tot_chrg_amt) AS total_charges,
        AVG(clm_pmt_amt) AS avg_payment_per_claim,
        SUM(clm_pmt_amt) / COUNT(DISTINCT bene_id) AS avg_payment_per_patient
    FROM mimi_ws_1.synmedpuf.snf
    WHERE 
        clm_from_dt IS NOT NULL 
        AND clm_pmt_amt IS NOT NULL
    GROUP BY DATE_TRUNC('month', clm_from_dt)
),

payment_stats AS (
    -- Calculate payment ratios and percentages
    SELECT 
        claim_month,
        unique_patients,
        total_claims,
        total_payments,
        total_charges,
        avg_payment_per_claim,
        avg_payment_per_patient,
        CASE 
            WHEN total_charges > 0 THEN (total_payments / total_charges) * 100 
            ELSE 0 
        END AS payment_to_charge_ratio
    FROM monthly_payments
)

-- Final output with ranked metrics
SELECT 
    claim_month,
    unique_patients,
    total_claims,
    ROUND(total_payments, 2) as total_payments,
    ROUND(avg_payment_per_claim, 2) as avg_payment_per_claim,
    ROUND(avg_payment_per_patient, 2) as avg_payment_per_patient,
    ROUND(payment_to_charge_ratio, 2) as payment_to_charge_ratio,
    -- Calculate month-over-month growth
    ROUND(((total_payments - LAG(total_payments) OVER (ORDER BY claim_month)) / 
           NULLIF(LAG(total_payments) OVER (ORDER BY claim_month), 0)) * 100, 2) 
           as payment_growth_pct
FROM payment_stats
ORDER BY claim_month;

-- How this query works:
-- 1. Groups claims by month to establish payment trends
-- 2. Calculates key payment metrics including per-claim and per-patient averages
-- 3. Computes payment-to-charge ratios to understand reimbursement efficiency
-- 4. Adds month-over-month growth analysis to identify trends

-- Assumptions and limitations:
-- 1. Assumes claim dates and payment amounts are populated and accurate
-- 2. Does not account for claim adjustments or corrections
-- 3. Month-over-month calculations may be affected by seasonal variations
-- 4. Payment patterns may not reflect current Medicare payment policies

-- Possible extensions:
-- 1. Add provider-level analysis to compare facility performance
-- 2. Include denial rates and reasons for payment variations
-- 3. Incorporate geographic analysis of payment patterns
-- 4. Add case-mix adjustment based on DRG codes
-- 5. Include analysis of specific revenue codes and HCPCS
-- 6. Compare payment patterns across different years

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:02:24.616585
    - Additional Notes: Query focuses on Medicare SNF payment trends and reimbursement patterns over time. Payment-to-charge ratios and growth calculations require non-zero values in the base amounts. Consider adding error handling for NULL or zero values in financial calculations. Monthly aggregation may need adjustment based on fiscal year requirements.
    
    */