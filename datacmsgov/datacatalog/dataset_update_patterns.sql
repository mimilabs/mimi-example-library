-- CMS Dataset Access Pattern Analysis
-- Business Purpose: Analyze dataset update frequencies and access patterns to optimize 
-- data distribution strategies and identify high-value datasets for healthcare analytics.
-- This analysis helps organizations prioritize which CMS datasets to integrate into their
-- data pipelines and analytics workflows.

WITH update_frequency_ranked AS (
    -- Categorize and rank datasets by update frequency and access patterns
    SELECT 
        title,
        accrualPeriodicity,
        accessLevel,
        format,
        modified,
        COUNT(*) OVER (PARTITION BY accrualPeriodicity) as frequency_count,
        ROW_NUMBER() OVER (PARTITION BY accrualPeriodicity ORDER BY modified DESC) as recency_rank
    FROM mimi_ws_1.datacmsgov.datacatalog
    WHERE accrualPeriodicity IS NOT NULL
),

dataset_stats AS (
    -- Calculate key metrics about dataset availability
    SELECT 
        accrualPeriodicity,
        format,
        frequency_count,
        COUNT(DISTINCT title) as dataset_count,
        MAX(modified) as latest_update
    FROM update_frequency_ranked
    WHERE recency_rank <= 5
    GROUP BY accrualPeriodicity, format, frequency_count
)

SELECT 
    accrualPeriodicity as update_frequency,
    format as file_format,
    dataset_count,
    frequency_count as total_in_category,
    DATE(latest_update) as most_recent_update,
    ROUND(100.0 * dataset_count / frequency_count, 2) as category_coverage_pct
FROM dataset_stats
ORDER BY frequency_count DESC, dataset_count DESC;

-- How this query works:
-- 1. First CTE ranks datasets within each update frequency category
-- 2. Second CTE aggregates statistics about dataset availability
-- 3. Final SELECT formats results for business analysis

-- Assumptions and Limitations:
-- - Assumes accrualPeriodicity values are standardized
-- - Limited to datasets with non-null update frequencies
-- - Focus on most recent updates (top 5) per category

-- Possible Extensions:
-- 1. Add temporal analysis to track dataset freshness over time
-- 2. Include bureau code analysis to understand agency contributions
-- 3. Incorporate download URL availability to assess data accessibility
-- 4. Add dataset size or complexity metrics if available
-- 5. Create filtered views for specific healthcare domains

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:22:34.686199
    - Additional Notes: Query focuses on dataset maintenance patterns and can help identify the most actively maintained data categories. Note that the results may be skewed if there are inconsistencies in how update frequencies are recorded across different datasets.
    
    */