-- payer_loyalty_analysis.sql

-- Business Purpose:
-- Analyze patient loyalty and churn patterns across payers to:
-- - Calculate average number of payer switches per patient
-- - Identify patterns of payer switching behavior
-- - Help payers develop retention strategies based on transition patterns
-- - Support market share analysis and competitive intelligence

WITH patient_transitions AS (
    -- Calculate the number of payer changes per patient
    SELECT 
        patient,
        COUNT(DISTINCT payer) as number_of_payers,
        COUNT(*) as total_coverage_periods,
        MIN(start_year) as first_coverage_year,
        MAX(end_year) as last_coverage_year
    FROM mimi_ws_1.synthea.payer_transitions
    GROUP BY patient
),

payer_metrics AS (
    -- Analyze transition patterns between payers
    SELECT 
        payer,
        COUNT(DISTINCT patient) as total_patients,
        AVG(end_year - start_year) as avg_coverage_duration,
        COUNT(*) as total_coverage_periods
    FROM mimi_ws_1.synthea.payer_transitions
    GROUP BY payer
)

SELECT 
    -- Calculate key loyalty metrics
    AVG(number_of_payers) as avg_payers_per_patient,
    AVG(total_coverage_periods) as avg_coverage_periods_per_patient,
    COUNT(CASE WHEN number_of_payers = 1 THEN 1 END) * 100.0 / COUNT(*) as single_payer_patient_pct,
    AVG(last_coverage_year - first_coverage_year) as avg_years_in_system,
    (SELECT 
        payer 
    FROM payer_metrics 
    ORDER BY total_patients DESC 
    LIMIT 1) as largest_payer,
    (SELECT 
        payer 
    FROM payer_metrics 
    ORDER BY avg_coverage_duration DESC 
    LIMIT 1) as highest_retention_payer
FROM patient_transitions;

-- How this query works:
-- 1. First CTE calculates patient-level metrics including number of different payers and coverage periods
-- 2. Second CTE calculates payer-level metrics including patient counts and average coverage duration
-- 3. Main query combines these metrics to produce key loyalty and churn indicators

-- Assumptions and Limitations:
-- - Assumes continuous coverage between start_year and end_year
-- - Does not account for simultaneous coverage by multiple payers
-- - Treats all payer switches equally, regardless of reason or direction
-- - Limited to available years in the dataset

-- Possible Extensions:
-- 1. Add seasonal analysis of payer switches
-- 2. Include ownership type in the analysis to understand transitions between public/private
-- 3. Create cohort analysis based on first coverage year
-- 4. Add geographic analysis if location data is available
-- 5. Calculate transition probability matrices between specific payers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:15:14.236155
    - Additional Notes: Query calculates key loyalty metrics including patient churn and payer retention rates. Note that metrics may be skewed if patients have overlapping coverage periods or if there are significant gaps between coverage periods. Results are most meaningful when analyzed alongside total market size and demographic data.
    
    */