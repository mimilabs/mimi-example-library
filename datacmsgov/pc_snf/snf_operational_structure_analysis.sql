-- Title: SNF Financial Status and Operational Scale Analysis
-- Business Purpose: This query analyzes the financial and operational characteristics
-- of Skilled Nursing Facilities to understand:
-- 1. The distribution of for-profit vs non-profit facilities
-- 2. The scale of operations based on multiple facility indicators
-- 3. Key patterns in corporate structure and affiliations
-- This information helps identify market opportunities and operational patterns.

WITH facility_metrics AS (
    -- Calculate key operational indicators
    SELECT 
        organization_name,
        proprietary_nonprofit,
        CASE 
            WHEN multiple_npi_flag = 'Y' THEN 1 
            ELSE 0 
        END as has_multiple_locations,
        organization_type_structure,
        CASE 
            WHEN affiliation_entity_name IS NOT NULL THEN 1 
            ELSE 0 
        END as has_affiliations
    FROM mimi_ws_1.datacmsgov.pc_snf
    WHERE organization_name IS NOT NULL
),

summary_stats AS (
    -- Aggregate metrics by organization type
    SELECT 
        organization_type_structure,
        proprietary_nonprofit,
        COUNT(*) as facility_count,
        SUM(has_multiple_locations) as multi_location_count,
        SUM(has_affiliations) as affiliated_facility_count,
        ROUND(AVG(has_multiple_locations) * 100, 2) as pct_multi_location,
        ROUND(AVG(has_affiliations) * 100, 2) as pct_affiliated
    FROM facility_metrics
    GROUP BY 1, 2
)

-- Final output with business insights
SELECT 
    organization_type_structure as org_type,
    proprietary_nonprofit as financial_status,
    facility_count,
    multi_location_count,
    affiliated_facility_count,
    pct_multi_location,
    pct_affiliated
FROM summary_stats
WHERE facility_count > 10  -- Focus on significant segments
ORDER BY facility_count DESC;

-- How this query works:
-- 1. First CTE creates facility-level metrics including multiple location and affiliation flags
-- 2. Second CTE aggregates these metrics by organization type and financial status
-- 3. Final query filters and presents the results in a business-friendly format

-- Assumptions and Limitations:
-- 1. Assumes proprietary_nonprofit field is consistently populated
-- 2. multiple_npi_flag is used as a proxy for multiple locations
-- 3. Only includes organizations with more than 10 facilities for statistical significance
-- 4. Data represents a snapshot in time

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating incorporation_date
-- 2. Include geographic analysis by state/region
-- 3. Add market concentration metrics
-- 4. Compare affiliation patterns between for-profit and non-profit entities
-- 5. Analyze correlation between organizational structure and multiple location strategy/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:09:30.801091
    - Additional Notes: The query provides insights into SNF operational scale and financial characteristics but does not account for variations in reporting periods or potential gaps in affiliation data. Results may need adjustment based on specific reporting periods of interest. Organizations with 10 or fewer facilities are excluded from the analysis.
    
    */