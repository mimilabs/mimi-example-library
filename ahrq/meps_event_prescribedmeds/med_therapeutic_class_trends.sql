-- prescription_trends_by_therapeutic_class.sql

-- Business Purpose: 
-- Analyze prescription medication patterns by therapeutic class to identify
-- key medication categories and their prevalence. This helps healthcare
-- organizations understand medication utilization patterns, support
-- formulary decisions, and identify potential areas for clinical interventions.

WITH therapeutic_classes AS (
    -- Aggregate prescriptions by therapeutic class and year
    SELECT 
        YEAR(mimi_src_file_date) as reporting_year,
        tc1 as therapeutic_class,
        tc1s1 as therapeutic_subclass,
        COUNT(DISTINCT dupersid) as patient_count,
        COUNT(*) as prescription_count,
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY YEAR(mimi_src_file_date)) as pct_of_total_rx
    FROM mimi_ws_1.ahrq.meps_event_prescribedmeds
    WHERE tc1 IS NOT NULL 
    GROUP BY 
        YEAR(mimi_src_file_date),
        tc1,
        tc1s1
)

SELECT 
    reporting_year,
    therapeutic_class,
    therapeutic_subclass,
    patient_count,
    prescription_count,
    ROUND(pct_of_total_rx, 2) as percent_of_total_prescriptions,
    -- Calculate year-over-year growth
    LAG(prescription_count) OVER (PARTITION BY therapeutic_class ORDER BY reporting_year) as prev_year_rx_count,
    ROUND(((prescription_count * 1.0 / 
        NULLIF(LAG(prescription_count) OVER (PARTITION BY therapeutic_class ORDER BY reporting_year), 0)) - 1) * 100, 2) 
        as yoy_growth_pct
FROM therapeutic_classes
WHERE prescription_count >= 1000  -- Focus on significant medication classes
ORDER BY 
    reporting_year DESC,
    prescription_count DESC;

-- How the Query Works:
-- 1. Creates a CTE to aggregate prescription counts by therapeutic class and year
-- 2. Calculates key metrics including patient counts and prescription volumes
-- 3. Computes the percentage of total prescriptions for each class
-- 4. Adds year-over-year growth calculations
-- 5. Filters for significant medication classes with >= 1000 prescriptions
-- 6. Orders results by year and prescription volume

-- Assumptions and Limitations:
-- 1. Relies on accurate therapeutic classification coding
-- 2. Only includes primary therapeutic class (tc1), not secondary classes
-- 3. Growth calculations may be affected by changes in sample size between years
-- 4. Minimum threshold of 1000 prescriptions may need adjustment based on use case

-- Possible Extensions:
-- 1. Add demographic breakdowns (age groups, gender) for each therapeutic class
-- 2. Include average costs or days supply metrics
-- 3. Analyze seasonal patterns within therapeutic classes
-- 4. Compare brand vs generic utilization within therapeutic classes
-- 5. Add geographic analysis by state or region
-- 6. Include clinical outcome metrics if available in linked tables

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:32:49.929654
    - Additional Notes: Query provides insights into medication prescription patterns by therapeutic class with year-over-year trends. The 1000 prescription threshold may need adjustment based on dataset size. Consider indexing mimi_src_file_date and tc1 columns for optimal performance on large datasets.
    
    */