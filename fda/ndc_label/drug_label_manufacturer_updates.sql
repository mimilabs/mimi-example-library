-- Drug Label Evolution Analysis by Manufacturer
-- 
-- Business Purpose:
-- Track how drug labels have evolved over time by manufacturer to understand:
-- 1. Which companies are most actively updating their drug information
-- 2. The frequency and scope of label changes
-- 3. Potential regulatory compliance patterns
-- This helps identify industry leaders in drug information maintenance and possible areas 
-- requiring increased regulatory attention.

WITH label_versions AS (
    -- Get the count of label versions and latest update for each drug
    SELECT 
        SPLIT(package_ndc, '-')[0] as manufacturer_id,
        package_ndc,
        COUNT(DISTINCT version) as version_count,
        MAX(effective_time) as latest_update,
        MIN(effective_time) as first_label_date
    FROM mimi_ws_1.fda.ndc_label
    WHERE package_ndc IS NOT NULL 
    GROUP BY manufacturer_id, package_ndc
),

manufacturer_stats AS (
    -- Calculate statistics by manufacturer
    SELECT 
        manufacturer_id,
        COUNT(DISTINCT package_ndc) as total_products,
        AVG(version_count) as avg_versions_per_drug,
        COUNT(CASE WHEN version_count > 1 THEN 1 END) as products_with_updates,
        MAX(latest_update) as most_recent_update,
        MIN(first_label_date) as earliest_label
    FROM label_versions
    GROUP BY manufacturer_id
)

SELECT 
    manufacturer_id,
    total_products,
    ROUND(avg_versions_per_drug, 2) as avg_versions_per_drug,
    products_with_updates,
    ROUND(100.0 * products_with_updates / total_products, 2) as pct_products_updated,
    most_recent_update,
    earliest_label,
    DATEDIFF(most_recent_update, earliest_label) as days_of_history
FROM manufacturer_stats
WHERE total_products >= 5  -- Focus on manufacturers with meaningful product portfolios
ORDER BY total_products DESC, avg_versions_per_drug DESC
LIMIT 100;

-- How this query works:
-- 1. First CTE extracts manufacturer IDs from NDC codes and counts versions per drug
-- 2. Second CTE aggregates statistics at the manufacturer level
-- 3. Final SELECT formats and filters results for meaningful analysis

-- Assumptions and Limitations:
-- 1. Assumes manufacturer ID is first segment of package_ndc
-- 2. Only includes manufacturers with 5+ products for statistical relevance
-- 3. Does not account for manufacturer name changes or M&A activity
-- 4. Version numbers are assumed to be sequential and complete

-- Possible Extensions:
-- 1. Add manufacturer name lookup table for better identification
-- 2. Include analysis of specific types of label changes (safety, dosing, etc.)
-- 3. Compare update patterns across different drug classes
-- 4. Add seasonality analysis of label updates
-- 5. Include text analysis of change magnitude between versions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:08:08.425600
    - Additional Notes: Query requires manufacturer IDs from package_ndc field to be populated and valid. Performance may be impacted with very large datasets due to the string splitting operation. Consider adding an index on package_ndc and effective_time if query performance is slow.
    
    */