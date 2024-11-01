-- Title: Medication Utilization Patterns by Payer Analysis

-- Business Purpose:
-- - Identify prescribing patterns across different insurance payers
-- - Analyze average prescription duration and dispense rates by payer
-- - Support payer contract negotiations and network optimization
-- - Guide formulary management decisions

WITH payer_metrics AS (
    -- Calculate key metrics per payer
    SELECT 
        payer,
        COUNT(DISTINCT patient) as patient_count,
        COUNT(DISTINCT code) as unique_medications,
        AVG(DATEDIFF(COALESCE(stop, CURRENT_DATE), start)) as avg_prescription_days,
        AVG(dispenses) as avg_dispenses,
        SUM(totalcost) as total_medication_cost
    FROM mimi_ws_1.synthea.medications
    WHERE start >= DATE_SUB(CURRENT_DATE, 365)  -- Last 12 months
    GROUP BY payer
),
payer_ranks AS (
    -- Add rankings and calculations for analysis
    SELECT 
        *,
        ROUND(total_medication_cost / patient_count, 2) as cost_per_patient,
        ROUND(unique_medications / patient_count * 100, 2) as med_diversity_score,
        RANK() OVER (ORDER BY patient_count DESC) as volume_rank
    FROM payer_metrics
)
-- Final result set with key insights
SELECT 
    payer,
    patient_count,
    unique_medications,
    ROUND(avg_prescription_days, 1) as avg_prescription_days,
    ROUND(avg_dispenses, 1) as avg_dispenses,
    ROUND(total_medication_cost, 2) as total_medication_cost,
    cost_per_patient,
    med_diversity_score,
    volume_rank
FROM payer_ranks
ORDER BY volume_rank;

-- How this query works:
-- 1. First CTE aggregates key metrics by payer from the medications table
-- 2. Second CTE adds derived metrics and rankings
-- 3. Final select formats and presents the results in a meaningful order

-- Assumptions and Limitations:
-- - Assumes current prescriptions without stop dates are still active
-- - Limited to last 12 months of data for currency
-- - Does not account for seasonal variations
-- - Medication switches within same therapeutic class counted separately

-- Possible Extensions:
-- 1. Add therapeutic class grouping to analyze formulary coverage
-- 2. Include temporal trends to show payer behavior changes
-- 3. Add geographic analysis if location data available
-- 4. Compare brand vs generic utilization patterns
-- 5. Incorporate patient demographic analysis by payer

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:52:11.417285
    - Additional Notes: Query focuses on payer-level medication patterns and requires at least 12 months of historical data in the medications table. The med_diversity_score calculation assumes higher values indicate better formulary coverage. Cost calculations may need adjustment based on specific pricing models.
    
    */