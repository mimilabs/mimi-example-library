-- Title: Practice Size Category Analysis for Healthcare Technology Planning
-- Business Purpose: This query analyzes the distribution of healthcare practices by size categories
-- to support:
-- - Strategic planning for healthcare IT system deployments
-- - Resource allocation for implementation support
-- - Understanding the healthcare delivery landscape
-- - Identifying target markets for health IT solutions

WITH practice_categories AS (
    SELECT 
        -- Create meaningful practice size categories
        CASE 
            WHEN practice_size <= 5 THEN 'Very Small (1-5)'
            WHEN practice_size <= 15 THEN 'Small (6-15)'
            WHEN practice_size <= 50 THEN 'Medium (16-50)'
            WHEN practice_size <= 100 THEN 'Large (51-100)'
            ELSE 'Enterprise (100+)'
        END AS practice_size_category,
        
        -- Count unique practices and providers
        COUNT(DISTINCT grp_key) as practice_count,
        COUNT(DISTINCT npi) as provider_count,
        
        -- Calculate technology adoption metrics
        COUNT(DISTINCT developer) as unique_vendors,
        COUNT(DISTINCT product) as unique_products,
        
        -- Get most recent reporting date
        MAX(mimi_src_file_date) as latest_report_date
        
    FROM mimi_ws_1.healthit.chit_cpip
    WHERE practice_size IS NOT NULL
    GROUP BY 
        CASE 
            WHEN practice_size <= 5 THEN 'Very Small (1-5)'
            WHEN practice_size <= 15 THEN 'Small (6-15)'
            WHEN practice_size <= 50 THEN 'Medium (16-50)'
            WHEN practice_size <= 100 THEN 'Large (51-100)'
            ELSE 'Enterprise (100+)'
        END
)

SELECT 
    practice_size_category,
    practice_count,
    provider_count,
    unique_vendors,
    unique_products,
    -- Calculate key metrics
    ROUND(provider_count::FLOAT / practice_count, 1) as avg_providers_per_practice,
    ROUND(unique_products::FLOAT / practice_count * 100, 1) as products_per_100_practices,
    latest_report_date
FROM practice_categories
ORDER BY 
    -- Order from smallest to largest practices
    CASE practice_size_category
        WHEN 'Very Small (1-5)' THEN 1
        WHEN 'Small (6-15)' THEN 2
        WHEN 'Medium (16-50)' THEN 3
        WHEN 'Large (51-100)' THEN 4
        WHEN 'Enterprise (100+)' THEN 5
    END;

-- How this query works:
-- 1. Creates practice size categories using CASE statement
-- 2. Groups practices by these categories
-- 3. Calculates key metrics including unique practices, providers, and technology adoption
-- 4. Derives additional metrics like average providers per practice
-- 5. Orders results by practice size category

-- Assumptions and limitations:
-- - Practice size data is accurate and current
-- - Each grp_key represents a unique practice
-- - All practices have valid size data
-- - Technology adoption is represented by unique products/vendors

-- Possible extensions:
-- 1. Add temporal analysis to track changes over time
-- 2. Include geographic distribution within size categories
-- 3. Add technology edition analysis (2015 vs 2015 Cures Update)
-- 4. Incorporate specialty mix within practice size categories
-- 5. Add financial metrics if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:43:43.942141
    - Additional Notes: Query aggregates practices into standardized size categories (Very Small to Enterprise) and calculates key adoption metrics per category. Performance may be impacted with very large datasets due to multiple DISTINCT counts. Consider adding date filters if analyzing specific time periods.
    
    */