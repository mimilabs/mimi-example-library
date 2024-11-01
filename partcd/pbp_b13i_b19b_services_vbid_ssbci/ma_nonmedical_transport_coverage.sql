-- Medicare Advantage Non-Medical Transportation Benefit Analysis
-- 
-- This query analyzes the transportation for non-medical needs benefit offered by Medicare Advantage
-- plans, including coverage patterns, service types, and authorization requirements. Understanding
-- these benefits is crucial for evaluating plan support for social determinants of health and
-- access to community resources.

WITH transport_coverage AS (
    -- Get base plan info and transportation benefit details
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        pbp_a_plan_type,
        pbp_a_ben_cov,
        pbp_b13i_t_bendesc_yn AS offers_transport,
        pbp_b13i_t_bendesc_trn AS enhanced_transport,
        pbp_b13i_t_bendesc_amt_pal AS num_trips_plan_approved,
        pbp_b13i_t_bendesc_amt_al AS num_trips_any_location,
        pbp_b13i_t_maxplan_amt AS max_benefit_amount,
        pbp_b13i_t_auth_yn AS requires_auth,
        pbp_b13i_t_refer_yn AS requires_referral,
        mimi_src_file_date
    FROM mimi_ws_1.partcd.pbp_b13i_b19b_services_vbid_ssbci
    WHERE pbp_b13i_t_bendesc_yn = 'Y'  -- Only plans offering transportation benefit
)

SELECT 
    -- Calculate summary metrics
    mimi_src_file_date AS report_date,
    COUNT(DISTINCT pbp_a_hnumber) AS num_organizations,
    COUNT(DISTINCT CONCAT(pbp_a_hnumber, pbp_a_plan_identifier)) AS num_plans,
    
    -- Analyze coverage patterns
    AVG(CAST(num_trips_plan_approved AS INT)) AS avg_trips_plan_approved,
    AVG(CAST(num_trips_any_location AS INT)) AS avg_trips_any_location,
    AVG(CAST(max_benefit_amount AS FLOAT)) AS avg_max_benefit,
    
    -- Calculate authorization requirements
    ROUND(100.0 * SUM(CASE WHEN requires_auth = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        AS pct_requiring_auth,
    ROUND(100.0 * SUM(CASE WHEN requires_referral = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        AS pct_requiring_referral,
        
    -- Enhanced benefit analysis    
    ROUND(100.0 * SUM(CASE WHEN enhanced_transport = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        AS pct_enhanced_benefit
        
FROM transport_coverage
GROUP BY mimi_src_file_date
ORDER BY mimi_src_file_date;

-- How this query works:
-- 1. Creates a CTE filtering to plans offering non-medical transportation
-- 2. Calculates key metrics around coverage, trip limits, and requirements
-- 3. Aggregates results by report date to show trends
--
-- Assumptions and limitations:
-- - Assumes numerical fields contain valid numbers
-- - Does not account for mid-year benefit changes
-- - Cannot determine actual utilization of benefits
-- 
-- Possible extensions:
-- - Add geographic analysis by state/region
-- - Compare against plan star ratings
-- - Analyze correlation with other supplemental benefits
-- - Break down by plan type (MA vs SNP)
-- - Include cost sharing analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:21:36.632332
    - Additional Notes: Query focuses specifically on non-medical transportation benefits in Medicare Advantage plans, analyzing coverage patterns, authorization requirements, and enhanced benefits across organizations. Note that trip counts and benefit amounts may need validation as data types are converted from string fields.
    
    */