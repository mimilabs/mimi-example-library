-- Title: Seasonal Medication Prescribing Trends Analysis

-- Business Purpose:
-- - Identify seasonal patterns in medication prescribing
-- - Understand medication volume trends across different months/seasons
-- - Support inventory management and staffing decisions
-- - Guide seasonal health campaign planning

WITH monthly_prescriptions AS (
    -- Extract month and year from start date and count prescriptions
    SELECT 
        EXTRACT(YEAR FROM start) as year,
        EXTRACT(MONTH FROM start) as month,
        COUNT(*) as prescription_count,
        COUNT(DISTINCT patient) as unique_patients,
        COUNT(DISTINCT description) as unique_medications
    FROM mimi_ws_1.synthea.medications
    WHERE start >= '2020-01-01' -- Focus on recent years
    GROUP BY 
        EXTRACT(YEAR FROM start),
        EXTRACT(MONTH FROM start)
),

seasonal_avg AS (
    -- Calculate average prescriptions by month across years
    SELECT 
        month,
        ROUND(AVG(prescription_count), 2) as avg_prescriptions,
        ROUND(AVG(unique_patients), 2) as avg_patients,
        ROUND(AVG(unique_medications), 2) as avg_unique_meds
    FROM monthly_prescriptions
    GROUP BY month
)

-- Final output showing seasonal patterns
SELECT 
    month,
    avg_prescriptions,
    avg_patients,
    avg_unique_meds,
    -- Calculate percent difference from annual average
    ROUND(((avg_prescriptions - (SELECT AVG(avg_prescriptions) FROM seasonal_avg)) / 
           (SELECT AVG(avg_prescriptions) FROM seasonal_avg) * 100), 2) as pct_diff_from_avg
FROM seasonal_avg
ORDER BY month;

-- How it works:
-- 1. First CTE aggregates prescription data by month and year
-- 2. Second CTE calculates monthly averages across all years
-- 3. Final query adds percentage difference from annual average
-- 4. Results show monthly prescription patterns and variations

-- Assumptions and Limitations:
-- - Assumes prescription start date is representative of prescribing patterns
-- - Limited to dates after 2020 for recent trends
-- - Seasonal patterns may vary by medication type or condition
-- - Synthetic data may not fully reflect real-world seasonal variations

-- Possible Extensions:
-- 1. Add medication category/class analysis to identify which types drive seasonal patterns
-- 2. Include geographic region analysis if available
-- 3. Correlate with specific conditions or diagnoses
-- 4. Add year-over-year growth analysis
-- 5. Break down by age groups or patient demographics
-- 6. Analyze seasonal cost variations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:26:00.981998
    - Additional Notes: Query focuses on post-2020 data to establish recent seasonal patterns. Results are averaged across years to smooth out anomalies and provide more reliable seasonal insights. Consider adjusting the date filter (2020-01-01) based on available data range.
    
    */