-- Title: NDC Package Consistency Check Across Drug Recalls
-- Business Purpose: 
-- This query validates the consistency and completeness of NDC coding across drug recalls
-- by comparing package_ndc, product_ndc, and cms_ndc formats. This helps:
-- 1. Ensure data quality for regulatory compliance
-- 2. Identify potential data discrepancies that could affect patient safety
-- 3. Support accurate drug product tracking across healthcare systems

WITH ndc_validation AS (
    -- First get all unique NDC combinations and flag potential mismatches
    SELECT 
        package_ndc,
        product_ndc,
        cms_ndc,
        COUNT(DISTINCT recall_number) as recall_count,
        -- Check if product NDC is properly contained in package NDC
        package_ndc LIKE concat(product_ndc, '%') as valid_ndc_hierarchy,
        -- Check if CMS NDC format follows expected pattern
        LENGTH(cms_ndc) = 11 as valid_cms_format
    FROM mimi_ws_1.fda.enforcement_ndc_detail
    GROUP BY 1,2,3
)

SELECT 
    CASE 
        WHEN valid_ndc_hierarchy AND valid_cms_format THEN 'FULLY_VALID'
        WHEN valid_ndc_hierarchy AND NOT valid_cms_format THEN 'INVALID_CMS'
        WHEN NOT valid_ndc_hierarchy AND valid_cms_format THEN 'INVALID_HIERARCHY'
        ELSE 'MULTIPLE_ISSUES'
    END as validation_status,
    COUNT(*) as ndc_combinations,
    SUM(recall_count) as total_recalls,
    ROUND(AVG(recall_count), 2) as avg_recalls_per_combination,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () as percentage_of_total
FROM ndc_validation
GROUP BY 1
ORDER BY ndc_combinations DESC;

-- How it works:
-- 1. Creates a CTE that validates NDC format consistency for each unique combination
-- 2. Checks both hierarchical relationship between package/product NDCs and CMS format
-- 3. Aggregates results into meaningful validation categories with recall impact metrics

-- Assumptions and Limitations:
-- 1. Assumes package_ndc should contain product_ndc as a prefix
-- 2. Assumes CMS NDC should be exactly 11 digits
-- 3. Does not validate specific format patterns beyond length
-- 4. Does not check for valid labeler codes

-- Possible Extensions:
-- 1. Add specific NDC format pattern validation using regex
-- 2. Include temporal analysis to track data quality trends
-- 3. Cross-reference with other NDC reference tables for completeness
-- 4. Add labeler code validation against FDA directory
-- 5. Generate detailed error reports for specific validation failures

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:49:18.155480
    - Additional Notes: Query focuses on data quality assurance by validating NDC formatting across different standards (package, product, CMS). Results are stratified by validation status and include impact metrics like recall counts. Useful for regulatory compliance teams and data stewards monitoring drug product identifier consistency.
    
    */