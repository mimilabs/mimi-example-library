
-- File: plan_network_complexity_analysis.sql
-- Title: Medicare Plan Network and Cost Complexity Diagnostic

/* 
Business Purpose:
- Assess the structural complexity and cost diversity of Medicare prescription drug plans
- Identify plans with unique network, cost, and coverage characteristics
- Support strategic market segmentation and plan design insights

Primary Analytical Lens: 
- Evaluate plan variability across critical financial and network dimensions
*/

WITH plan_network_complexity AS (
    SELECT 
        -- Plan Categorization
        CASE 
            SUBSTR(contract_id, 1, 1)
            WHEN 'H' THEN 'Local Medicare Advantage'
            WHEN 'R' THEN 'Regional Medicare Advantage'
            WHEN 'S' THEN 'Standalone Prescription Drug Plan'
            ELSE 'Other'
        END AS plan_category,

        -- Segmentation Metrics
        snp AS special_needs_plan_type,
        COUNT(DISTINCT plan_id) AS unique_plan_count,
        
        -- Financial Complexity Indicators
        ROUND(AVG(premium), 2) AS avg_monthly_premium,
        ROUND(AVG(deductible), 2) AS avg_annual_deductible,
        ROUND(AVG(icl), 2) AS avg_initial_coverage_limit,
        
        -- Geographic Diversity
        COUNT(DISTINCT state) AS states_covered,
        COUNT(DISTINCT county_code) AS counties_covered,
        
        -- Suppression Indicator
        ROUND(
            100.0 * SUM(CASE WHEN plan_suppressed_yn = 'Y' THEN 1 ELSE 0 END) / 
            COUNT(*), 
            2
        ) AS percent_suppressed_plans

    FROM 
        mimi_ws_1.prescriptiondrugplan.plan_information
    
    GROUP BY 
        plan_category, 
        special_needs_plan_type
)

SELECT 
    plan_category,
    special_needs_plan_type,
    unique_plan_count,
    avg_monthly_premium,
    avg_annual_deductible,
    avg_initial_coverage_limit,
    states_covered,
    counties_covered,
    percent_suppressed_plans
FROM 
    plan_network_complexity
ORDER BY 
    unique_plan_count DESC, 
    avg_monthly_premium DESC;

/*
Query Mechanics:
- Transforms raw plan information into a structured complexity diagnostic
- Uses window functions and case statements for nuanced categorization
- Aggregates data at plan category and special needs plan type levels

Assumptions and Limitations:
- Relies on CMS-assigned contract and plan identifiers
- Does not include actual plan names due to data suppression
- Snapshot represents a specific point in time

Potential Extensions:
1. Incorporate formulary richness metrics
2. Add regional cost comparisons
3. Develop predictive model for plan complexity scoring
*/


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:39:10.233153
    - Additional Notes: Provides a comprehensive diagnostic of Medicare prescription drug plan complexity, focusing on network, financial, and geographic variations across different plan types and special needs categories.
    
    */