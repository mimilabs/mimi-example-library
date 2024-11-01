-- fqhc_leadership_influence.sql

-- Business Purpose:
-- Analyze FQHC leadership and management control patterns to understand:
-- 1. Key decision makers and their roles across FQHCs
-- 2. Distribution of management roles vs ownership stakes
-- 3. Concentration of leadership influence in the FQHC network
-- 4. Identify potential governance patterns that could impact operations

WITH leadership_summary AS (
    -- Get distinct owners with leadership roles and their ownership details
    SELECT DISTINCT
        associate_id_owner,
        first_name_owner,
        last_name_owner,
        title_owner,
        role_text_owner,
        COUNT(DISTINCT enrollment_id) as fqhc_count,
        AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_stake,
        COLLECT_SET(role_code_owner) as role_codes
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
    WHERE role_text_owner LIKE '%Director%'
        OR role_text_owner LIKE '%Officer%'
        OR role_text_owner LIKE '%Manager%'
    GROUP BY 
        associate_id_owner,
        first_name_owner,
        last_name_owner,
        title_owner,
        role_text_owner
)

SELECT 
    role_text_owner,
    COUNT(*) as leaders_count,
    ROUND(AVG(fqhc_count), 2) as avg_facilities_per_leader,
    ROUND(AVG(avg_ownership_stake), 2) as avg_ownership_percentage,
    COUNT(CASE WHEN fqhc_count > 1 THEN 1 END) as multi_facility_leaders,
    COUNT(CASE WHEN SIZE(role_codes) > 1 THEN 1 END) as multi_role_leaders
FROM leadership_summary
GROUP BY role_text_owner
HAVING COUNT(*) >= 5
ORDER BY avg_ownership_percentage DESC;

-- How the Query Works:
-- 1. Creates a CTE that identifies individuals in leadership positions
-- 2. Calculates key metrics per leader including facility count and average ownership
-- 3. Aggregates results by role type to show leadership patterns
-- 4. Filters for roles with meaningful representation (5+ leaders)

-- Assumptions and Limitations:
-- - Assumes leadership roles are accurately captured in role_text_owner
-- - Limited to explicit leadership titles (Director, Officer, Manager)
-- - May not capture informal leadership arrangements
-- - Ownership percentages might be missing or inconsistent

-- Possible Extensions:
-- 1. Add temporal analysis to track leadership stability over time
-- 2. Compare leadership patterns between urban and rural FQHCs
-- 3. Analyze correlation between leadership structure and facility performance
-- 4. Examine geographic distribution of multi-facility leaders
-- 5. Compare leadership patterns between for-profit and non-profit FQHCs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:09:00.801776
    - Additional Notes: The query aggregates leadership metrics across FQHCs, focusing on management roles and their influence. Note that it uses COLLECT_SET which may have performance implications for very large datasets, and the role identification is limited to specific keyword matches in role_text_owner.
    
    */