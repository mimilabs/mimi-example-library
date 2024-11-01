-- outlier_payment_patterns.sql

-- Business Purpose:
-- Analyzes patterns in Medicare outlier payments for outpatient hospital services
-- Identifies providers with high rates of outlier cases and associated costs
-- Helps detect potential areas for cost management and quality improvement
-- Supports strategic planning for healthcare organizations and payers

WITH provider_summary AS (
    -- Aggregate metrics at the provider level
    SELECT 
        rndrng_prvdr_ccn,
        rndrng_prvdr_org_name,
        rndrng_prvdr_state_abrvtn,
        SUM(capc_srvcs) as total_services,
        SUM(outlier_srvcs) as total_outlier_services,
        AVG(avg_mdcr_outlier_amt) as avg_outlier_payment,
        SUM(outlier_srvcs * avg_mdcr_outlier_amt) as total_outlier_payments
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'  -- Most recent full year
    GROUP BY 1,2,3
    HAVING total_services >= 1000  -- Focus on providers with significant volume
)

SELECT 
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    total_services,
    total_outlier_services,
    ROUND(100.0 * total_outlier_services / total_services, 2) as outlier_rate_pct,
    ROUND(avg_outlier_payment, 2) as avg_outlier_payment,
    ROUND(total_outlier_payments, 2) as total_outlier_payments
FROM provider_summary
WHERE total_outlier_services > 0
ORDER BY outlier_rate_pct DESC
LIMIT 50;

-- How it works:
-- 1. Creates a CTE to aggregate key metrics at the provider level
-- 2. Calculates outlier rates and payments for providers
-- 3. Filters to show only providers with outlier cases
-- 4. Orders results by outlier rate to identify highest-impact providers

-- Assumptions and Limitations:
-- - Assumes 2022 data is most recent and complete
-- - Limited to providers with 1000+ total services for statistical significance
-- - Does not account for case mix or provider specialization
-- - Outlier payments may be justified by complex cases

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include APC-level breakdown for high outlier providers
-- 3. Incorporate geographic analysis of outlier patterns
-- 4. Compare outlier rates against quality metrics
-- 5. Add peer group comparisons by provider size or type

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:11:43.109993
    - Additional Notes: The query focuses on providers with high volumes of outlier cases in Medicare outpatient services, which could indicate complex patient populations or potential billing patterns requiring review. The 1000+ services threshold helps ensure statistical reliability but may exclude smaller facilities with legitimate outlier patterns.
    
    */