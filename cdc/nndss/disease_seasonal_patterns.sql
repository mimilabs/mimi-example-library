-- NNDSS Weekly Disease Pattern Analysis
--
-- Business Purpose:
-- Analyzes the seasonality and weekly patterns of notifiable diseases to help
-- public health officials better anticipate and prepare for disease activity surges.
-- This information supports resource allocation, staffing decisions, and 
-- preventive measure timing across healthcare facilities.

WITH weekly_patterns AS (
    -- Calculate average weekly cases and identify peak weeks for each disease
    SELECT 
        label as disease_name,
        mmwr_week,
        ROUND(AVG(current_week), 1) as avg_weekly_cases,
        MAX(current_week) as max_weekly_cases,
        COUNT(DISTINCT current_mmwr_year) as years_of_data
    FROM mimi_ws_1.cdc.nndss
    WHERE 
        current_week IS NOT NULL 
        AND current_week_flag IS NULL  -- Exclude flagged data
        AND reporting_area = 'UNITED STATES'  -- National level analysis
    GROUP BY 
        label,
        mmwr_week
),

top_weeks AS (
    -- Get top 4 weeks for each disease
    SELECT 
        disease_name,
        mmwr_week,
        avg_weekly_cases,
        ROW_NUMBER() OVER (PARTITION BY disease_name ORDER BY avg_weekly_cases DESC) as week_rank
    FROM weekly_patterns
),

disease_metrics AS (
    -- Identify peak seasons and consistent patterns
    SELECT 
        w.disease_name,
        -- Collect top weeks into an array
        COLLECT_LIST(CASE WHEN t.week_rank <= 4 THEN t.mmwr_week END) as peak_weeks,
        MAX(w.max_weekly_cases) as highest_weekly_count,
        ROUND(AVG(w.avg_weekly_cases), 1) as typical_weekly_cases,
        MAX(w.years_of_data) as data_years
    FROM weekly_patterns w
    LEFT JOIN top_weeks t ON w.disease_name = t.disease_name AND w.mmwr_week = t.mmwr_week
    GROUP BY w.disease_name
)

-- Final output with key insights
SELECT 
    disease_name,
    peak_weeks as typical_peak_weeks,
    highest_weekly_count,
    typical_weekly_cases,
    data_years,
    -- Calculate relative intensity of peaks
    ROUND(highest_weekly_count / NULLIF(typical_weekly_cases, 0), 1) as peak_to_average_ratio
FROM disease_metrics
WHERE typical_weekly_cases > 0  -- Focus on diseases with regular activity
ORDER BY typical_weekly_cases DESC
LIMIT 20;  -- Focus on most common diseases

-- How this works:
-- 1. First CTE calculates average and maximum cases for each disease by week
-- 2. Second CTE ranks weeks by average cases for each disease
-- 3. Third CTE aggregates metrics and collects top weeks into arrays
-- 4. Final query presents the most relevant diseases with their seasonal patterns
--
-- Assumptions and Limitations:
-- - Assumes national-level reporting is consistent and representative
-- - Limited to diseases with regular occurrence (filters out rare events)
-- - Weekly averages may smooth out important year-specific variations
-- - Peak weeks identification assumes consistent seasonal patterns
--
-- Possible Extensions:
-- 1. Add geographic stratification to identify regional pattern differences
-- 2. Compare patterns across different years to detect pattern changes
-- 3. Include correlation analysis between different diseases
-- 4. Add weather/climate data to analyze environmental factors
-- 5. Create forward-looking predictions based on historical patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:14:51.645751
    - Additional Notes: Query focuses on national-level seasonal disease patterns and requires 'UNITED STATES' to be a valid reporting_area value. Peak weeks analysis is limited to diseases with consistent reporting and may not capture irregular outbreaks effectively. COLLECT_LIST function assumes ordered collection is maintained.
    
    */