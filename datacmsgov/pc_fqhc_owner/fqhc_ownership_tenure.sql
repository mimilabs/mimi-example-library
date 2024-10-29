-- fqhc_owner_temporal_analysis.sql

-- Business Purpose: 
-- Analyze the temporal patterns of FQHC ownership changes to understand:
-- 1. Recent ownership transitions and their timing
-- 2. Length of ownership tenure
-- 3. Seasonal patterns in ownership changes
-- This information helps identify market dynamics and potential consolidation trends.

WITH ownership_dates AS (
    -- Get first and most recent ownership dates for each FQHC
    SELECT 
        organization_name,
        associate_id,
        MIN(association_date_owner) as first_ownership_date,
        MAX(association_date_owner) as latest_ownership_date,
        COUNT(DISTINCT associate_id_owner) as total_owners,
        DATEDIFF(MAX(association_date_owner), MIN(association_date_owner)) as ownership_span_days
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
    GROUP BY organization_name, associate_id
),

recent_changes AS (
    -- Focus on FQHCs with ownership changes in last 2 years
    SELECT 
        o.organization_name,
        o.association_date_owner,
        o.type_owner,
        o.role_text_owner,
        CASE 
            WHEN o.type_owner = 'O' THEN o.organization_name_owner
            ELSE CONCAT(o.first_name_owner, ' ', o.last_name_owner)
        END as owner_name
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner o
    WHERE o.association_date_owner >= DATE_SUB(CURRENT_DATE(), 730)
)

SELECT
    YEAR(od.first_ownership_date) as initial_year,
    COUNT(DISTINCT od.associate_id) as num_fqhcs,
    AVG(od.total_owners) as avg_owners_per_fqhc,
    AVG(od.ownership_span_days)/365.25 as avg_ownership_years,
    SUM(CASE WHEN rc.organization_name IS NOT NULL THEN 1 ELSE 0 END) as recent_ownership_changes
FROM ownership_dates od
LEFT JOIN recent_changes rc ON od.organization_name = rc.organization_name
GROUP BY YEAR(od.first_ownership_date)
ORDER BY initial_year DESC;

-- How this works:
-- 1. First CTE calculates key ownership date metrics for each FQHC
-- 2. Second CTE identifies recent ownership changes within last 2 years
-- 3. Main query aggregates results by year showing ownership stability metrics

-- Assumptions and Limitations:
-- - Association dates are accurate and complete
-- - Changes in ownership are properly recorded with new association dates
-- - Analysis may not capture complex ownership structures or partial transfers
-- - Limited to date ranges available in the source data

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional patterns in ownership stability
-- 2. Include owner type analysis to see if certain owner types have longer tenure
-- 3. Add seasonality analysis to identify common times for ownership changes
-- 4. Compare ownership duration patterns between for-profit and non-profit entities
-- 5. Add correlation analysis with other FQHC performance metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:28:43.403193
    - Additional Notes: Query focuses on temporal ownership patterns and requires historical data spanning multiple years for meaningful results. The analysis may be impacted by data completeness, particularly for association_date_owner values. Consider adding date range parameters if analyzing specific time periods.
    
    */