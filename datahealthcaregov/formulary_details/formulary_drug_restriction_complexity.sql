-- Title: Healthcare.gov Formulary - Drug Restriction Complexity Analysis

-- Business Purpose:
-- Analyze the complexity of drug coverage rules across health insurance plans
-- Identify plans with the most restrictive prescription drug policies
-- Support strategic insights for health plan comparisons and consumer decision-making

WITH drug_restriction_summary AS (
    SELECT 
        plan_id,
        plan_id_type,
        years,
        COUNT(DISTINCT rxnorm_id) AS total_drugs,
        
        -- Calculate the percentage of drugs with coverage restrictions
        ROUND(100.0 * SUM(CASE WHEN prior_authorization = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS prior_auth_percentage,
        ROUND(100.0 * SUM(CASE WHEN step_therapy = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS step_therapy_percentage,
        ROUND(100.0 * SUM(CASE WHEN quantity_limit = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS quantity_limit_percentage,
        
        -- Compute a "restriction complexity" score
        ROUND(
            (SUM(CASE WHEN prior_authorization = 'Yes' THEN 1 ELSE 0 END) +
             SUM(CASE WHEN step_therapy = 'Yes' THEN 1 ELSE 0 END) +
             SUM(CASE WHEN quantity_limit = 'Yes' THEN 1 ELSE 0 END)) * 100.0 / COUNT(*), 2
        ) AS restriction_complexity_score

    FROM mimi_ws_1.datahealthcaregov.formulary_details
    WHERE years = (SELECT MAX(years) FROM mimi_ws_1.datahealthcaregov.formulary_details)
    GROUP BY plan_id, plan_id_type, years
)

SELECT 
    plan_id,
    plan_id_type,
    years,
    total_drugs,
    prior_auth_percentage,
    step_therapy_percentage,
    quantity_limit_percentage,
    restriction_complexity_score,
    
    -- Categorize plans based on restriction complexity
    CASE 
        WHEN restriction_complexity_score >= 75 THEN 'Highly Restrictive'
        WHEN restriction_complexity_score BETWEEN 50 AND 74 THEN 'Moderately Restrictive'
        ELSE 'Least Restrictive'
    END AS plan_restriction_category

FROM drug_restriction_summary
ORDER BY restriction_complexity_score DESC
LIMIT 50;

-- How the Query Works:
-- 1. Calculates the percentage of drugs with various coverage restrictions
-- 2. Creates a composite "restriction complexity" score
-- 3. Categorizes plans based on their drug coverage complexity
-- 4. Provides a ranked view of the most restrictive health plans

-- Assumptions and Limitations:
-- - Uses the most recent year's data
-- - Restriction complexity is a simple additive score
-- - Assumes 'Yes' indicates a restriction
-- - Limited to top 50 restrictive plans

-- Potential Query Extensions:
-- 1. Add drug tier analysis
-- 2. Compare restrictions across different plan types
-- 3. Trend analysis of restriction complexity over years
-- 4. Incorporate drug class or therapeutic area insights

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:42:02.114557
    - Additional Notes: This query analyzes drug coverage restrictions across health insurance plans, providing insights into plan complexity. It should be used with caution, as the restriction complexity score is a simplified metric and may not capture all nuances of drug coverage policies.
    
    */