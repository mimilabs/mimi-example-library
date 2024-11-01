-- drug_recall_manufacturer_trends.sql 

-- Business Purpose:
-- Identify manufacturers with recurring quality issues by analyzing their recall patterns
-- Support vendor quality assessment and risk management decisions
-- Help healthcare organizations evaluate supplier reliability
-- Guide regulatory compliance monitoring efforts

-- Main Query
WITH manufacturer_metrics AS (
    SELECT 
        recalling_firm,
        COUNT(DISTINCT recall_number) as total_recalls,
        COUNT(DISTINCT CASE WHEN classification = 'I' THEN recall_number END) as class_1_recalls,
        AVG(DATEDIFF(days, recall_initiation_date, report_date)) as avg_reporting_delay,
        COUNT(DISTINCT EXTRACT(year FROM recall_initiation_date)) as years_with_recalls,
        -- Using MAX to show example products instead of STRING_AGG
        MAX(product_description) as example_product
    FROM mimi_ws_1.fda.enforcement
    WHERE recall_initiation_date >= '2018-01-01'
    GROUP BY recalling_firm
),
ranked_manufacturers AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (ORDER BY total_recalls DESC) as recall_rank,
        (class_1_recalls * 100.0 / NULLIF(total_recalls, 0)) as pct_serious_recalls
    FROM manufacturer_metrics
    WHERE total_recalls >= 3  -- Focus on manufacturers with multiple recalls
)
SELECT 
    recalling_firm,
    total_recalls,
    class_1_recalls,
    ROUND(pct_serious_recalls, 1) as pct_serious_recalls,
    ROUND(avg_reporting_delay, 1) as avg_reporting_delay_days,
    years_with_recalls,
    example_product as product_example
FROM ranked_manufacturers
WHERE recall_rank <= 20
ORDER BY total_recalls DESC, pct_serious_recalls DESC;

-- How it works:
-- 1. First CTE aggregates key metrics for each manufacturer
-- 2. Second CTE ranks manufacturers and calculates additional metrics
-- 3. Final query filters to top 20 manufacturers by recall count
-- 4. Results ordered by total recalls and percentage of serious recalls

-- Assumptions and Limitations:
-- - Focuses on recalls from 2018 onwards for recent relevance
-- - Requires at least 3 recalls to filter out one-time incidents
-- - Assumes manufacturer names are consistently recorded
-- - Does not account for company size or production volume
-- - Shows only one example product per manufacturer

-- Possible Extensions:
-- 1. Add trend analysis showing if recall frequency is increasing/decreasing
-- 2. Include geographic distribution of recalls by manufacturer
-- 3. Analyze seasonal patterns in recalls by manufacturer
-- 4. Compare voluntary vs mandated recall patterns
-- 5. Add recall resolution time analysis (based on status changes)
-- 6. Include correlation with specific product categories or therapeutic areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:04:43.213844
    - Additional Notes: Query focuses on identifying high-risk manufacturers based on recall frequency and severity. The avg_reporting_delay metric may be useful for identifying manufacturers with potential reporting compliance issues. Note that the analysis is limited to manufacturers with 3+ recalls since 2018 to ensure statistical relevance.
    
    */