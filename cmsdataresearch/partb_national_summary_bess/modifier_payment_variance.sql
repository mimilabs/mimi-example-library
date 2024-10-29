-- medicare_modifier_impact_analysis.sql

-- Business Purpose:
-- Analyze the financial impact of claim modifiers on Medicare Part B reimbursements.
-- This analysis helps healthcare organizations optimize billing practices and
-- understand how different modifiers affect payment rates for the same procedures.
-- Key insights support revenue cycle management and compliance efforts.

WITH base_metrics AS (
    -- Calculate base metrics for each HCPCS code without modifiers
    SELECT 
        hcpcs,
        description,
        SUM(allowed_services) as total_services,
        SUM(payment) as total_payment,
        AVG(payment/NULLIF(allowed_services,0)) as avg_payment_per_service
    FROM mimi_ws_1.cmsdataresearch.partb_national_summary_bess
    WHERE modifier IS NULL
    GROUP BY hcpcs, description
),
modifier_impact AS (
    -- Calculate metrics for services with modifiers
    SELECT 
        m.hcpcs,
        m.modifier,
        m.description,
        SUM(m.allowed_services) as mod_services,
        SUM(m.payment) as mod_payment,
        AVG(m.payment/NULLIF(m.allowed_services,0)) as mod_payment_per_service
    FROM mimi_ws_1.cmsdataresearch.partb_national_summary_bess m
    WHERE modifier IS NOT NULL
    GROUP BY m.hcpcs, m.modifier, m.description
)

SELECT 
    mi.hcpcs,
    mi.description,
    mi.modifier,
    mi.mod_services,
    mi.mod_payment_per_service,
    bm.avg_payment_per_service as base_payment_per_service,
    -- Calculate payment rate variance
    ((mi.mod_payment_per_service - bm.avg_payment_per_service) / 
     NULLIF(bm.avg_payment_per_service, 0) * 100) as payment_rate_variance_pct
FROM modifier_impact mi
JOIN base_metrics bm ON mi.hcpcs = bm.hcpcs
-- Focus on significant volume services
WHERE mi.mod_services >= 1000
ORDER BY ABS(payment_rate_variance_pct) DESC
LIMIT 20;

-- How it works:
-- 1. Creates a base metrics CTE for procedures without modifiers
-- 2. Creates a modifier impact CTE for procedures with modifiers
-- 3. Joins and compares the payment rates to calculate variance
-- 4. Filters for significant volume and sorts by impact

-- Assumptions and Limitations:
-- - Assumes modifier NULL represents base procedure rate
-- - Requires sufficient volume for meaningful comparison
-- - Does not account for geographical variations
-- - Limited to single year analysis

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include specialty-specific modifier analysis
-- 3. Add revenue opportunity calculations
-- 4. Expand to include denied claims analysis
-- 5. Create modifier combination impact analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:24:39.768023
    - Additional Notes: Query focuses on modifier-based payment variations for high-volume procedures, helping identify billing patterns that significantly impact reimbursement rates. Minimum threshold of 1000 services ensures statistical relevance. Results show top 20 procedures with largest payment variances.
    
    */