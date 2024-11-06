-- Title: Immunization Sequence and Patient Care Patterns Analysis

-- Business Purpose:
-- This analysis helps healthcare organizations improve patient care continuity by:
-- 1. Identifying typical immunization sequences for individual patients
-- 2. Analyzing gaps between immunizations and repeat visits
-- 3. Understanding patient engagement patterns through immunization touchpoints

WITH patient_immunization_sequence AS (
    -- Get ordered immunization history per patient
    SELECT 
        patient,
        date,
        description,
        encounter,
        -- Calculate days since previous immunization
        DATEDIFF(date, 
            LAG(date) OVER (PARTITION BY patient ORDER BY date)
        ) as days_since_last_immunization,
        -- Track immunization sequence number for each patient
        ROW_NUMBER() OVER (PARTITION BY patient ORDER BY date) as immunization_sequence
    FROM mimi_ws_1.synthea.immunizations
    WHERE date >= '2020-01-01' -- Focus on recent data
),

patient_engagement_metrics AS (
    -- Analyze patient engagement patterns
    SELECT 
        patient,
        COUNT(*) as total_immunizations,
        COUNT(DISTINCT encounter) as unique_visits,
        AVG(days_since_last_immunization) as avg_days_between_immunizations,
        MAX(immunization_sequence) as max_sequence_number
    FROM patient_immunization_sequence
    GROUP BY patient
)

-- Final result set combining sequence and engagement metrics
SELECT 
    -- Categorize engagement levels
    CASE 
        WHEN total_immunizations >= 5 THEN 'High Engagement'
        WHEN total_immunizations >= 3 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END as engagement_level,
    COUNT(DISTINCT patient) as patient_count,
    AVG(total_immunizations) as avg_immunizations_per_patient,
    AVG(unique_visits) as avg_visits_per_patient,
    AVG(avg_days_between_immunizations) as typical_days_between_immunizations
FROM patient_engagement_metrics
GROUP BY 
    CASE 
        WHEN total_immunizations >= 5 THEN 'High Engagement'
        WHEN total_immunizations >= 3 THEN 'Medium Engagement'
        ELSE 'Low Engagement'
    END
ORDER BY patient_count DESC;

-- How this query works:
-- 1. First CTE creates a sequence of immunizations per patient with timing metrics
-- 2. Second CTE calculates engagement metrics for each patient
-- 3. Final query segments patients by engagement level and provides aggregate metrics

-- Assumptions and Limitations:
-- 1. Uses 2020 onwards data only - adjust date filter as needed
-- 2. Engagement levels are arbitrarily defined based on immunization count
-- 3. Does not account for expected vs. actual immunization schedules
-- 4. Assumes sequential immunizations within same encounter are meaningful

-- Possible Extensions:
-- 1. Add age group analysis to understand engagement patterns by demographics
-- 2. Include specific vaccine types to track completion of standard series
-- 3. Incorporate seasonality analysis for recurring immunizations
-- 4. Add cost analysis dimension to understand financial impact of engagement patterns
-- 5. Compare engagement patterns across different healthcare facilities or regions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:54:52.263157
    - Additional Notes: Query focuses on patient engagement patterns through immunization sequences and visit frequency. The engagement level thresholds (5+ for high, 3+ for medium) may need adjustment based on specific organizational standards or patient population characteristics. Consider the 2020 date filter impact on historical analysis.
    
    */