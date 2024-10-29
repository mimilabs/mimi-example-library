-- outpatient_service_complexity_analysis.sql

-- Business Purpose: 
-- Analyzes the complexity and specialization of outpatient hospital services by examining
-- the breadth of services (APCs) offered and average payments per beneficiary
-- Helps healthcare organizations understand service mix and competitive positioning
-- Supports strategic planning for service line development

WITH provider_metrics AS (
    -- Calculate service breadth and payment metrics per provider
    SELECT 
        rndrng_prvdr_ccn,
        rndrng_prvdr_org_name,
        rndrng_prvdr_state_abrvtn,
        COUNT(DISTINCT apc_cd) as unique_services,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        SUM(avg_mdcr_pymt_amt * capc_srvcs) / SUM(capc_srvcs) as avg_payment_per_service,
        SUM(avg_mdcr_pymt_amt * capc_srvcs) / SUM(bene_cnt) as avg_payment_per_beneficiary
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date = '2022-12-31'
    GROUP BY 1,2,3
    HAVING total_beneficiaries >= 1000  -- Focus on providers with significant volume
),
summary_stats AS (
    -- Calculate percentile thresholds for categorization
    SELECT
        percentile_cont(0.75) WITHIN GROUP (ORDER BY unique_services) as service_breadth_75th,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY avg_payment_per_beneficiary) as payment_intensity_75th
    FROM provider_metrics
)

-- Final output combining metrics with categorization
SELECT 
    pm.*,
    CASE 
        WHEN pm.unique_services > s.service_breadth_75th 
        AND pm.avg_payment_per_beneficiary > s.payment_intensity_75th
        THEN 'High Complexity'
        WHEN pm.unique_services > s.service_breadth_75th 
        THEN 'Broad Service Mix'
        WHEN pm.avg_payment_per_beneficiary > s.payment_intensity_75th
        THEN 'High Intensity'
        ELSE 'Standard Services'
    END as service_complexity_category
FROM provider_metrics pm
CROSS JOIN summary_stats s
ORDER BY avg_payment_per_beneficiary DESC
LIMIT 100;

-- How it works:
-- 1. First CTE calculates key metrics per provider including service breadth and payment intensity
-- 2. Second CTE determines 75th percentile thresholds for categorization
-- 3. Main query categorizes providers based on their metrics relative to thresholds
-- 4. Results show top 100 providers by payment per beneficiary with their service complexity category

-- Assumptions and Limitations:
-- - Requires minimum volume threshold (1000 beneficiaries) for meaningful analysis
-- - Uses 75th percentile as arbitrary cutoff for categorization
-- - Based on Medicare payments only, may not reflect total facility complexity
-- - Annual snapshot may miss seasonal variations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to track changes in service mix
-- 2. Include geographic analysis to identify regional patterns
-- 3. Add provider characteristics (size, ownership type) for deeper segmentation
-- 4. Create peer group comparisons based on similar provider characteristics
-- 5. Analyze relationship between service complexity and quality metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:14:38.010830
    - Additional Notes: Query requires sufficient data volume for meaningful percentile calculations. The 1000 beneficiary threshold and 75th percentile cutoffs should be adjusted based on specific analysis needs. Consider regional variations when interpreting complexity categories.
    
    */