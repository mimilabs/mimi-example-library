-- Title: Strategic Immunization Timing Analysis
-- Business Purpose: 
-- This analysis helps healthcare providers optimize vaccine administration scheduling by:
-- 1. Identifying peak immunization periods during the year
-- 2. Understanding typical immunization timing patterns
-- 3. Supporting resource allocation and staff planning decisions

WITH monthly_trends AS (
    -- Calculate monthly immunization volumes and average costs
    SELECT 
        DATE_TRUNC('month', date) AS month,
        COUNT(*) AS total_immunizations,
        COUNT(DISTINCT patient) AS unique_patients,
        COUNT(DISTINCT code) AS unique_vaccines,
        ROUND(AVG(base_cost), 2) AS avg_cost,
        -- Calculate day of week distribution
        COUNT(CASE WHEN DATE_FORMAT(date, 'E') IN ('Mon','Tue','Wed','Thu','Fri') THEN 1 END) AS weekday_count,
        COUNT(CASE WHEN DATE_FORMAT(date, 'E') IN ('Sat','Sun') THEN 1 END) AS weekend_count
    FROM mimi_ws_1.synthea.immunizations
    WHERE date >= DATE_ADD(CURRENT_DATE(), -365) -- Last 12 months
    GROUP BY DATE_TRUNC('month', date)
),

seasonal_stats AS (
    -- Calculate seasonal statistics
    SELECT 
        CASE 
            WHEN MONTH(month) IN (12,1,2) THEN 'Winter'
            WHEN MONTH(month) IN (3,4,5) THEN 'Spring'
            WHEN MONTH(month) IN (6,7,8) THEN 'Summer'
            ELSE 'Fall'
        END AS season,
        AVG(total_immunizations) AS avg_monthly_immunizations,
        AVG(weekday_count) AS avg_weekday_volume,
        AVG(weekend_count) AS avg_weekend_volume
    FROM monthly_trends
    GROUP BY 
        CASE 
            WHEN MONTH(month) IN (12,1,2) THEN 'Winter'
            WHEN MONTH(month) IN (3,4,5) THEN 'Spring'
            WHEN MONTH(month) IN (6,7,8) THEN 'Summer'
            ELSE 'Fall'
        END
)

-- Final output combining monthly trends with seasonal patterns
SELECT 
    mt.month,
    mt.total_immunizations,
    mt.unique_patients,
    mt.unique_vaccines,
    mt.avg_cost,
    mt.weekday_count,
    mt.weekend_count,
    ss.season,
    ROUND(mt.total_immunizations / ss.avg_monthly_immunizations * 100, 1) AS percent_of_seasonal_avg
FROM monthly_trends mt
JOIN seasonal_stats ss ON 
    CASE 
        WHEN MONTH(mt.month) IN (12,1,2) THEN 'Winter'
        WHEN MONTH(mt.month) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(mt.month) IN (6,7,8) THEN 'Summer'
        ELSE 'Fall'
    END = ss.season
ORDER BY mt.month;

-- How it works:
-- 1. Creates monthly aggregations of immunization data
-- 2. Calculates seasonal patterns and averages
-- 3. Combines monthly data with seasonal benchmarks
-- 4. Provides comparison of actual volumes to seasonal averages

-- Assumptions and Limitations:
-- 1. Assumes current data is representative of typical patterns
-- 2. Limited to last 12 months of data
-- 3. Does not account for holidays or special events
-- 4. Treats all immunizations equally regardless of type

-- Possible Extensions:
-- 1. Add specific vaccine type analysis for seasonal patterns
-- 2. Include year-over-year comparisons
-- 3. Add correlation with local weather patterns
-- 4. Include capacity planning metrics
-- 5. Add geographic clustering analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:44:17.812698
    - Additional Notes: This query focuses on temporal patterns in immunization delivery, providing insights for operational planning. Note that the seasonal categorization is based on Northern Hemisphere seasons and may need adjustment for different geographic regions. The query requires at least 12 months of historical data for meaningful results.
    
    */