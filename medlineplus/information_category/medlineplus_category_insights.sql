-- medlineplus_category_diversity_analysis.sql
-- Business Purpose: Provide strategic insights into MedlinePlus site information categories to support content strategy and user experience design

WITH category_stats AS (
    -- Aggregate category metrics to understand information landscape
    SELECT 
        category,
        COUNT(DISTINCT site_id) AS unique_sites_count,
        COUNT(*) AS total_category_entries,
        ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS category_percentage
    FROM mimi_ws_1.medlineplus.information_category
    GROUP BY category
),
temporal_trend AS (
    -- Identify most recent data load for temporal context
    SELECT 
        MAX(mimi_src_file_date) AS latest_data_snapshot,
        MAX(mimi_dlt_load_date) AS latest_load_date
    FROM mimi_ws_1.medlineplus.information_category
)

SELECT 
    cs.category,
    cs.unique_sites_count,
    cs.total_category_entries,
    cs.category_percentage,
    tt.latest_data_snapshot,
    tt.latest_load_date
FROM category_stats cs
CROSS JOIN temporal_trend tt
ORDER BY cs.unique_sites_count DESC, cs.category_percentage DESC
LIMIT 20;

/*
Query Mechanics:
- First CTE (category_stats) calculates metrics per information category
- Second CTE (temporal_trend) captures data loading metadata
- Main query combines category insights with temporal context
- Ordered by site count and category representation

Assumptions:
- Data represents a comprehensive snapshot of MedlinePlus sites
- Categories are mutually exclusive for each site entry

Potential Extensions:
1. Add geographic or audience segmentation
2. Correlate categories with site engagement metrics
3. Create trend analysis across multiple data loads
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:10:11.048059
    - Additional Notes: Provides a strategic overview of MedlinePlus site information categories, highlighting category distribution, site diversity, and temporal context. Best used for high-level content strategy planning and understanding information landscape.
    
    */