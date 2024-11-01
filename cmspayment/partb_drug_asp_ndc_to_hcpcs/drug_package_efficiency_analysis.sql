-- Title: Drug Package Billing Efficiency Analysis
-- Business Purpose: Analyzes drug packaging and billing unit relationships to:
-- - Identify opportunities for more efficient drug packaging
-- - Support procurement decisions by comparing package sizes across manufacturers
-- - Help optimize inventory management and billing practices
-- - Reduce waste and control costs in drug dispensing

WITH base_data AS (
    SELECT 
        hcpcs_code,
        drug_name,
        labeler_name,
        pkg_size,
        billunitspkg,
        mimi_src_file_date
    FROM mimi_ws_1.cmspayment.partb_drug_asp_ndc_to_hcpcs
    WHERE billunitspkg > 0 
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cmspayment.partb_drug_asp_ndc_to_hcpcs)
),

billing_metrics AS (
    SELECT 
        hcpcs_code,
        drug_name,
        labeler_name,
        pkg_size,
        billunitspkg,
        COUNT(*) OVER (PARTITION BY drug_name) as ndc_count,
        AVG(billunitspkg) OVER (PARTITION BY drug_name) as avg_billunits_for_drug
    FROM base_data
)

SELECT 
    drug_name,
    hcpcs_code,
    labeler_name,
    pkg_size,
    billunitspkg,
    ndc_count,
    ROUND(avg_billunits_for_drug, 2) as avg_billunits_for_drug,
    ROUND((billunitspkg / avg_billunits_for_drug), 2) as packaging_efficiency_ratio,
    CASE 
        WHEN billunitspkg < avg_billunits_for_drug * 0.8 THEN 'Below Average'
        WHEN billunitspkg > avg_billunits_for_drug * 1.2 THEN 'Above Average'
        ELSE 'Optimal Range'
    END as efficiency_category
FROM billing_metrics
WHERE ndc_count > 1  -- Focus on drugs with multiple NDCs
ORDER BY drug_name, packaging_efficiency_ratio DESC;

-- How it works:
-- 1. Creates a base CTE with filtered data
-- 2. Uses window functions to calculate metrics for each drug
-- 3. Computes efficiency ratios and categorizes packages
-- 4. Filters for drugs with multiple NDCs

-- Assumptions and Limitations:
-- - Assumes current package sizes are based on clinical needs
-- - Does not account for drug stability or storage requirements
-- - Limited to drugs with multiple NDCs for meaningful comparisons
-- - Based on latest available data only

-- Possible Extensions:
-- 1. Add trending analysis to track packaging changes over time
-- 2. Include price data to analyze cost implications
-- 3. Add therapeutic class grouping for broader comparisons
-- 4. Incorporate waste metrics based on typical prescription patterns
-- 5. Add geographical analysis of package size preferences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:47:10.912617
    - Additional Notes: Query focuses on drugs with multiple NDCs to compare packaging efficiency across manufacturers. Results show how each drug package size compares to the average for that drug, highlighting potential opportunities for packaging optimization. Latest data only is used for analysis.
    
    */