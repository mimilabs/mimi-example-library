-- Transportation Benefit Waiver Analysis for Hospital Admissions
--
-- Business Purpose:
-- Analyzes waiver patterns of ambulance copayments/coinsurance when patients are admitted 
-- to hospitals, helping identify plans that reduce financial barriers for emergency care
-- and potentially improve health outcomes through earlier hospital admissions.

WITH benefit_summary AS (
    -- Get core ambulance benefit waiver information
    SELECT 
        pbp_a_plan_type,
        pbp_b10a_copay_wav_yn AS copay_waived,
        pbp_b10a_coins_wav_yn AS coins_waived,
        pbp_b10a_copay_yn AS has_copay,
        pbp_b10a_coins_yn AS has_coins,
        mimi_src_file_date,
        COUNT(*) AS plan_count
    FROM mimi_ws_1.partcd.pbp_b10_amb_trans
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.pbp_b10_amb_trans)
    GROUP BY 1,2,3,4,5,6
)

SELECT
    pbp_a_plan_type AS plan_type,
    ROUND(SUM(CASE WHEN copay_waived = 'Y' AND has_copay = 'Y' 
              THEN plan_count ELSE 0 END) * 100.0 / 
          SUM(CASE WHEN has_copay = 'Y' 
              THEN plan_count ELSE 0 END), 1) AS pct_plans_waiving_copay,
    ROUND(SUM(CASE WHEN coins_waived = 'Y' AND has_coins = 'Y' 
              THEN plan_count ELSE 0 END) * 100.0 / 
          SUM(CASE WHEN has_coins = 'Y' 
              THEN plan_count ELSE 0 END), 1) AS pct_plans_waiving_coins,
    SUM(plan_count) AS total_plans,
    mimi_src_file_date AS data_date
FROM benefit_summary
GROUP BY pbp_a_plan_type, mimi_src_file_date
HAVING total_plans >= 10
ORDER BY total_plans DESC;

-- How this works:
-- 1. Creates a CTE to aggregate core waiver metrics at plan type level
-- 2. Calculates percentage of plans waiving copays and coinsurance when admitted
-- 3. Only includes plan types with at least 10 plans for statistical relevance
-- 4. Uses most recent data snapshot available

-- Assumptions & Limitations:
-- - Assumes waiver patterns are consistent throughout the year
-- - Limited to plans that have copays/coinsurance to begin with
-- - Does not account for partial waivers or special conditions
-- - Data represents plan design, not actual utilization

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Compare waiver rates against plan premiums or star ratings
-- 3. Include geographic analysis by state/region
-- 4. Correlate with hospital admission rates if available
-- 5. Analyze impact on total cost of care

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:00:47.987103
    - Additional Notes: Query focuses specifically on hospital admission waivers for ambulance services and requires at least 10 plans per plan type for meaningful analysis. Results are most meaningful when comparing across different plan types within the same time period.
    
    */