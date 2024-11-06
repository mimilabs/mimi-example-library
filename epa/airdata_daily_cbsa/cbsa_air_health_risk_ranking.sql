-- air_quality_public_health_alerts.sql

-- Business Purpose:
-- Identify CBSAs with persistent poor air quality to support public health interventions 
-- and population health management programs. This analysis helps healthcare organizations
-- target preventive care and disease management resources to high-risk areas.

WITH monthly_poor_air_days AS (
    -- Calculate days per month where air quality was Unhealthy or worse
    SELECT 
        cbsa,
        DATE_TRUNC('month', date) as month,
        COUNT(*) as total_days,
        COUNT(CASE WHEN aqi > 150 THEN 1 END) as poor_air_days,
        AVG(aqi) as avg_aqi
    FROM mimi_ws_1.epa.airdata_daily_cbsa
    WHERE date >= DATE_ADD(months, -12, CURRENT_DATE)
    GROUP BY cbsa, DATE_TRUNC('month', date)
),

high_risk_areas AS (
    -- Identify CBSAs with consistently poor air quality
    SELECT 
        cbsa,
        COUNT(DISTINCT month) as months_with_data,
        AVG(poor_air_days) as avg_poor_days_per_month,
        MAX(avg_aqi) as max_monthly_avg_aqi,
        SUM(poor_air_days) as total_poor_air_days
    FROM monthly_poor_air_days
    GROUP BY cbsa
    HAVING COUNT(DISTINCT month) >= 6
)

SELECT 
    cbsa,
    months_with_data,
    ROUND(avg_poor_days_per_month, 1) as avg_poor_days_per_month,
    ROUND(max_monthly_avg_aqi, 1) as max_monthly_avg_aqi,
    total_poor_air_days,
    -- Calculate risk tier based on frequency of poor air quality
    CASE 
        WHEN avg_poor_days_per_month >= 5 THEN 'High Risk'
        WHEN avg_poor_days_per_month >= 2 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_tier
FROM high_risk_areas
WHERE total_poor_air_days > 0
ORDER BY avg_poor_days_per_month DESC
LIMIT 20;

-- How it works:
-- 1. First CTE calculates monthly statistics for each CBSA
-- 2. Second CTE identifies areas with persistent air quality issues
-- 3. Final query adds risk tiers and formats output for actionable insights

-- Assumptions and Limitations:
-- - Requires at least 6 months of data for meaningful analysis
-- - Uses AQI > 150 as threshold for poor air quality
-- - Does not account for population size or vulnerable populations
-- - Recent data is more relevant for current decision-making

-- Possible Extensions:
-- 1. Add seasonal trend analysis
-- 2. Include population data to calculate exposure impact
-- 3. Compare with respiratory disease rates
-- 4. Add geographic clustering of high-risk areas
-- 5. Create rolling average calculations for trend analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:19:02.403062
    - Additional Notes: Query focuses on 12-month lookback period and requires minimum 6 months of data for each CBSA. Risk tiers are defined using fixed thresholds (5+ days for High Risk, 2+ days for Medium Risk) which may need adjustment based on specific regional or seasonal patterns.
    
    */