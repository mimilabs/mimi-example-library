-- File: medlineplus_top_institutes_impact_analysis.sql
-- Business Purpose: Identify the most influential primary institutes in the MedlinePlus knowledge base by analyzing their topic coverage, helping healthcare organizations and researchers understand key knowledge contributors and potential collaboration opportunities.

WITH institute_topic_summary AS (
    -- Aggregate topic count and diversity for each institute
    SELECT 
        institute,
        COUNT(DISTINCT topic_id) AS total_topics_covered,
        COUNT(DISTINCT mimi_src_file_name) AS source_file_diversity,
        MAX(mimi_src_file_date) AS most_recent_update
    FROM mimi_ws_1.medlineplus.primary_institute
    WHERE institute IS NOT NULL
    GROUP BY institute
),

institute_impact_ranking AS (
    -- Rank institutes by their breadth and recency of topic coverage
    SELECT 
        institute,
        total_topics_covered,
        source_file_diversity,
        most_recent_update,
        RANK() OVER (ORDER BY total_topics_covered DESC) AS topic_coverage_rank,
        RANK() OVER (ORDER BY source_file_diversity DESC) AS source_diversity_rank
    FROM institute_topic_summary
)

-- Present the top institutes with their impact metrics
SELECT 
    institute,
    total_topics_covered AS topic_count,
    source_file_diversity AS source_count,
    most_recent_update,
    topic_coverage_rank,
    source_diversity_rank,
    ROUND(
        (topic_coverage_rank + source_diversity_rank) / 2.0, 
        2
    ) AS composite_impact_score
FROM institute_impact_ranking
WHERE total_topics_covered > 10  -- Focus on significant contributors
ORDER BY composite_impact_score
LIMIT 25;

/*
HOW THE QUERY WORKS:
1. First CTE aggregates topic coverage for each institute
2. Second CTE ranks institutes by topic count and source diversity
3. Final query calculates a composite impact score and presents top institutes

ASSUMPTIONS & LIMITATIONS:
- Assumes higher topic count indicates greater institutional influence
- Does not account for topic complexity or depth
- Relies on MedlinePlus data snapshot completeness

POTENTIAL EXTENSIONS:
- Add URL analysis to understand digital presence
- Incorporate topic category weights
- Time-series analysis of institute contributions
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:07:08.894762
    - Additional Notes: Query provides a comprehensive view of primary institutes' contributions to MedlinePlus health topics, focusing on breadth of coverage and source diversity. Composite impact scoring helps identify key knowledge contributors while allowing for future refinement of the ranking methodology.
    
    */