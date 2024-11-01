-- NHANES Kidney Disease Impact Assessment
-- Business Purpose: Analyze the impact of kidney conditions on patients' daily lives and 
-- quality of life by examining urinary symptoms, frequency of issues, and level of disruption.
-- This helps healthcare providers and policymakers understand the broader effects of kidney 
-- conditions beyond just clinical manifestations.

WITH kidney_impact AS (
    -- Get patients with kidney conditions and their associated quality of life metrics
    SELECT 
        seqn,
        kiq022 AS has_kidney_condition,
        kiq050 AS urine_leakage_bother_level,
        kiq052 AS daily_activities_impact,
        kiq480 AS nightly_urination_frequency,
        CASE 
            WHEN kiq005 IN (1,2) THEN 'Frequent'
            WHEN kiq005 IN (3,4) THEN 'Occasional'
            WHEN kiq005 = 5 THEN 'Never'
            ELSE 'Unknown'
        END AS urinary_leakage_frequency
    FROM mimi_ws_1.cdc.nhanes_qre_kidney_conditions
    WHERE kiq022 IS NOT NULL
)

SELECT 
    -- Calculate impact metrics
    urinary_leakage_frequency,
    COUNT(*) as patient_count,
    ROUND(AVG(CASE WHEN daily_activities_impact <= 2 THEN 1 ELSE 0 END) * 100, 1) as pct_significant_impact,
    ROUND(AVG(CASE WHEN nightly_urination_frequency >= 3 THEN 1 ELSE 0 END) * 100, 1) as pct_frequent_night_urination,
    ROUND(AVG(CASE WHEN urine_leakage_bother_level <= 2 THEN 1 ELSE 0 END) * 100, 1) as pct_highly_bothered
FROM kidney_impact
WHERE urinary_leakage_frequency != 'Unknown'
GROUP BY urinary_leakage_frequency
ORDER BY 
    CASE urinary_leakage_frequency 
        WHEN 'Frequent' THEN 1 
        WHEN 'Occasional' THEN 2 
        WHEN 'Never' THEN 3 
    END;

-- How this query works:
-- 1. Creates a CTE to classify patients based on urinary leakage frequency
-- 2. Calculates percentage of patients experiencing significant life impacts
-- 3. Groups results by leakage frequency to show correlation with quality of life

-- Assumptions and Limitations:
-- - Assumes survey responses are accurate and representative
-- - Missing or null responses are excluded
-- - Focus is on urinary symptoms as proxy for quality of life impact
-- - Does not account for potential confounding factors

-- Possible Extensions:
-- 1. Add demographic breakdowns to identify most affected populations
-- 2. Include temporal analysis to track changes over survey cycles
-- 3. Correlate with treatment methods to assess intervention effectiveness
-- 4. Add economic impact analysis by incorporating work/activity limitation data
-- 5. Create risk stratification model based on symptom severity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:33:22.787503
    - Additional Notes: Query focuses on patient-reported quality of life metrics and symptom frequency. Results are most meaningful when combined with demographic or treatment data for comprehensive impact assessment. Consider seasonal variations in symptoms when interpreting results. Some survey cycles may have different coding schemes for response values.
    
    */