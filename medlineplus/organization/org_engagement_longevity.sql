-- Title: MedlinePlus Organization Growth and Stability Analysis

-- Business Purpose:
-- - Track the growth and stability of organizations contributing to MedlinePlus over time
-- - Identify patterns in organizational engagement and participation
-- - Support strategic planning for partnerships and content management
-- - Monitor the health of the MedlinePlus contributor network

-- Main Query
WITH organization_metrics AS (
    SELECT 
        organization,
        MIN(mimi_src_file_date) as first_appearance,
        MAX(mimi_src_file_date) as last_appearance,
        COUNT(DISTINCT site_id) as total_sites,
        COUNT(DISTINCT mimi_src_file_date) as active_periods
    FROM mimi_ws_1.medlineplus.organization
    GROUP BY organization
),
duration_stats AS (
    SELECT
        organization,
        total_sites,
        active_periods,
        DATEDIFF(last_appearance, first_appearance) as days_active,
        CASE 
            WHEN DATEDIFF(last_appearance, first_appearance) > 365 THEN 'Long-term'
            WHEN DATEDIFF(last_appearance, first_appearance) > 180 THEN 'Medium-term'
            ELSE 'Short-term'
        END as engagement_level
    FROM organization_metrics
)
SELECT 
    engagement_level,
    COUNT(*) as org_count,
    AVG(total_sites) as avg_sites_per_org,
    AVG(active_periods) as avg_active_periods,
    AVG(days_active) as avg_days_active
FROM duration_stats
GROUP BY engagement_level
ORDER BY org_count DESC;

-- How the Query Works:
-- 1. Creates base metrics for each organization including first/last appearance dates and activity counts
-- 2. Calculates duration statistics and assigns engagement levels
-- 3. Aggregates results by engagement level to show distribution and patterns

-- Assumptions and Limitations:
-- - Assumes continuous organization participation between first and last appearance
-- - Does not account for potential gaps in participation
-- - Engagement levels are arbitrarily defined (365/180 days)
-- - Limited to raw counts without qualitative assessment of contribution value

-- Possible Extensions:
-- 1. Add quarter-over-quarter growth analysis
-- 2. Include site category/type analysis by organization
-- 3. Add geographical distribution analysis if location data becomes available
-- 4. Create alerts for organizations showing declining engagement
-- 5. Develop predictive models for organization retention
-- 6. Add content quality metrics by organization engagement level

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:43:57.932662
    - Additional Notes: Query uses 365/180 day thresholds for engagement categorization which may need adjustment based on business requirements. Results are sensitive to data completeness in mimi_src_file_date field. Consider adjusting engagement level thresholds based on domain-specific requirements.
    
    */