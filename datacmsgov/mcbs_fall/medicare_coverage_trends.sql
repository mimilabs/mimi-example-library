-- Medicare Coverage Trends and Enrollment Patterns Analysis
-- 
-- Business Purpose:
-- This analysis examines Medicare beneficiary enrollment patterns across different coverage types
-- (Traditional Medicare vs Medicare Advantage) and supplemental coverage to identify:
-- 1. Market share trends between coverage types
-- 2. Dual eligibility rates
-- 3. Part D prescription drug coverage adoption
-- 4. Key demographic factors influencing coverage choices
--
-- This insight helps healthcare organizations understand:
-- - Medicare Advantage market penetration and growth opportunities
-- - Population segments needing specialized outreach
-- - Coverage gaps requiring intervention
-- - Strategic planning for benefit design

SELECT 
    surveyyr as year,
    
    -- Medicare Advantage vs Traditional Medicare split
    ROUND(100.0 * COUNT(CASE WHEN adm_ma_flag_yr = 3 THEN 1 END) / COUNT(*), 1) as pct_full_ma,
    ROUND(100.0 * COUNT(CASE WHEN adm_ffs_flag_yr = 3 THEN 1 END) / COUNT(*), 1) as pct_full_ffs,
    
    -- Part D and supplemental coverage
    ROUND(100.0 * COUNT(CASE WHEN adm_partd = 1 THEN 1 END) / COUNT(*), 1) as pct_part_d,
    ROUND(100.0 * COUNT(CASE WHEN ins_d_privnum = 1 THEN 1 END) / COUNT(*), 1) as pct_with_suppl,
    
    -- Dual eligibility rates
    ROUND(100.0 * COUNT(CASE WHEN adm_dual_flag_yr = 3 THEN 1 END) / COUNT(*), 1) as pct_full_dual,
    
    -- Total beneficiary count
    COUNT(*) as total_beneficiaries

FROM mimi_ws_1.datacmsgov.mcbs_fall

WHERE surveyyr BETWEEN 2017 AND 2021

GROUP BY surveyyr
ORDER BY surveyyr;

-- How this works:
-- 1. Groups data by survey year to show trends over time
-- 2. Calculates percentages for key Medicare coverage metrics
-- 3. Uses CASE statements to identify specific enrollment categories
-- 4. Rounds percentages to 1 decimal place for readability

-- Assumptions and Limitations:
-- - Survey data represents point-in-time enrollment
-- - Survey sampling methodology may impact representation
-- - Missing data handled through complete case analysis
-- - Limited to 2017-2021 timeframe

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, income, urban/rural)
-- 2. Include satisfaction metrics for different coverage types
-- 3. Analyze regional variations in coverage patterns
-- 4. Compare prescription drug coverage across plan types
-- 5. Examine health status impact on coverage choices/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:16:15.345315
    - Additional Notes: Query requires complete enrollment data for accurate trend analysis. Coverage percentages may not sum to 100% due to beneficiaries having multiple coverage types or partial-year enrollment. For state-level analysis, additional geographic filters would need to be added.
    
    */