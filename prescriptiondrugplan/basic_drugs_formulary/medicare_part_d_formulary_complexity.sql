-- Title: Medicare Part D Formulary Access and Complexity Analysis

/* 
Business Purpose:
Analyze Medicare Part D formulary drug access complexity by measuring:
- Percentage of drugs subject to additional coverage restrictions
- Distribution of drugs across cost-sharing tiers
- Comparative restrictiveness of prescription drug plan formularies

Key Business Insights:
- Quantify formulary management complexity
- Identify potential barriers to drug accessibility
- Support payer and provider decision-making around prescription coverage
*/

WITH drug_restriction_summary AS (
    SELECT 
        contract_year,
        COUNT(DISTINCT ndc) AS total_drugs,
        SUM(CASE WHEN prior_authorization_yn = 'Y' THEN 1 ELSE 0 END) AS prior_auth_drugs,
        SUM(CASE WHEN step_therapy_yn = 'Y' THEN 1 ELSE 0 END) AS step_therapy_drugs,
        SUM(CASE WHEN quantity_limit_yn = 'Y' THEN 1 ELSE 0 END) AS quantity_limited_drugs,
        ROUND(AVG(tier_level_value), 2) AS avg_tier_level
    FROM 
        mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
    WHERE 
        contract_year IS NOT NULL
    GROUP BY 
        contract_year
)

SELECT 
    contract_year,
    total_drugs,
    ROUND(prior_auth_drugs * 100.0 / total_drugs, 2) AS pct_prior_auth_drugs,
    ROUND(step_therapy_drugs * 100.0 / total_drugs, 2) AS pct_step_therapy_drugs,
    ROUND(quantity_limited_drugs * 100.0 / total_drugs, 2) AS pct_quantity_limited_drugs,
    avg_tier_level
FROM 
    drug_restriction_summary
ORDER BY 
    contract_year;

/* 
How This Query Works:
1. Aggregates drug-level restrictions by contract year
2. Calculates percentages of drugs with specific access limitations
3. Provides a comprehensive view of formulary complexity

Assumptions and Limitations:
- Assumes consistent data reporting across contract years
- Does not capture granular drug-specific details
- Uses proxy NDC codes which may not perfectly match manufacturer codes

Potential Query Extensions:
1. Add tier-level detailed breakdowns
2. Compare restrictions across different plan types
3. Analyze trend lines of formulary complexity over time
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:31:08.602391
    - Additional Notes: Aggregates Medicare Part D formulary drug access restrictions by contract year. Useful for understanding prescription drug plan coverage complexity, but limited by proxy NDC codes and snapshot-based data reporting.
    
    */