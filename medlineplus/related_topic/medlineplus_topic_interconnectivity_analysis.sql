-- medlineplus_topic_interconnectivity_analysis.sql
-- Business Purpose: Analyze the density and diversity of health topic relationships to 
-- understand content navigation patterns and potential content recommendation strategies

WITH topic_relationship_metrics AS (
    -- Calculate relationship density and breadth for each main topic
    SELECT 
        topic_id,
        COUNT(DISTINCT related_id) AS unique_related_topics,
        COUNT(*) AS total_related_links,
        ARRAY_AGG(DISTINCT related_title) AS related_topic_titles,
        MAX(mimi_src_file_date) AS most_recent_data_point
    FROM mimi_ws_1.medlineplus.related_topic
    GROUP BY topic_id
),
topic_diversity_ranking AS (
    -- Rank topics by their interconnectivity and potential for user exploration
    SELECT 
        topic_id,
        unique_related_topics,
        total_related_links,
        DENSE_RANK() OVER (ORDER BY unique_related_topics DESC) AS topic_interconnectivity_rank,
        most_recent_data_point
    FROM topic_relationship_metrics
)

SELECT 
    topic_id,
    unique_related_topics,
    total_related_links,
    topic_interconnectivity_rank,
    most_recent_data_point
FROM topic_diversity_ranking
WHERE unique_related_topics > 5  -- Focus on topics with meaningful relationships
ORDER BY unique_related_topics DESC
LIMIT 100;

-- Query Mechanics:
-- 1. First CTE calculates relationship metrics for each main topic
-- 2. Second CTE ranks topics by their interconnectivity
-- 3. Final SELECT surfaces topics with rich, diverse relationships

-- Assumptions & Limitations:
-- - Assumes more related topics indicate higher content relevance
-- - Snapshot represents a specific moment in MedlinePlus data
-- - Ranking may change with updated source data

-- Potential Extensions:
-- 1. Analyze related topics by medical category
-- 2. Create content recommendation engine
-- 3. Visualize topic relationship networks
-- 4. Track changes in topic interconnectivity over time

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:12:26.602367
    - Additional Notes: Analyzes health topic relationships by calculating unique connections and ranking topics based on their interconnectivity. Best used for content strategy and recommendation system insights.
    
    */