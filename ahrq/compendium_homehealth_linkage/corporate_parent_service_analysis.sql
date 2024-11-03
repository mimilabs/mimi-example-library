-- Home Health Corporate Parent Influence Analysis
--
-- Business Purpose:
-- - Analyze how different corporate parent types influence home health organization distribution
-- - Identify patterns in home health service offerings based on corporate ownership
-- - Assess potential implications for care delivery and market strategy
-- - Support strategic planning and partnership decisions
--

WITH corporate_summary AS (
    -- Aggregate home health organizations by corporate parent
    SELECT 
        corp_parent_type,
        corp_parent_name,
        COUNT(DISTINCT compendium_hh_id) as total_organizations,
        COUNT(DISTINCT home_health_care_org_state) as states_covered,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home health' THEN compendium_hh_id END) as home_health_count,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'hospice' THEN compendium_hh_id END) as hospice_count,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home dialysis' THEN compendium_hh_id END) as dialysis_count
    FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
    WHERE corp_parent_name IS NOT NULL
    GROUP BY corp_parent_type, corp_parent_name
),

parent_metrics AS (
    -- Calculate key metrics for each corporate parent
    SELECT 
        corp_parent_type,
        corp_parent_name,
        total_organizations,
        states_covered,
        ROUND(home_health_count * 100.0 / total_organizations, 1) as home_health_pct,
        ROUND(hospice_count * 100.0 / total_organizations, 1) as hospice_pct,
        ROUND(dialysis_count * 100.0 / total_organizations, 1) as dialysis_pct
    FROM corporate_summary
)

-- Final output with ranked results
SELECT 
    corp_parent_type,
    corp_parent_name,
    total_organizations,
    states_covered,
    home_health_pct,
    hospice_pct,
    dialysis_pct,
    DENSE_RANK() OVER (PARTITION BY corp_parent_type ORDER BY total_organizations DESC) as size_rank
FROM parent_metrics
WHERE total_organizations >= 5  -- Focus on larger corporate parents
ORDER BY corp_parent_type, size_rank
LIMIT 20;

-- How this query works:
-- 1. First CTE aggregates key counts by corporate parent
-- 2. Second CTE calculates percentage distributions of service types
-- 3. Final query ranks corporate parents by size within their type
-- 4. Results show top 20 corporate parents with significant presence
--
-- Assumptions and Limitations:
-- - Assumes corporate parent information is accurately captured
-- - Limited to organizations with known corporate parents
-- - Focuses on larger organizations (5+ facilities)
-- - Current time snapshot only
--
-- Possible Extensions:
-- 1. Add year-over-year growth analysis
-- 2. Include financial metrics if available
-- 3. Add geographic concentration metrics
-- 4. Compare outcomes data across corporate parent types
-- 5. Analyze relationship between size and service diversity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:14:54.158260
    - Additional Notes: Query provides insights into corporate ownership patterns in home healthcare, focusing on service mix and geographic coverage. Best used for strategic analysis of market leaders and their service portfolios. Note that filtering threshold of 5+ organizations may need adjustment based on market size and analysis needs.
    
    */