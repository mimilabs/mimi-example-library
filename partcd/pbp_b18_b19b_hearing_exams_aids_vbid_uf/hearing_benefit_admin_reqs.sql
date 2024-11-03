-- hearing_benefit_utilization_requirements.sql

-- Business Purpose: 
-- Analyze authorization and referral requirements for hearing benefits across Medicare Advantage plans
-- to understand access barriers and administrative requirements that may impact member utilization.
-- This analysis helps plans optimize their benefit design and identify opportunities to improve 
-- member experience while managing appropriate utilization.

SELECT
    -- Plan identifiers
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type,
    
    -- Hearing exam requirements
    COUNT(*) as total_plans,
    
    -- Authorization patterns for exams
    SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' AND pbp_b18a_auth_yn = 'Y' THEN 1 ELSE 0 END) as exam_auth_required,
    ROUND(100.0 * SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' AND pbp_b18a_auth_yn = 'Y' THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' THEN 1 ELSE 0 END), 0), 1) as exam_auth_pct,
    
    -- Referral patterns for exams
    SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' AND pbp_b18a_refer_yn = 'Y' THEN 1 ELSE 0 END) as exam_referral_required,
    ROUND(100.0 * SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' AND pbp_b18a_refer_yn = 'Y' THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN pbp_b18a_bendesc_yn = 'Y' THEN 1 ELSE 0 END), 0), 1) as exam_referral_pct,
    
    -- Authorization patterns for hearing aids
    SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' AND pbp_b18b_auth_yn = 'Y' THEN 1 ELSE 0 END) as aid_auth_required,
    ROUND(100.0 * SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' AND pbp_b18b_auth_yn = 'Y' THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' THEN 1 ELSE 0 END), 0), 1) as aid_auth_pct,
    
    -- Referral patterns for hearing aids
    SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' AND pbp_b18b_refer_yn = 'Y' THEN 1 ELSE 0 END) as aid_referral_required,
    ROUND(100.0 * SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' AND pbp_b18b_refer_yn = 'Y' THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN pbp_b18b_bendesc_yn = 'Y' THEN 1 ELSE 0 END), 0), 1) as aid_referral_pct

FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf

-- Get latest data version
WHERE version = (SELECT MAX(version) 
                FROM mimi_ws_1.partcd.pbp_b18_b19b_hearing_exams_aids_vbid_uf)

GROUP BY 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    pbp_a_plan_type

ORDER BY 
    total_plans DESC,
    pbp_a_hnumber;

-- How this works:
-- 1. Identifies plans offering hearing exams and hearing aids
-- 2. Calculates the percentage of plans requiring authorization/referral for each benefit
-- 3. Groups results by plan identifiers to show variations across plan types
-- 4. Uses the latest version of benefit data for current analysis

-- Assumptions and Limitations:
-- - Analysis assumes authorization/referral requirements are consistently coded
-- - Does not account for potential variations in requirements by provider type
-- - Limited to point-in-time analysis based on latest version
-- - Does not consider impact of VBID modifications on requirements

-- Possible Extensions:
-- 1. Add trend analysis over multiple versions/years
-- 2. Include geographic analysis by state/region
-- 3. Correlate requirements with plan star ratings
-- 4. Compare requirements across different organization types
-- 5. Analyze relationship between utilization management and benefit generosity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:34:11.137884
    - Additional Notes: Query focuses on administrative requirements that could impact benefit access and utilization. Note that percentages are calculated only for plans offering the specific benefit (exam or hearing aid) to avoid skewed metrics from non-offering plans. The results can help identify potential barriers to care and opportunities for streamlining benefit administration.
    
    */