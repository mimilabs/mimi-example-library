-- fqhc_owner_titles_analysis.sql

-- Business Purpose: 
-- Analyze the distribution of job titles among individual FQHC owners to:
-- 1. Understand leadership and executive representation in ownership
-- 2. Identify key decision-maker roles across FQHCs
-- 3. Support succession planning and leadership development initiatives
-- 4. Guide governance and compliance monitoring efforts

-- Main Query
WITH owner_titles AS (
    SELECT 
        title_owner,
        COUNT(DISTINCT associate_id) as fqhc_count,
        COUNT(DISTINCT associate_id_owner) as owner_count,
        AVG(CAST(percentage_ownership AS DECIMAL(5,2))) as avg_ownership_pct,
        COUNT(*) as total_relationships
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
    WHERE 
        type_owner = 'I'  -- Focus on individual owners
        AND title_owner IS NOT NULL 
        AND title_owner != ''
    GROUP BY title_owner
)

SELECT 
    title_owner,
    fqhc_count,
    owner_count,
    ROUND(avg_ownership_pct, 2) as avg_ownership_pct,
    total_relationships,
    ROUND(100.0 * fqhc_count / SUM(fqhc_count) OVER(), 2) as pct_of_total_fqhcs
FROM owner_titles
WHERE fqhc_count >= 5  -- Filter for meaningful representation
ORDER BY fqhc_count DESC, avg_ownership_pct DESC
LIMIT 20;

-- How the Query Works:
-- 1. Creates a CTE to aggregate ownership data by title
-- 2. Counts unique FQHCs and owners for each title
-- 3. Calculates average ownership percentage
-- 4. Filters for titles with significant representation
-- 5. Adds percentage of total FQHCs metric
-- 6. Orders results by prevalence and ownership stake

-- Assumptions and Limitations:
-- 1. Assumes title_owner field is standardized and meaningful
-- 2. Limited to individual owners (type_owner = 'I')
-- 3. Excludes blank or null titles
-- 4. May miss variations in title naming conventions
-- 5. Point-in-time analysis based on latest data

-- Possible Extensions:
-- 1. Add temporal analysis to track title distribution changes over time
-- 2. Cross-reference with role_code_owner for deeper role analysis
-- 3. Include geographic distribution of titles
-- 4. Compare title distributions between different FQHC size categories
-- 5. Analyze correlation between titles and ownership percentages
-- 6. Add gender analysis based on owner names
-- 7. Compare title distributions with industry benchmarks

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:02:19.593546
    - Additional Notes: Query focuses on executive leadership distribution within FQHC ownership structure. Note that results may be incomplete if title standardization is inconsistent across organizations. The 5-FQHC minimum threshold in the WHERE clause can be adjusted based on analysis needs.
    
    */