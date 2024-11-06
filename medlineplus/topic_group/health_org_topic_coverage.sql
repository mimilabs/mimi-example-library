-- Topic Group Analysis: Understanding Health Organization Networks
--
-- Business Purpose:
-- This query analyzes the relationships between health topics and supporting organizations
-- to identify key healthcare ecosystem partners and potential collaboration opportunities.
-- Understanding these relationships helps in:
-- 1. Identifying influential healthcare organizations
-- 2. Mapping coverage of health topics across organizations
-- 3. Finding gaps in topic coverage
-- 4. Supporting partnership strategy decisions

SELECT 
    -- Organization metrics
    group_name,
    COUNT(DISTINCT topic_id) as topics_covered,
    COUNT(*) as total_associations,
    
    -- Calculate engagement metrics
    ROUND(COUNT(DISTINCT topic_id) * 100.0 / 
          (SELECT COUNT(DISTINCT topic_id) FROM mimi_ws_1.medlineplus.topic_group), 2) 
          as topic_coverage_percentage,
    
    -- Get most recent activity date
    MAX(mimi_src_file_date) as latest_activity_date,
    
    -- Include reference URL
    MAX(group_url) as organization_url

FROM mimi_ws_1.medlineplus.topic_group

GROUP BY group_name

-- Focus on organizations with significant engagement
HAVING COUNT(DISTINCT topic_id) >= 5

-- Order by impact
ORDER BY topics_covered DESC, total_associations DESC

LIMIT 20;

-- How This Query Works:
-- 1. Groups data by organization name
-- 2. Calculates key metrics per organization:
--    - Number of unique health topics covered
--    - Total number of topic associations
--    - Percentage coverage of all available topics
-- 3. Filters for organizations with meaningful engagement (5+ topics)
-- 4. Orders results by impact (topic coverage and total associations)
--
-- Assumptions & Limitations:
-- - Assumes current data is representative of active relationships
-- - Organizations may have varying levels of contribution quality not captured here
-- - URL presence doesn't guarantee active web resources
-- - Limited to top 20 organizations for initial analysis
--
-- Potential Extensions:
-- 1. Add temporal analysis to show changing relationships over time:
--    - Add GROUP BY YEAR(mimi_src_file_date)
-- 2. Include topic categorization to show organizational focus areas:
--    - JOIN with topic metadata tables
-- 3. Network analysis to show organization clusters:
--    - Self-join to find organizations frequently co-occurring on topics
-- 4. Geographic analysis if organization location data available:
--    - Add regional coverage analysis
-- 5. Topic gap analysis:
--    - Identify health topics with limited organizational support

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:12:01.070733
    - Additional Notes: Query focuses on organizational engagement metrics but requires sufficient data volume to be meaningful due to the HAVING clause filter of 5+ topics. The topic_coverage_percentage calculation assumes the subquery will return a non-zero count. Consider adjusting the LIMIT and HAVING thresholds based on actual data distribution.
    
    */