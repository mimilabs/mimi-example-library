-- condition_financial_burden_analysis.sql
-- Business Purpose:
-- - Estimate potential financial impact of medical conditions
-- - Provide insights for insurance product design and risk management
-- - Support actuarial modeling and healthcare resource allocation strategies

WITH condition_frequency AS (
    SELECT 
        code,                       -- Standardized condition code
        description,                -- Human-readable condition name
        COUNT(DISTINCT patient) AS unique_patient_count,
        COUNT(*) AS total_occurrences,
        
        -- Estimate potential complexity by calculating average duration
        AVG(DATEDIFF(stop, start)) AS avg_condition_duration_days
    FROM mimi_ws_1.synthea.conditions
    WHERE stop IS NOT NULL  -- Only consider resolved conditions
    GROUP BY code, description
),

condition_severity_estimate AS (
    SELECT 
        code,
        description,
        unique_patient_count,
        total_occurrences,
        avg_condition_duration_days,
        
        -- Simple financial impact proxy: scale by patient count and duration
        ROUND(unique_patient_count * avg_condition_duration_days / 30, 2) AS financial_burden_index
    FROM condition_frequency
)

SELECT 
    description,
    unique_patient_count,
    total_occurrences,
    avg_condition_duration_days,
    financial_burden_index,
    
    -- Rank conditions by potential financial impact
    DENSE_RANK() OVER (ORDER BY financial_burden_index DESC) AS financial_impact_rank
FROM condition_severity_estimate
ORDER BY financial_burden_index DESC
LIMIT 20;

-- Query Mechanics:
-- 1. Calculates unique patients and total occurrences per condition
-- 2. Estimates condition duration and creates a financial burden proxy
-- 3. Ranks conditions by potential economic impact
-- 4. Provides top 20 conditions with highest estimated financial burden

-- Assumptions:
-- - Duration correlates with treatment complexity
-- - Patient count indicates potential widespread impact
-- - Linear scaling of financial burden (simplification)

-- Potential Extensions:
-- - Integrate actual treatment costs
-- - Include age and demographic segmentation
-- - Add regional or healthcare system specifics
-- - Create predictive financial risk models

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:26:30.058035
    - Additional Notes: The query provides a synthetic healthcare conditions analysis using a financial impact proxy. Note that this uses generated data and should be treated as a modeling exercise, not actual clinical or financial reporting.
    
    */