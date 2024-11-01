-- identifying_high_cost_specialty_biologics.sql

-- Business Purpose:
-- This query identifies high-cost specialty biologics and their payment characteristics
-- to support formulary management, cost containment, and contracting strategies.
-- Understanding these drugs is critical for:
-- - Specialty pharmacy program development
-- - Value-based contract negotiations
-- - Prior authorization criteria development
-- - Patient cost-sharing optimization

SELECT 
    hcpcs_code,
    short_description,
    hcpcs_code_dosage,
    payment_limit,
    coinsurance_percentage,
    mimi_src_file_date,
    
    -- Calculate annualized cost assuming monthly administration
    ROUND(payment_limit * 12, 2) as estimated_annual_cost,
    
    -- Calculate patient out-of-pocket exposure
    ROUND(payment_limit * (coinsurance_percentage/100), 2) as patient_cost_share
    
FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing

-- Focus on most recent pricing data
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing
)

-- Filter for likely specialty biologics based on payment threshold
AND payment_limit >= 5000

-- Sort by payment impact
ORDER BY payment_limit DESC
LIMIT 20;

-- How this query works:
-- 1. Selects key fields needed for specialty drug analysis
-- 2. Calculates estimated annual cost and patient exposure
-- 3. Filters to most recent pricing period
-- 4. Identifies high-cost drugs using $5000 threshold
-- 5. Returns top 20 drugs by payment amount

-- Assumptions & Limitations:
-- - $5000 threshold is a proxy for specialty drugs
-- - Annual cost assumes monthly administration
-- - Does not account for multiple doses per month
-- - Patient cost share calculation assumes no secondary insurance
-- - Limited to 20 drugs for initial analysis

-- Possible Extensions:
-- - Add therapeutic category classification
-- - Compare pricing trends across quarters
-- - Include utilization data if available
-- - Add biosimilar availability indicators
-- - Incorporate site-of-care cost differentials
-- - Analyze patient access implications of cost sharing
-- - Include payer mix and coverage policy analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:38:25.220497
    - Additional Notes: Query identifies high-cost specialty biologics with payment thresholds above $5000 and calculates annual cost projections. The $5000 threshold and monthly administration assumption should be adjusted based on specific program requirements. Results limited to top 20 drugs from most recent pricing period.
    
    */