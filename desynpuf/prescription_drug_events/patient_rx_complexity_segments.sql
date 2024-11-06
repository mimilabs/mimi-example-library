-- patient_drug_behavior_profile.sql
--
-- Business Purpose:
-- Analyze patient prescription drug behavior patterns to identify:
-- - Average number of unique medications per patient
-- - Patient consistency in refills across multiple medications
-- - Financial burden distribution across patient population
-- This insight helps identify opportunities for patient support programs
-- and medication therapy management interventions.

WITH patient_rx_metrics AS (
    -- Calculate key prescription metrics per patient
    SELECT 
        desynpuf_id,
        COUNT(DISTINCT prod_srvc_id) as unique_drugs,
        COUNT(*) as total_prescriptions,
        ROUND(AVG(days_suply_num),1) as avg_days_supply,
        SUM(ptnt_pay_amt) as total_patient_paid,
        SUM(tot_rx_cst_amt) as total_rx_cost
    FROM mimi_ws_1.desynpuf.prescription_drug_events
    GROUP BY desynpuf_id
),

patient_segments AS (
    -- Segment patients based on prescription complexity
    SELECT 
        CASE 
            WHEN unique_drugs >= 5 THEN 'High Complex'
            WHEN unique_drugs >= 3 THEN 'Moderate Complex'
            ELSE 'Low Complex'
        END as complexity_segment,
        COUNT(*) as patient_count,
        ROUND(AVG(total_prescriptions),1) as avg_prescriptions,
        ROUND(AVG(total_patient_paid),2) as avg_patient_paid,
        ROUND(AVG(total_rx_cost),2) as avg_total_cost
    FROM patient_rx_metrics
    GROUP BY 
        CASE 
            WHEN unique_drugs >= 5 THEN 'High Complex'
            WHEN unique_drugs >= 3 THEN 'Moderate Complex'
            ELSE 'Low Complex'
        END
)

-- Final output with patient segments and key metrics
SELECT 
    complexity_segment,
    patient_count,
    avg_prescriptions,
    avg_patient_paid,
    avg_total_cost,
    ROUND(avg_patient_paid / avg_total_cost * 100, 1) as patient_cost_share_pct
FROM patient_segments
ORDER BY 
    CASE complexity_segment 
        WHEN 'High Complex' THEN 1
        WHEN 'Moderate Complex' THEN 2
        ELSE 3
    END;

-- How this query works:
-- 1. First CTE calculates per-patient metrics including unique drugs and costs
-- 2. Second CTE segments patients based on prescription complexity
-- 3. Final query presents key metrics by segment with cost share calculation

-- Assumptions and Limitations:
-- - Assumes all prescriptions in the period are captured
-- - Does not account for prescription therapeutic class
-- - Complexity segmentation thresholds are simplified for illustration
-- - Does not consider temporal patterns in prescription fills

-- Possible Extensions:
-- 1. Add temporal analysis to identify seasonal patterns
-- 2. Include therapeutic class analysis for better complexity assessment
-- 3. Add year-over-year comparison of patient segments
-- 4. Include analysis of specific high-cost medications
-- 5. Add geographic clustering of patient segments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:59:03.037370
    - Additional Notes: The query segments patients based on medication complexity and provides insights into cost burden across different patient groups. The segmentation thresholds (5+ drugs for high complex, 3+ for moderate) should be validated against clinical guidelines for the specific patient population being analyzed.
    
    */