-- Title: Imaging Study Quality and Compliance Analysis
-- Business Purpose: Monitor imaging study documentation completeness and compliance
-- by analyzing the completeness of key data elements and identifying potential
-- documentation gaps. This helps ensure regulatory compliance, supports billing
-- accuracy, and improves data quality for clinical decision making.

WITH documentation_metrics AS (
    -- Calculate completeness metrics for each imaging study
    SELECT 
        DATE_TRUNC('month', date) as study_month,
        COUNT(*) as total_studies,
        SUM(CASE WHEN bodysite_code IS NOT NULL AND bodysite_description IS NOT NULL THEN 1 ELSE 0 END) as complete_bodysite,
        SUM(CASE WHEN modality_code IS NOT NULL AND modality_description IS NOT NULL THEN 1 ELSE 0 END) as complete_modality,
        SUM(CASE WHEN sop_code IS NOT NULL AND sop_description IS NOT NULL THEN 1 ELSE 0 END) as complete_sop
    FROM mimi_ws_1.synthea.imaging_studies
    WHERE date >= DATE_SUB(CURRENT_DATE, 12)
    GROUP BY DATE_TRUNC('month', date)
)

SELECT 
    study_month,
    total_studies,
    -- Calculate completion rates as percentages
    ROUND((complete_bodysite / total_studies) * 100, 2) as bodysite_completion_rate,
    ROUND((complete_modality / total_studies) * 100, 2) as modality_completion_rate,
    ROUND((complete_sop / total_studies) * 100, 2) as sop_completion_rate,
    -- Flag months with suboptimal documentation
    CASE WHEN (complete_bodysite / total_studies) < 0.95 
         OR (complete_modality / total_studies) < 0.95 
         OR (complete_sop / total_studies) < 0.95 
    THEN 'Needs Review' ELSE 'Compliant' END as compliance_status
FROM documentation_metrics
ORDER BY study_month DESC;

-- How it works:
-- 1. Creates a CTE to aggregate monthly documentation completeness metrics
-- 2. Calculates completion rates for key imaging study elements
-- 3. Identifies months where documentation falls below 95% threshold
-- 4. Orders results by month to show trends

-- Assumptions and Limitations:
-- - Assumes 95% completion rate as compliance threshold
-- - Limited to last 12 months of data
-- - Treats NULL values as incomplete documentation
-- - Does not account for variations in requirements by modality type

-- Possible Extensions:
-- 1. Add facility-level breakdown to identify specific locations needing improvement
-- 2. Include provider-specific completion rates for targeted training
-- 3. Implement severity levels based on missing element combinations
-- 4. Add trending analysis to identify systematic documentation issues
-- 5. Compare completion rates across different imaging modalities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:17:04.942564
    - Additional Notes: Query tracks documentation completeness rates over time with a 95% compliance threshold. Consider adjusting the threshold value based on specific organizational requirements. The 12-month lookback period can be modified as needed.
    
    */