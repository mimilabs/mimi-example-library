-- CMS Dataset Quality Analysis
-- Business Purpose: Analyze the completeness and accessibility of CMS datasets to identify gaps
-- and opportunities for improving data governance and user experience.
-- This analysis helps prioritize dataset maintenance and documentation efforts.

WITH dataset_metrics AS (
  SELECT
    -- Evaluate core metadata completeness
    COUNT(*) as total_datasets,
    SUM(CASE WHEN description IS NOT NULL AND LENGTH(description) > 50 THEN 1 ELSE 0 END) as well_described,
    SUM(CASE WHEN describedBy IS NOT NULL THEN 1 ELSE 0 END) as has_data_dictionary,
    SUM(CASE WHEN downloadURL IS NOT NULL THEN 1 ELSE 0 END) as directly_downloadable,
    
    -- Analyze update patterns
    SUM(CASE WHEN modified >= DATE_ADD(CURRENT_DATE(), -90) THEN 1 ELSE 0 END) as recently_updated,
    
    -- Check documentation quality indicators
    SUM(CASE WHEN temporal IS NOT NULL THEN 1 ELSE 0 END) as has_time_coverage,
    SUM(CASE WHEN accessLevel = 'public' THEN 1 ELSE 0 END) as public_datasets
  FROM mimi_ws_1.datacmsgov.datacatalog
),
quality_scores AS (
  SELECT
    total_datasets,
    ROUND(100.0 * well_described / total_datasets, 1) as pct_well_described,
    ROUND(100.0 * has_data_dictionary / total_datasets, 1) as pct_with_dictionary,
    ROUND(100.0 * directly_downloadable / total_datasets, 1) as pct_downloadable,
    ROUND(100.0 * recently_updated / total_datasets, 1) as pct_recent_updates,
    ROUND(100.0 * has_time_coverage / total_datasets, 1) as pct_temporal_coverage,
    ROUND(100.0 * public_datasets / total_datasets, 1) as pct_public
  FROM dataset_metrics
)
SELECT
  'Dataset Quality Metrics' as metric_category,
  total_datasets as total_count,
  pct_well_described as description_quality,
  pct_with_dictionary as documentation_coverage,
  pct_downloadable as download_availability,
  pct_recent_updates as freshness_score,
  pct_temporal_coverage as time_coverage,
  pct_public as accessibility
FROM quality_scores;

-- How it works:
-- 1. First CTE calculates raw counts for various quality metrics
-- 2. Second CTE converts counts to percentages for easier interpretation
-- 3. Final SELECT presents the metrics in a business-friendly format

-- Assumptions and Limitations:
-- - Assumes description length >50 chars indicates meaningful content
-- - 90-day threshold for "recent" updates may need adjustment
-- - Does not account for dataset size or complexity
-- - Quality metrics are equally weighted

-- Possible Extensions:
-- 1. Add trending analysis to track quality improvements over time
-- 2. Break down metrics by bureau code to identify departmental patterns
-- 3. Create quality score tiers (A/B/C/D/F) based on composite metrics
-- 4. Add checks for specific required fields by dataset type
-- 5. Generate automated recommendations for quality improvements

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:45:32.778942
    - Additional Notes: Query provides a snapshot of dataset quality and accessibility metrics across the CMS data catalog. Results show percentages for key quality indicators including description completeness, documentation availability, and update frequency. The 90-day recency threshold and 50-character description length are configurable based on organizational requirements.
    
    */