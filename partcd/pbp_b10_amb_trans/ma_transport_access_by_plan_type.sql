-- Non-Emergency Transportation Utilization and Access Analysis
-- 
-- Business Purpose:
-- Analyze the supplemental transportation benefit offerings across Medicare Advantage plans
-- to identify access patterns, coverage limitations, and potential gaps in non-emergency
-- transportation services. This helps:
-- 1. Healthcare consultants evaluate market opportunities
-- 2. Plan administrators benchmark their offerings
-- 3. Policy makers understand transportation access disparities

SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Transportation benefit offering analysis
    SUM(CASE WHEN pbp_b10b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_transport,
    ROUND(100.0 * SUM(CASE WHEN pbp_b10b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) / 
          COUNT(DISTINCT bid_id), 1) as pct_with_transport,
    
    -- Trip limit analysis
    SUM(CASE WHEN pbp_b10b_bendesc_lim_pal = 'N' THEN 1 ELSE 0 END) as plans_with_trip_limits,
    AVG(CASE WHEN pbp_b10b_bendesc_lim_pal = 'N' THEN CAST(pbp_b10b_bendesc_amt_pal AS INT) END) as avg_trips_when_limited,
    
    -- Cost sharing analysis
    SUM(CASE WHEN pbp_b10b_copay_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_copay,
    AVG(CASE WHEN pbp_b10b_copay_yn = 'Y' THEN pbp_b10b_copay_amt_max END) as avg_max_copay,
    
    -- Authorization requirements
    SUM(CASE WHEN pbp_b10b_auth_yn = 'Y' THEN 1 ELSE 0 END) as plans_require_auth,
    ROUND(100.0 * SUM(CASE WHEN pbp_b10b_auth_yn = 'Y' THEN 1 ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN pbp_b10b_bendesc_yn = 'Y' THEN 1 ELSE 0 END), 0), 1) as pct_requiring_auth

FROM mimi_ws_1.partcd.pbp_b10_amb_trans

-- Focus on most recent data
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.partcd.pbp_b10_amb_trans)

GROUP BY pbp_a_plan_type
HAVING total_plans >= 10  -- Filter out rare plan types
ORDER BY total_plans DESC;

-- How this works:
-- 1. Groups data by plan type to enable comparison across different MA plan structures
-- 2. Calculates key metrics around transportation benefit offerings and restrictions
-- 3. Focuses on most recent data to provide current market view
-- 4. Uses CASE statements to handle conditional counting and averages
-- 5. Includes percentage calculations for easier interpretation

-- Assumptions and Limitations:
-- 1. Assumes current year data is most representative of market conditions
-- 2. Limited to plan-level analysis; no member utilization data
-- 3. Doesn't account for mid-year benefit changes
-- 4. Small plan types are filtered out to focus on major market segments

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include trend analysis across multiple years
-- 3. Cross-reference with plan star ratings
-- 4. Add analysis of different transportation modes offered
-- 5. Compare supplemental transport benefits with other supplemental offerings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:15:12.405473
    - Additional Notes: Query focuses specifically on plan-type level statistics for non-emergency transportation benefits, with emphasis on access metrics like authorization requirements and trip limits. Consider adding WHERE clauses to filter specific plan types if analysis needs to be more targeted.
    
    */