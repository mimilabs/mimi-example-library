-- patient_coverage_gaps.sql

-- Business Purpose:
-- Analyze insurance coverage gaps at individual patient level to:
-- - Identify patients with significant gaps in coverage
-- - Assess the timing and duration of coverage gaps
-- - Support targeted outreach and retention initiatives
-- - Enable early intervention for high-risk patients

WITH continuous_coverage AS (
    -- First calculate each patient's coverage timeline
    SELECT 
        patient,
        start_year,
        end_year,
        payer,
        -- Calculate days between coverage periods
        LEAD(start_year) OVER (PARTITION BY patient ORDER BY start_year) - end_year AS gap_years
    FROM mimi_ws_1.synthea.payer_transitions
    WHERE start_year IS NOT NULL 
    AND end_year IS NOT NULL
),

patient_gaps AS (
    -- Identify significant gaps (more than 1 year)
    SELECT
        patient,
        start_year AS gap_start_year,
        LEAD(start_year) OVER (PARTITION BY patient ORDER BY start_year) AS next_coverage_year,
        payer AS previous_payer,
        LEAD(payer) OVER (PARTITION BY patient ORDER BY start_year) AS next_payer,
        gap_years
    FROM continuous_coverage
    WHERE gap_years > 1
)

SELECT
    COUNT(DISTINCT patient) as patients_with_gaps,
    AVG(gap_years) as avg_gap_duration,
    MIN(gap_years) as min_gap_years,
    MAX(gap_years) as max_gap_years,
    -- Categorize gap durations
    COUNT(CASE WHEN gap_years BETWEEN 1 AND 2 THEN 1 END) as gaps_1_2_years,
    COUNT(CASE WHEN gap_years BETWEEN 2 AND 5 THEN 1 END) as gaps_2_5_years,
    COUNT(CASE WHEN gap_years > 5 THEN 1 END) as gaps_over_5_years
FROM patient_gaps;

-- How this works:
-- 1. Creates timeline of coverage for each patient
-- 2. Calculates gaps between coverage periods
-- 3. Identifies gaps > 1 year
-- 4. Summarizes gap patterns across population

-- Assumptions and Limitations:
-- - Assumes gaps > 1 year are significant and worthy of intervention
-- - Does not account for partial year coverage
-- - May include expected gaps (e.g., moving abroad)
-- - Limited to available years in dataset

-- Possible Extensions:
-- 1. Add demographic factors to identify vulnerable populations
-- 2. Include seasonal patterns of coverage gaps
-- 3. Correlate gaps with specific payer transitions
-- 4. Add geographic analysis of gap patterns
-- 5. Include cost impact analysis of coverage gaps

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:39:08.151832
    - Additional Notes: Query focuses on identifying insurance coverage gaps of 1+ years. The analysis provides high-level metrics about gap frequency and duration, which can be valuable for risk assessment and intervention planning. Note that the query currently treats all gaps equally and does not differentiate between voluntary and involuntary coverage gaps.
    
    */