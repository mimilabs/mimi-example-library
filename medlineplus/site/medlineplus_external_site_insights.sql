-- health_external_sites_topic_insights.sql
-- Business Purpose: 
-- Analyze the relationship between health topics and external information sites
-- Provide insights into the diversity and coverage of health information resources
-- Support strategic content development and resource allocation decisions

WITH site_summary AS (
    -- Aggregate external site details by topic
    SELECT 
        topic_id,
        COUNT(DISTINCT url) AS unique_site_count,
        COUNT(DISTINCT CASE WHEN language_mapped_url IS NOT NULL THEN url END) AS multilingual_site_count,
        MAX(mimi_src_file_date) AS most_recent_update
    FROM mimi_ws_1.medlineplus.site
    GROUP BY topic_id
),
site_type_analysis AS (
    -- Classify external sites by domain characteristics
    SELECT 
        topic_id,
        SUM(CASE 
            WHEN url LIKE '%.gov%' THEN 1 
            WHEN url LIKE '%.org%' THEN 1 
            WHEN url LIKE '%.edu%' THEN 1 
            ELSE 0 
        END) AS authoritative_site_count,
        SUM(CASE 
            WHEN url LIKE '%.com%' THEN 1 
            ELSE 0 
        END) AS commercial_site_count
    FROM mimi_ws_1.medlineplus.site
    GROUP BY topic_id
)

-- Primary query to provide comprehensive topic-level insights
SELECT 
    ss.topic_id,
    ss.unique_site_count,
    ss.multilingual_site_count,
    ROUND(ss.multilingual_site_count * 100.0 / ss.unique_site_count, 2) AS multilingual_percentage,
    sta.authoritative_site_count,
    sta.commercial_site_count,
    ss.most_recent_update
FROM site_summary ss
JOIN site_type_analysis sta ON ss.topic_id = sta.topic_id
WHERE ss.unique_site_count > 0
ORDER BY ss.unique_site_count DESC
LIMIT 100;

-- Query Explanation:
-- 1. site_summary CTE: Aggregates site information by topic
-- 2. site_type_analysis CTE: Categorizes sites by domain type
-- 3. Main query joins these CTEs to provide comprehensive insights
-- 4. Focuses on topics with at least one external site
-- 5. Ordered by number of unique sites in descending order

-- Assumptions:
-- - Topic_id represents a unique health topic
-- - URL domains are reliable indicators of site type
-- - Most recent update date reflects content currency

-- Potential Extensions:
-- 1. Add language diversity analysis
-- 2. Implement more granular site type classification
-- 3. Create time-series analysis of site updates
-- 4. Correlate site count with topic complexity or prevalence

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:08:02.904157
    - Additional Notes: Query provides topic-level analysis of external health information sites, including site count, multilingual availability, and site type distribution. Requires careful interpretation due to potential domain classification limitations.
    
    */