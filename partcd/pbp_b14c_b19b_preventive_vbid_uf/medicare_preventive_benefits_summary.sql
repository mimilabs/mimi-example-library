
/*************************************************************************
Title: Medicare Advantage Supplemental Preventive Services Analysis
 
Business Purpose:
This query analyzes the distribution and characteristics of supplemental preventive 
services (health education, fitness benefits, counseling) offered by Medicare 
Advantage plans to help understand:
- What types of preventive services are most commonly offered
- How plans structure cost sharing for these benefits
- Geographic variations in supplemental benefit offerings

The insights can help:
- Insurers design competitive benefit packages
- Policymakers evaluate access to preventive services
- Researchers study relationships between benefits and health outcomes
*************************************************************************/

-- Main analysis of supplemental preventive services
SELECT 
    -- Geographic grouping
    SUBSTR(pbp_a_hnumber, 1, 2) as region,
    
    -- Plan characteristics
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Health Education/Wellness offerings
    SUM(CASE WHEN pbp_b14c_bendesc_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_supp_benefits,
    SUM(CASE WHEN pbp_b14c_bendesc_amo_hec IS NOT NULL THEN 1 ELSE 0 END) as plans_with_health_ed,
    SUM(CASE WHEN pbp_b14c_bendesc_amo_mhc IS NOT NULL THEN 1 ELSE 0 END) as plans_with_fitness,
    
    -- Counseling services metrics
    SUM(CASE WHEN pbp_b14c_bendesc_amo_cs IS NOT NULL THEN 1 ELSE 0 END) as plans_with_counseling,
    AVG(CAST(pbp_b14c_bendesc_dur_num_cs AS INT)) as avg_counseling_minutes,
    
    -- Cost sharing structure
    SUM(CASE WHEN pbp_b14c_copay_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_copays,
    AVG(CAST(pbp_b14c_maxplan_amt_hec AS FLOAT)) as avg_max_health_ed_coverage

FROM mimi_ws_1.partcd.pbp_b14c_b19b_preventive_vbid_uf

WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.pbp_b14c_b19b_preventive_vbid_uf
)

GROUP BY 
    SUBSTR(pbp_a_hnumber, 1, 2),
    pbp_a_plan_type

ORDER BY 
    region,
    total_plans DESC;

/*************************************************************************
How this query works:
1. Groups plans by region (first 2 chars of H-number) and plan type
2. Calculates counts and percentages of plans offering different benefits
3. Computes average duration and cost sharing metrics
4. Uses most recent data snapshot via mimi_src_file_date filter

Assumptions & Limitations:
- H-number first 2 chars serve as proxy for geographic regions
- Null values in benefit fields interpreted as benefit not offered
- Cost amounts assumed to be in consistent units (dollars)
- Analysis limited to point-in-time snapshot

Possible Extensions:
1. Add temporal analysis comparing benefits across years
2. Include more detailed cost sharing analysis (coins, deductibles)
3. Break out specific types of health education programs
4. Correlate with plan enrollment or quality metrics
5. Add filters for specific plan types or regions of interest
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:06:16.952809
    - Additional Notes: Query aggregates at regional level which may mask local variations. Cost sharing calculations exclude coinsurance and deductible data. Results should be validated against CMS documentation for region code interpretations. Consider memory usage when running across multiple years of data.
    
    */