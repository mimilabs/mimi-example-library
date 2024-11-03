-- Title: Aspirin Dosage Analysis for Patient Safety and Adherence
-- Business Purpose: 
-- Analyze dosage patterns of preventive aspirin use to identify potential safety concerns
-- and opportunities for improving patient guidance. This helps healthcare providers 
-- better understand actual dosing behaviors compared to recommendations.

WITH base_doses AS (
    -- Get valid dosage records and standardize units
    SELECT 
        seqn,
        rxd530 as dose_mg,
        CASE 
            WHEN rxq525u = 1 THEN 'Daily'
            WHEN rxq525u = 2 THEN 'Weekly'
            ELSE 'Other'
        END as frequency,
        rxq525q as frequency_count,
        rxq515 as following_provider_advice,
        rxq520 as self_directed_use
    FROM mimi_ws_1.cdc.nhanes_qre_preventive_aspirin_use
    WHERE rxd530 IS NOT NULL 
    AND rxq525u IN (1,2)
    AND rxq525q IS NOT NULL
)

SELECT 
    -- Calculate dosing categories
    CASE 
        WHEN dose_mg <= 81 THEN 'Low dose (≤81mg)'
        WHEN dose_mg <= 325 THEN 'Regular dose (82-325mg)'
        ELSE 'High dose (>325mg)'
    END as dose_category,
    
    -- Analyze frequency patterns
    frequency,
    
    -- Calculate patient counts and percentages
    COUNT(*) as patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total,
    
    -- Analyze guidance adherence
    SUM(CASE WHEN following_provider_advice = 1 THEN 1 ELSE 0 END) as following_provider_count,
    SUM(CASE WHEN self_directed_use = 1 THEN 1 ELSE 0 END) as self_directed_count,
    
    -- Calculate average doses
    ROUND(AVG(dose_mg), 2) as avg_dose_mg,
    ROUND(AVG(frequency_count), 2) as avg_frequency_count

FROM base_doses
GROUP BY 
    CASE 
        WHEN dose_mg <= 81 THEN 'Low dose (≤81mg)'
        WHEN dose_mg <= 325 THEN 'Regular dose (82-325mg)'
        ELSE 'High dose (>325mg)'
    END,
    frequency
ORDER BY 
    dose_category,
    frequency;

-- How this query works:
-- 1. Creates a CTE with standardized dose and frequency information
-- 2. Groups results by dose category and frequency
-- 3. Calculates key metrics including patient counts, adherence, and dosing patterns
-- 4. Orders results for clear presentation of dosing patterns

-- Assumptions and Limitations:
-- - Assumes rxd530 values are in milligrams
-- - Limited to records with valid dosage and frequency information
-- - Focuses on daily and weekly dosing patterns only
-- - Does not account for seasonal or temporary use patterns

-- Possible Extensions:
-- 1. Add temporal analysis to track dosing changes over time
-- 2. Include demographic factors to identify population-specific patterns
-- 3. Add safety flags for potentially concerning dosing patterns
-- 4. Compare dosing patterns against specific medical conditions
-- 5. Analyze the relationship between dosing patterns and adherence rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:54:31.057244
    - Additional Notes: Query focuses on safety-oriented analysis of aspirin dosage patterns, categorizing doses into low/regular/high ranges and analyzing adherence patterns. Best used for identifying potential over/under-dosing trends and comparing provider-guided versus self-directed usage patterns. Note that the 81mg and 325mg thresholds are based on common clinical guidelines for preventive aspirin therapy.
    
    */