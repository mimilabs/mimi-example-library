-- Title: MedlinePlus Organization Activity Trend Analysis

-- Business Purpose:
-- - Monitor organization participation patterns and activity levels in MedlinePlus
-- - Identify peak activity periods and potential seasonal trends
-- - Support resource allocation and engagement planning

WITH monthly_activity AS (
    -- Calculate monthly organization activity metrics
    SELECT 
        DATE_TRUNC('month', mimi_src_file_date) AS activity_month,
        COUNT(DISTINCT organization) as active_orgs,
        COUNT(DISTINCT site_id) as active_sites,
        COUNT(*) as total_interactions
    FROM mimi_ws_1.medlineplus.organization
    WHERE mimi_src_file_date >= DATE_ADD(months, -12, CURRENT_DATE())
    GROUP BY DATE_TRUNC('month', mimi_src_file_date)
),

activity_metrics AS (
    -- Calculate month-over-month changes
    SELECT 
        activity_month,
        active_orgs,
        active_sites,
        total_interactions,
        (active_orgs - LAG(active_orgs) OVER (ORDER BY activity_month)) / 
            NULLIF(LAG(active_orgs) OVER (ORDER BY activity_month), 0) * 100 as org_growth_pct
    FROM monthly_activity
)

SELECT 
    activity_month,
    active_orgs,
    active_sites,
    total_interactions,
    ROUND(org_growth_pct, 1) as org_growth_pct,
    -- Calculate activity ratios
    ROUND(total_interactions::FLOAT / NULLIF(active_orgs, 0), 2) as interactions_per_org,
    ROUND(active_sites::FLOAT / NULLIF(active_orgs, 0), 2) as sites_per_org
FROM activity_metrics
ORDER BY activity_month DESC;

-- How the Query Works:
-- 1. Creates monthly_activity CTE to aggregate key metrics by month
-- 2. Creates activity_metrics CTE to calculate growth percentages
-- 3. Final SELECT combines metrics with calculated ratios
-- 4. Results ordered by most recent month first

-- Assumptions and Limitations:
-- - Assumes mimi_src_file_date is consistently populated and accurate
-- - Limited to last 12 months of data
-- - Growth percentages may be affected by data completeness
-- - Does not account for organization size or type

-- Possible Extensions:
-- 1. Add rolling averages to smooth seasonal variations
-- 2. Include organization categorization for segment-specific analysis
-- 3. Add forecasting capabilities using historical patterns
-- 4. Incorporate quality metrics or content engagement data
-- 5. Add alerts for significant changes in activity levels

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:54:34.732831
    - Additional Notes: Query aggregates monthly activity metrics and calculates organization engagement ratios. Results limited to trailing 12 months and requires consistent mimi_src_file_date values for accurate trend analysis.
    
    */