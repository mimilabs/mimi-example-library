-- Title: Drug Recall Supply Chain Risk Assessment
-- Business Purpose:
-- This query helps identify potential supply chain vulnerabilities by analyzing:
-- 1. Drug products with multiple recalls across different NDC packages
-- 2. Relationships between product-level and package-level recalls
-- 3. Temporal patterns in recall events for supply chain risk monitoring

WITH product_recall_counts AS (
    -- First aggregate recalls at the product NDC level
    SELECT 
        product_ndc,
        COUNT(DISTINCT recall_number) as recall_count,
        COUNT(DISTINCT package_ndc) as affected_packages,
        MIN(mimi_src_file_date) as first_recall_date,
        MAX(mimi_src_file_date) as last_recall_date
    FROM mimi_ws_1.fda.enforcement_ndc_detail
    WHERE product_ndc IS NOT NULL
    GROUP BY product_ndc
),

high_risk_products AS (
    -- Identify products with multiple recalls or multiple affected packages
    SELECT *
    FROM product_recall_counts
    WHERE recall_count > 1 
    OR affected_packages > 1
)

-- Final output focusing on supply chain risk indicators
SELECT 
    h.product_ndc,
    h.recall_count,
    h.affected_packages,
    h.first_recall_date,
    h.last_recall_date,
    DATEDIFF(day, h.first_recall_date, h.last_recall_date) as recall_span_days,
    -- Calculate risk metrics
    CASE 
        WHEN h.recall_count >= 3 OR h.affected_packages >= 3 THEN 'High'
        WHEN h.recall_count = 2 OR h.affected_packages = 2 THEN 'Medium'
        ELSE 'Low'
    END as supply_chain_risk_level
FROM high_risk_products h
ORDER BY h.recall_count DESC, h.affected_packages DESC;

-- How this query works:
-- 1. Creates initial aggregation of recalls by product NDC
-- 2. Identifies products with multiple recalls or affected packages
-- 3. Calculates risk metrics based on recall patterns
-- 4. Presents results ordered by risk severity

-- Assumptions and limitations:
-- 1. Assumes product_ndc is a reliable identifier across packages
-- 2. Risk levels are simplified into three categories
-- 3. Does not account for recall severity or reason
-- 4. Limited to the time period available in the source data

-- Possible extensions:
-- 1. Join with enforcement base table to include recall classification
-- 2. Add manufacturer/labeler analysis using NDC prefix
-- 3. Incorporate seasonal patterns in recall activity
-- 4. Add geographic distribution of affected products
-- 5. Include recall reason analysis for supply chain implications

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:41:20.673191
    - Additional Notes: Query focuses on product-level risk patterns rather than individual recalls. The risk scoring system (High/Medium/Low) is a simplified model based on recall frequency and package count only. For complete risk assessment, consider joining with the base enforcement table to incorporate recall classification and reason codes.
    
    */