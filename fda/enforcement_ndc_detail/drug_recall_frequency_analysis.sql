
/*******************************************************************************
Title: Drug Recall Analysis by NDC Package Details

Business Purpose:
This query analyzes drug recall patterns by connecting package-level NDC details 
with recall events to identify:
- Most frequently recalled drug products
- Recall patterns over time
- Potential quality control issues at the package/product level

This helps:
- Track product safety trends
- Identify recurring quality issues
- Support regulatory compliance monitoring
*******************************************************************************/

-- Main analysis query
WITH recalls_by_product AS (
    -- Get recall counts and date ranges by product NDC
    SELECT 
        product_ndc,
        COUNT(DISTINCT recall_number) as recall_count,
        MIN(mimi_src_file_date) as first_recall_date,
        MAX(mimi_src_file_date) as latest_recall_date
    FROM mimi_ws_1.fda.enforcement_ndc_detail
    WHERE product_ndc IS NOT NULL
    GROUP BY product_ndc
),
frequent_recalls AS (
    -- Identify products with multiple recalls
    SELECT *
    FROM recalls_by_product 
    WHERE recall_count > 1
    ORDER BY recall_count DESC
)

-- Final output with key metrics
SELECT
    f.product_ndc,
    f.recall_count,
    f.first_recall_date,
    f.latest_recall_date,
    DATEDIFF(day, f.first_recall_date, f.latest_recall_date) as days_between_recalls,
    COUNT(DISTINCT e.package_ndc) as affected_packages
FROM frequent_recalls f
JOIN mimi_ws_1.fda.enforcement_ndc_detail e 
    ON f.product_ndc = e.product_ndc
GROUP BY 
    f.product_ndc,
    f.recall_count,
    f.first_recall_date,
    f.latest_recall_date
ORDER BY f.recall_count DESC
LIMIT 100;

/*******************************************************************************
How This Query Works:
1. First CTE aggregates recall events by product NDC
2. Second CTE filters to products with multiple recalls
3. Final query joins back to get package details and calculates metrics

Assumptions & Limitations:
- Assumes product_ndc is the appropriate level for analysis
- Limited to products with multiple recalls
- Does not include recall reason or severity (would need join to enforcement table)
- Time window limited by data availability

Possible Extensions:
1. Join to enforcement table to include recall classification and reason
2. Add manufacturer/labeler analysis using NDC prefix
3. Create time-based trending analysis
4. Add comparison to industry averages
5. Include geographic distribution of recalls
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:23:47.895220
    - Additional Notes: Query focuses on identifying repeat recalls at the product level. For complete recall context, this should be joined with the main enforcement table to include recall reasons and classifications. Time window analysis depends on data refresh frequency in source table.
    
    */