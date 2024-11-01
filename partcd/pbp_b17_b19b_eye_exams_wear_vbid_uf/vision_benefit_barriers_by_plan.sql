-- medicare_advantage_vision_benefit_restrictions.sql
-- Purpose: Analyze authorization and referral requirements for vision benefits to understand access barriers
-- Business Value: Identify plans with potential administrative barriers to vision care access,
--               which can impact member satisfaction and utilization of preventive eye care services

WITH vision_requirements AS (
    -- Combine eye exam and eyewear authorization/referral requirements
    SELECT 
        pbp_a_hnumber,
        pbp_a_plan_identifier,
        pbp_a_plan_type,
        pbp_b17a_bendesc_yn AS offers_eye_exams,
        pbp_b17b_bendesc_yn AS offers_eyewear,
        pbp_b17a_auth_yn AS exam_requires_auth,
        pbp_b17a_refer_yn AS exam_requires_referral,
        pbp_b17b_auth_yn AS eyewear_requires_auth,
        pbp_b17b_refer_yn AS eyewear_requires_referral,
        mimi_src_file_date
    FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf)
)

SELECT 
    pbp_a_plan_type,
    COUNT(*) as total_plans,
    
    -- Calculate percentage of plans requiring authorizations
    ROUND(100.0 * SUM(CASE WHEN exam_requires_auth = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_requiring_exam_auth,
    ROUND(100.0 * SUM(CASE WHEN eyewear_requires_auth = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_requiring_eyewear_auth,
    
    -- Calculate percentage of plans requiring referrals
    ROUND(100.0 * SUM(CASE WHEN exam_requires_referral = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_requiring_exam_referral,
    ROUND(100.0 * SUM(CASE WHEN eyewear_requires_referral = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_requiring_eyewear_referral,
        
    -- Calculate percentage of plans with both requirements
    ROUND(100.0 * SUM(CASE WHEN exam_requires_auth = 'Y' AND exam_requires_referral = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) 
        as pct_requiring_both_for_exams
FROM vision_requirements
WHERE offers_eye_exams = 'Y' 
  AND offers_eyewear = 'Y'
GROUP BY pbp_a_plan_type
ORDER BY total_plans DESC;

-- How this query works:
-- 1. Creates a CTE to extract relevant authorization and referral requirements
-- 2. Filters for most recent data period
-- 3. Calculates percentages of plans with various requirements by plan type
-- 4. Only includes plans that offer both eye exams and eyewear benefits

-- Assumptions and limitations:
-- - Assumes 'Y'/'N' values in authorization/referral fields
-- - Limited to plans offering both exam and eyewear benefits
-- - Does not consider changes in requirements over time
-- - Does not account for variations in authorization processes

-- Possible extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare requirements across different organization types
-- 3. Analyze correlation with plan premiums or star ratings
-- 4. Track changes in requirements over multiple quarters
-- 5. Include analysis of specific eyewear benefit restrictions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:12:57.675412
    - Additional Notes: Query focuses specifically on administrative barriers (auth/referral requirements) across Medicare Advantage plan types. Results are percentage-based for easy comparison, but raw counts could be added if needed for volume analysis. Consider adding error handling for cases where authorization/referral fields contain unexpected values.
    
    */