-- snf_claims_diagnosis_patterns.sql
-- 
-- Business Purpose:
-- Analyzes the most common diagnoses and diagnosis patterns in skilled nursing facility (SNF) claims
-- to understand the key medical conditions driving SNF utilization. This insight helps with:
-- 1. Care pathway optimization
-- 2. Resource planning and staffing
-- 3. Clinical program development
-- 4. Care coordination with referring hospitals

WITH diagnosis_counts AS (
    -- Get primary diagnoses and count occurrences
    SELECT 
        prncpal_dgns_cd as diagnosis_code,
        COUNT(*) as diagnosis_count,
        COUNT(DISTINCT bene_id) as unique_patients,
        AVG(clm_pmt_amt) as avg_payment,
        AVG(clm_utlztn_day_cnt) as avg_length_of_stay
    FROM mimi_ws_1.synmedpuf.snf
    WHERE prncpal_dgns_cd IS NOT NULL
    GROUP BY prncpal_dgns_cd
),

ranked_diagnoses AS (
    -- Rank diagnoses by frequency
    SELECT 
        diagnosis_code,
        diagnosis_count,
        unique_patients,
        avg_payment,
        avg_length_of_stay,
        ROW_NUMBER() OVER (ORDER BY diagnosis_count DESC) as rank
    FROM diagnosis_counts
)

-- Return top 20 most common diagnoses with key metrics
SELECT 
    diagnosis_code,
    diagnosis_count,
    unique_patients,
    ROUND(avg_payment, 2) as avg_payment_per_claim,
    ROUND(avg_length_of_stay, 1) as avg_length_of_stay_days,
    ROUND(100.0 * diagnosis_count / SUM(diagnosis_count) OVER (), 2) as pct_of_total_claims
FROM ranked_diagnoses
WHERE rank <= 20
ORDER BY diagnosis_count DESC;

-- How this query works:
-- 1. First CTE counts occurrences of each primary diagnosis code
-- 2. Second CTE ranks diagnoses by frequency
-- 3. Main query returns top 20 with key utilization metrics
-- 4. Calculates percentage of total claims for each diagnosis

-- Assumptions and Limitations:
-- 1. Only analyzes primary diagnosis codes, not secondary diagnoses
-- 2. Does not account for diagnosis code changes over time (ICD-9 to ICD-10)
-- 3. Assumes diagnosis codes are properly coded and complete
-- 4. Payment amounts may not reflect total cost of care

-- Possible Extensions:
-- 1. Add diagnosis descriptions by joining to a diagnosis code reference table
-- 2. Analyze diagnosis patterns by patient demographics or geography
-- 3. Look at combinations of primary and secondary diagnoses
-- 4. Trend analysis over time to see changing patterns
-- 5. Compare diagnosis patterns between facilities or regions
-- 6. Add readmission rates by diagnosis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:49:08.893908
    - Additional Notes: Query focuses on primary diagnosis frequency and related metrics in SNF claims. May need to be joined with a diagnosis code lookup table for meaningful descriptions. Consider memory usage when running on large datasets due to window functions.
    
    */