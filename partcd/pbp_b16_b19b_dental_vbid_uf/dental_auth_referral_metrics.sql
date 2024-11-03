-- dental_access_network_requirements.sql

-- Business Purpose:
-- Analyze dental benefit access requirements across Medicare Advantage plans
-- Identify patterns in authorization and referral requirements for dental services
-- Support network adequacy and care coordination planning
-- Help identify barriers to dental care access

-- Main Query
SELECT 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type,
    
    -- Preventive Services Access Requirements
    SUM(CASE WHEN pbp_b16b_auth_oe_yn = 'Y' THEN 1 ELSE 0 END) as prev_oral_exam_auth_required,
    SUM(CASE WHEN pbp_b16b_refer_oe_yn = 'Y' THEN 1 ELSE 0 END) as prev_oral_exam_referral_required,
    SUM(CASE WHEN pbp_b16b_auth_pc_yn = 'Y' THEN 1 ELSE 0 END) as prev_cleaning_auth_required,
    SUM(CASE WHEN pbp_b16b_refer_pc_yn = 'Y' THEN 1 ELSE 0 END) as prev_cleaning_referral_required,
    
    -- Comprehensive Services Access Requirements
    SUM(CASE WHEN pbp_b16c_auth_rs_yn = 'Y' THEN 1 ELSE 0 END) as comp_restorative_auth_required,
    SUM(CASE WHEN pbp_b16c_refer_rs_yn = 'Y' THEN 1 ELSE 0 END) as comp_restorative_referral_required,
    SUM(CASE WHEN pbp_b16c_auth_end_yn = 'Y' THEN 1 ELSE 0 END) as comp_endodontics_auth_required,
    SUM(CASE WHEN pbp_b16c_refer_end_yn = 'Y' THEN 1 ELSE 0 END) as comp_endodontics_referral_required,
    
    -- Calculate access requirement ratios
    COUNT(*) as total_plans,
    ROUND(AVG(CASE WHEN pbp_b16b_auth_oe_yn = 'Y' THEN 1.0 ELSE 0 END) * 100, 2) as pct_plans_requiring_prev_auth,
    ROUND(AVG(CASE WHEN pbp_b16c_auth_rs_yn = 'Y' THEN 1.0 ELSE 0 END) * 100, 2) as pct_plans_requiring_comp_auth

FROM mimi_ws_1.partcd.pbp_b16_b19b_dental_vbid_uf
GROUP BY 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type
ORDER BY 
    pbp_a_hnumber,
    pbp_a_plan_identifier;

-- How this query works:
-- 1. Groups data by plan identifiers to analyze at plan level
-- 2. Counts authorization and referral requirements for key dental services
-- 3. Calculates percentages of plans requiring various access controls
-- 4. Separates analysis between preventive and comprehensive services

-- Assumptions and Limitations:
-- - Assumes Y/N indicators are consistently coded
-- - Does not account for potential regional variations
-- - Cannot determine actual impact on member access
-- - Does not consider provider network adequacy

-- Possible Extensions:
-- 1. Add geographic analysis by linking to plan service area data
-- 2. Compare access requirements across different plan types
-- 3. Analyze trends over time by incorporating historical data
-- 4. Include cost sharing analysis alongside access requirements
-- 5. Add dental provider network size correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:55:08.845841
    - Additional Notes: Query aggregates authorization and referral requirements at the plan level for both preventive and comprehensive dental services. High cardinality of group by fields may impact performance on very large datasets. Consider adding date filtering if analyzing multiple quarters.
    
    */