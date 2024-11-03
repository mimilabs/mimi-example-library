-- MEPS Telehealth Adoption and Payment Analysis 2019-2022
--
-- Business Purpose:
-- This analysis examines the growth of telehealth services and associated payment patterns to help:
-- 1. Track telehealth adoption trends since 2019
-- 2. Compare reimbursement levels between telehealth and in-person visits
-- 3. Identify which specialties have most successfully integrated telehealth
-- 4. Support strategic planning for virtual care initiatives

-- Main Query
WITH visit_payments AS (
    SELECT 
        obdateyr as visit_year,
        telehealthflag,
        drsplty as provider_specialty,
        COUNT(*) as visit_count,
        AVG(obxp_yy_x) as avg_total_payment,
        AVG(obpv_yy_x) as avg_private_insurance_payment,
        AVG(obmr_yy_x) as avg_medicare_payment
    FROM mimi_ws_1.ahrq.meps_event_officevisits
    WHERE obdateyr >= 2019  -- Focus on 2019+ to capture pre/post COVID trends
    AND obdateyr <= 2022    -- Latest available year
    AND obxp_yy_x > 0       -- Only include visits with valid payment data
    GROUP BY 1,2,3
)

SELECT 
    visit_year,
    telehealthflag,
    provider_specialty,
    visit_count,
    ROUND(avg_total_payment,2) as avg_total_payment,
    ROUND(avg_private_insurance_payment,2) as avg_private_insurance,
    ROUND(avg_medicare_payment,2) as avg_medicare,
    ROUND(100.0 * visit_count / SUM(visit_count) OVER (PARTITION BY visit_year),2) as pct_of_year_visits
FROM visit_payments
WHERE visit_count >= 30  -- Filter for statistical significance
ORDER BY visit_year DESC, visit_count DESC;

-- Query Documentation:
--
-- How it works:
-- 1. Creates a CTE to aggregate visit counts and payment metrics by year, telehealth status, and specialty
-- 2. Calculates average payments from different payer sources
-- 3. Computes the percentage distribution of visits within each year
-- 4. Filters for specialties with significant volume to ensure reliable insights
--
-- Assumptions and Limitations:
-- - Relies on accurate telehealth flagging in the source data
-- - Payment amounts are normalized across years (no inflation adjustment)
-- - Minimum threshold of 30 visits may exclude some emerging specialties
-- - Limited to direct visit payments (excludes associated services)
--
-- Possible Extensions:
-- 1. Add geographic analysis by incorporating regional indicators
-- 2. Include patient demographics to identify telehealth adoption patterns
-- 3. Analyze conversion patterns between in-person and telehealth visits
-- 4. Compare quality metrics between telehealth and traditional visits
-- 5. Segment analysis by urban/rural status to identify access patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:21:54.254208
    - Additional Notes: Query focuses on post-2019 data to capture COVID-19 impact on telehealth adoption. Payment analysis requires valid payment data (obxp_yy_x > 0) and minimum visit threshold (30) for statistical validity. Consider local regulations and reimbursement policies when interpreting results across different regions.
    
    */