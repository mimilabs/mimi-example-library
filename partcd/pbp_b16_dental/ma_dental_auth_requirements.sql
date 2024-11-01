-- Medicare Advantage Dental Service Authorization Requirements Analysis
-- Business Purpose: Analyze authorization and referral requirements for dental services 
-- across MA plans to understand access barriers and administrative burden on providers.
-- This helps inform provider network strategy, administrative simplification opportunities,
-- and member experience initiatives.

WITH dental_auth_reqs AS (
  SELECT 
    pbp_a_plan_type,
    orgtype,
    -- Preventive services auth flags
    pbp_b16b_auth_oe_yn AS oral_exam_auth_req,
    pbp_b16b_auth_dx_yn AS xray_auth_req, 
    pbp_b16b_auth_pc_yn AS cleaning_auth_req,
    
    -- Comprehensive services auth flags
    pbp_b16c_auth_rs_yn AS restorative_auth_req,
    pbp_b16c_auth_end_yn AS endodontics_auth_req,
    pbp_b16c_auth_peri_yn AS periodontics_auth_req,
    
    -- Referral requirements
    pbp_b16b_refer_oe_yn AS oral_exam_referral_req,
    pbp_b16c_refer_rs_yn AS restorative_referral_req,
    pbp_b16c_refer_peri_yn AS periodontics_referral_req
    
  FROM mimi_ws_1.partcd.pbp_b16_dental
)

SELECT
  pbp_a_plan_type as plan_type,
  orgtype as organization_type,
  
  -- Calculate % of plans requiring auth for preventive services
  ROUND(AVG(CASE WHEN oral_exam_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_oral_exam_auth,
  ROUND(AVG(CASE WHEN xray_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_xray_auth,
  ROUND(AVG(CASE WHEN cleaning_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_cleaning_auth,

  -- Calculate % of plans requiring auth for major services  
  ROUND(AVG(CASE WHEN restorative_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_restorative_auth,
  ROUND(AVG(CASE WHEN endodontics_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_endo_auth,
  ROUND(AVG(CASE WHEN periodontics_auth_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_perio_auth,
  
  -- Calculate % requiring referrals
  ROUND(AVG(CASE WHEN oral_exam_referral_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_exam_referral,
  ROUND(AVG(CASE WHEN restorative_referral_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_restorative_referral,
  ROUND(AVG(CASE WHEN periodontics_referral_req = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_require_perio_referral,
  
  COUNT(*) as total_plans

FROM dental_auth_reqs
GROUP BY 1,2
HAVING COUNT(*) >= 10 -- Only include plan types with meaningful sample sizes
ORDER BY total_plans DESC

/* How the Query Works:
1. Creates CTE to extract relevant authorization and referral requirement fields
2. Calculates percentages of plans requiring auth/referral for different service types
3. Groups by plan and organization type
4. Filters for statistically meaningful samples
5. Orders by plan volume

Assumptions & Limitations:
- Y/N fields accurately reflect auth/referral requirements
- Sample size filter of 10+ plans may exclude some niche plan types
- Does not account for potential regional variations
- Authorization requirements may vary by specific procedure codes

Possible Extensions:
1. Add temporal analysis to track auth requirement trends over time
2. Include geographic analysis of requirements by state/region
3. Correlate auth requirements with utilization or network adequacy metrics
4. Compare auth requirements against quality metrics or member satisfaction
5. Analyze relationship between auth requirements and plan premiums/star ratings
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:48:05.570422
    - Additional Notes: Query focuses on authorization and referral patterns across different dental service types. Consider memory usage when running across multiple years of data due to the wide table structure. The 10+ plans filter may need adjustment based on specific analysis needs.
    
    */