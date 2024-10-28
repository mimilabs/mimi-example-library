
/*******************************************************************************
Title: External Health Resource Analysis by Topic
 
Business Purpose:
- Analyze distribution and characteristics of external health information resources
- Identify most referenced health topics with external resources
- Support content quality assessment and gap analysis in health information coverage
*******************************************************************************/

-- Get top health topics by number of external references,
-- along with latest source dates and URL patterns
WITH TopicSummary AS (
    SELECT 
        topic_id,
        COUNT(DISTINCT url) as num_resources,
        MAX(mimi_src_file_date) as latest_update,
        COUNT(DISTINCT language_mapped_url) as num_language_versions,
        -- Simple domain type classification based on URL
        SUM(CASE 
            WHEN url LIKE '%.gov%' THEN 1 
            ELSE 0 
        END) as govt_sources,
        SUM(CASE 
            WHEN url LIKE '%.org%' THEN 1 
            ELSE 0 
        END) as org_sources
    FROM mimi_ws_1.medlineplus.site
    GROUP BY topic_id
)

SELECT
    t.topic_id,
    t.num_resources,
    t.num_language_versions,
    t.govt_sources,
    t.org_sources,
    t.latest_update,
    -- Calculate resource distribution metrics
    ROUND(t.govt_sources * 100.0 / t.num_resources, 1) as govt_sources_pct,
    ROUND(t.org_sources * 100.0 / t.num_resources, 1) as org_sources_pct
FROM TopicSummary t
WHERE t.num_resources >= 5  -- Focus on topics with substantial external coverage
ORDER BY t.num_resources DESC
LIMIT 20;

/*******************************************************************************
How it works:
1. Creates summary statistics for each health topic
2. Classifies URLs by domain type (.gov, .org)
3. Calculates distribution metrics
4. Filters for topics with meaningful coverage
5. Orders by most referenced topics

Assumptions and Limitations:
- Simple URL pattern matching may not catch all government/organization sites
- Does not assess content quality or authority
- Language versions may include duplicates
- Minimum threshold of 5 resources is arbitrary

Possible Extensions:
1. Add temporal analysis to track resource growth over time
2. Include topic names and categories for better context
3. Analyze title keywords to identify resource focus areas
4. Add URL validation status checking
5. Cross-reference with topic popularity or health condition prevalence
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:43:14.463793
    - Additional Notes: Query provides high-level resource distribution metrics but URL classification is basic. Consider adding domain validation and more sophisticated URL pattern matching for production use. The threshold of 5 resources may need adjustment based on actual data distribution.
    
    */