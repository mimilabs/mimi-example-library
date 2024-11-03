-- Prescription Drug Therapy Duration and Refill Pattern Analysis
--
-- Business Purpose:
-- Analyze patterns in prescription drug therapies to identify:
-- - Average therapy duration for medications
-- - Refill patterns and adherence indicators
-- - Variations in prescription continuity
-- This helps identify opportunities for medication adherence programs
-- and care management interventions.

WITH patient_drug_patterns AS (
    -- Get sequential prescription events per patient-drug combination
    SELECT 
        desynpuf_id,
        prod_srvc_id,
        srvc_dt,
        days_suply_num,
        qty_dspnsd_num,
        -- Calculate days between prescriptions
        DATEDIFF(srvc_dt, 
                LAG(srvc_dt) OVER (PARTITION BY desynpuf_id, prod_srvc_id 
                                  ORDER BY srvc_dt)) as days_between_rx,
        -- Count prescriptions per patient-drug
        COUNT(*) OVER (PARTITION BY desynpuf_id, prod_srvc_id) as rx_count
    FROM mimi_ws_1.desynpuf.prescription_drug_events
    WHERE srvc_dt BETWEEN '2008-01-01' AND '2010-12-31'
),

adherence_metrics AS (
    -- Calculate key therapy metrics
    SELECT 
        prod_srvc_id,
        COUNT(DISTINCT desynpuf_id) as patient_count,
        AVG(days_suply_num) as avg_supply_days,
        AVG(CASE WHEN days_between_rx IS NOT NULL 
            THEN days_between_rx END) as avg_days_between_refills,
        AVG(rx_count) as avg_rx_per_patient
    FROM patient_drug_patterns
    GROUP BY prod_srvc_id
)

-- Final output with therapy patterns
SELECT 
    prod_srvc_id as medication_id,
    patient_count,
    ROUND(avg_supply_days, 1) as typical_days_supply,
    ROUND(avg_days_between_refills, 1) as typical_days_between_refills,
    ROUND(avg_rx_per_patient, 1) as avg_prescriptions_per_patient,
    -- Flag potential adherence concerns
    CASE 
        WHEN avg_days_between_refills > (avg_supply_days * 1.25) THEN 'Potential Gap in Therapy'
        WHEN avg_days_between_refills < (avg_supply_days * 0.9) THEN 'Early Refills'
        ELSE 'Normal Pattern'
    END as refill_pattern_flag
FROM adherence_metrics
WHERE patient_count >= 100  -- Focus on commonly prescribed medications
ORDER BY patient_count DESC
LIMIT 50;

-- How this works:
-- 1. First CTE establishes prescription sequence for each patient-drug combination
-- 2. Second CTE calculates aggregate metrics per medication
-- 3. Final query adds interpretive flags and filters for relevance
--
-- Assumptions and limitations:
-- - Assumes prescription dates and supply days are accurate
-- - Does not account for hospitalizations or other therapy interruptions
-- - Limited to 2008-2010 time period
-- - Synthetic data may not reflect real-world patterns
--
-- Possible extensions:
-- 1. Add seasonal analysis of prescription patterns
-- 2. Include cost analysis for non-adherence impact
-- 3. Link to diagnostic codes to analyze condition-specific patterns
-- 4. Add demographic analysis of adherence patterns
-- 5. Create time-based trends in adherence metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:04:41.943119
    - Additional Notes: Query filters for medications with at least 100 patients to ensure statistical relevance. The adherence flags use standard thresholds (25% grace period for gaps, 10% early refill threshold) that may need adjustment based on specific medication types or organizational policies.
    
    */