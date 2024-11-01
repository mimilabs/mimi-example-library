-- Home Health Care Organization Geographic Coverage Analysis
--
-- Business Purpose:
-- - Analyze geographic coverage and service type distribution of home health organizations
-- - Identify potential service gaps and market opportunities by state/region
-- - Support strategic planning for health systems expanding home health services
--
-- Note: This analysis helps healthcare executives understand market presence and
-- identify areas for potential expansion or consolidation of home health services.

WITH state_summary AS (
    -- Aggregate home health services by state
    SELECT 
        home_health_care_org_state as state,
        COUNT(DISTINCT compendium_hh_id) as total_organizations,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home health' THEN compendium_hh_id END) as home_health_count,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'hospice' THEN compendium_hh_id END) as hospice_count,
        COUNT(DISTINCT CASE WHEN home_health_care_org_type = 'home dialysis' THEN compendium_hh_id END) as dialysis_count,
        COUNT(DISTINCT health_sys_id) as health_systems_count
    FROM mimi_ws_1.ahrq.compendium_homehealth_linkage
    GROUP BY home_health_care_org_state
),

state_rankings AS (
    -- Calculate state rankings by total organizations
    SELECT 
        *,
        RANK() OVER (ORDER BY total_organizations DESC) as rank_by_total,
        ROUND(100.0 * home_health_count / NULLIF(total_organizations, 0), 1) as home_health_pct,
        ROUND(100.0 * hospice_count / NULLIF(total_organizations, 0), 1) as hospice_pct,
        ROUND(100.0 * dialysis_count / NULLIF(total_organizations, 0), 1) as dialysis_pct
    FROM state_summary
)

SELECT 
    state,
    total_organizations,
    health_systems_count,
    home_health_count,
    hospice_count,
    dialysis_count,
    home_health_pct,
    hospice_pct,
    dialysis_pct,
    rank_by_total
FROM state_rankings
WHERE total_organizations > 0
ORDER BY rank_by_total;

-- How this query works:
-- 1. First CTE aggregates home health organizations by state and service type
-- 2. Second CTE calculates rankings and percentages
-- 3. Final output provides comprehensive state-level market analysis
--
-- Assumptions and limitations:
-- - Assumes current data represents active organizations
-- - Does not account for organization size or capacity
-- - Service area may cross state boundaries
--
-- Possible extensions:
-- 1. Add regional groupings (Northeast, Midwest, etc.)
-- 2. Include population data to calculate per-capita metrics
-- 3. Add year-over-year growth analysis
-- 4. Incorporate demographic data to identify underserved areas
-- 5. Add market concentration metrics (e.g., HHI) by state

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:23:48.602608
    - Additional Notes: Query provides state-level market analysis of home health services distribution. Consider adding a WHERE clause to filter specific time periods using mimi_src_file_date if analyzing trends over time. Large states may need additional geographic subdivisions for meaningful analysis.
    
    */