-- snf_fiscal_year_seasonality.sql

-- Business Purpose:
-- Analyze the fiscal year patterns of Skilled Nursing Facilities to understand:
-- 1. Seasonal reporting cycles and their impact on data availability
-- 2. Common fiscal year start/end dates to better time analytics updates
-- 3. Planning cycles for healthcare organizations working with SNFs
-- This helps organizations align their analytics and business planning with SNF reporting cycles.

WITH fiscal_patterns AS (
    -- Extract year and month components from fiscal year dates
    SELECT 
        EXTRACT(YEAR FROM fy_bgn_dt) as fiscal_year,
        EXTRACT(MONTH FROM fy_bgn_dt) as start_month,
        EXTRACT(MONTH FROM fy_end_dt) as end_month,
        COUNT(DISTINCT prvdr_num) as facility_count,
        -- Calculate the average reporting cycle length
        AVG(DATEDIFF(fy_end_dt, fy_bgn_dt)) as avg_cycle_length
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_rpt
    WHERE 
        fy_bgn_dt IS NOT NULL 
        AND fy_end_dt IS NOT NULL
        AND fy_bgn_dt <= CURRENT_DATE()
        AND fy_end_dt <= CURRENT_DATE()
    GROUP BY 
        fiscal_year,
        start_month,
        end_month
)

SELECT 
    fiscal_year,
    -- Identify common fiscal patterns
    CASE 
        WHEN start_month = 1 THEN 'Calendar Year'
        WHEN start_month = 10 THEN 'Federal Fiscal Year'
        WHEN start_month = 7 THEN 'Academic Fiscal Year'
        ELSE 'Other Pattern'
    END as fiscal_pattern,
    start_month,
    end_month,
    facility_count,
    ROUND(avg_cycle_length, 0) as avg_days_in_cycle,
    -- Calculate percentage of total facilities for that year
    ROUND(100.0 * facility_count / SUM(facility_count) OVER (PARTITION BY fiscal_year), 2) as pct_of_year_total
FROM fiscal_patterns
WHERE fiscal_year >= 2010  -- Focus on recent years
ORDER BY 
    fiscal_year DESC,
    facility_count DESC;

-- How this works:
-- 1. Creates a CTE to extract and aggregate fiscal year patterns
-- 2. Categorizes fiscal patterns based on common start months
-- 3. Calculates facility counts and percentages for each pattern
-- 4. Orders results to show most recent and most common patterns first

-- Assumptions and Limitations:
-- 1. Assumes fiscal year dates are valid and properly formatted
-- 2. Limited to standard fiscal patterns (calendar, federal, academic)
-- 3. Does not account for facilities with multiple reports in same year
-- 4. Focused on recent years (2010+) for relevance

-- Possible Extensions:
-- 1. Add geographic analysis of fiscal patterns by state/region
-- 2. Include provider control type to analyze ownership impact on fiscal timing
-- 3. Analyze submission delays relative to fiscal year end
-- 4. Compare fiscal patterns with quality metrics or financial performance
-- 5. Create forecasting model for expected report submissions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:17:06.973564
    - Additional Notes: Query focuses on fiscal year cycle patterns among SNFs and requires at least one full year of historical data to produce meaningful results. Best used for strategic planning of data collection and reporting schedules. Performance may be impacted with very large datasets due to window functions.
    
    */