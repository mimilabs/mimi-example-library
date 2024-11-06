-- Medicare Part D Senior Savings Model Participation Analysis
-- 
-- Business Purpose:
-- Analyze Medicare plan participation in the Part D Senior Savings Model 
-- to assess market adoption of enhanced insulin coverage programs.
-- This analysis helps identify geographic patterns and plan types
-- that are leading the way in providing more affordable insulin coverage.

WITH participating_plans AS (
    -- Get unique plans participating in Senior Savings Model
    SELECT DISTINCT
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        pbp_a_plan_type,
        orgtype,
        part_d_enhncd_cvrg_demo
    FROM mimi_ws_1.partcd.pbp_mrx_p
    WHERE part_d_enhncd_cvrg_demo = 'Y'
),

plan_counts AS (
    -- Calculate participation metrics by organization type
    SELECT 
        orgtype,
        pbp_a_plan_type,
        COUNT(DISTINCT pbp_a_hnumber) as participating_orgs,
        COUNT(DISTINCT CONCAT(pbp_a_hnumber, pbp_a_plan_identifier)) as participating_plans
    FROM participating_plans
    GROUP BY orgtype, pbp_a_plan_type
)

SELECT
    orgtype as organization_type,
    pbp_a_plan_type as plan_type,
    participating_orgs as number_of_organizations,
    participating_plans as number_of_plans,
    ROUND(participating_plans * 100.0 / participating_orgs, 1) as avg_plans_per_org
FROM plan_counts
WHERE participating_orgs > 0
ORDER BY participating_plans DESC;

-- How this query works:
-- 1. First CTE identifies unique plans participating in Senior Savings Model
-- 2. Second CTE aggregates participation metrics by org type and plan type
-- 3. Final SELECT formats and calculates the average plans per organization
--
-- Assumptions and Limitations:
-- - Assumes part_d_enhncd_cvrg_demo = 'Y' indicates Senior Savings Model participation
-- - Limited to current snapshot, doesn't show historical adoption trends
-- - Doesn't account for market share or beneficiary enrollment numbers
--
-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare insulin tier structures between participating vs non-participating plans
-- 3. Analyze relationship between participation and plan premiums
-- 4. Track participation changes over time using historical data
-- 5. Include market penetration metrics based on enrollment data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:17:30.347799
    - Additional Notes: This analysis focuses specifically on plan participation in the Part D Senior Savings Model, which is a targeted insulin savings program. The metrics primarily show organizational adoption patterns rather than beneficiary impact or cost savings outcomes. For complete program evaluation, this query should be combined with enrollment data and cost-sharing analysis.
    
    */