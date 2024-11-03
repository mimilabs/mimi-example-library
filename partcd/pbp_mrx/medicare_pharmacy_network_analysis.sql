-- medicare_drug_plan_network_access.sql

-- Business Purpose:
-- Analyze Medicare Part D pharmacy network configurations and access points across plans
-- This analysis helps:
-- 1. Understand pharmacy network strategies across plans
-- 2. Identify plans with comprehensive access through multiple pharmacy types
-- 3. Assess mail order and retail pharmacy availability
-- 4. Support network adequacy evaluation

SELECT 
    -- Plan identifiers
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    
    -- Network components
    mrx_partd_network_loc as network_type,
    
    -- Supply access points
    CASE WHEN mrx_gen_loc_rstd IS NOT NULL THEN 1 ELSE 0 END as has_retail_standard,
    CASE WHEN mrx_gen_loc_mostd IS NOT NULL THEN 1 ELSE 0 END as has_mail_order,
    CASE WHEN mrx_gen_loc_ltc IS NOT NULL THEN 1 ELSE 0 END as has_long_term_care,
    CASE WHEN mrx_gen_loc_oon IS NOT NULL THEN 1 ELSE 0 END as has_out_of_network,
    
    -- Supply duration options
    mrx_gen_rstd_1m as retail_1month_days,
    mrx_gen_rstd_3m as retail_3month_days,
    mrx_gen_mostd_3m as mail_order_3month_days,
    
    -- Network features
    mrx_first_fill as offers_free_first_fill,
    mrx_nat_rx_cov_yn as has_national_coverage,
    
    COUNT(*) as plan_count

FROM mimi_ws_1.partcd.pbp_mrx

WHERE mrx_drug_ben_yn = 'Y' -- Only include plans with drug benefits
  AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.partcd.pbp_mrx)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12

-- Key network indicators
HAVING COUNT(*) > 0

ORDER BY plan_count DESC

-- Query Operation:
-- 1. Focuses on current pharmacy network configurations using latest data
-- 2. Identifies key access points: retail, mail-order, LTC, out-of-network
-- 3. Shows supply duration options for different pharmacy types
-- 4. Highlights additional network features like free first fill and national coverage
-- 5. Aggregates at plan level to show network patterns

-- Assumptions and Limitations:
-- 1. All plans in analysis offer Part D benefits (filtered by mrx_drug_ben_yn = 'Y')
-- 2. Using most recent data snapshot
-- 3. Does not include cost sharing details
-- 4. Network presence is binary (has/doesn't have) without detail on network size

-- Possible Extensions:
-- 1. Add geographical analysis by linking to plan service area data
-- 2. Include cost sharing variations across pharmacy types
-- 3. Analyze trends in network configurations over time
-- 4. Compare network breadth with plan enrollment or market share
-- 5. Add specialty pharmacy network analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:12:36.432590
    - Additional Notes: The query focuses on pharmacy network characteristics across Medicare Part D plans, including retail, mail-order, and long-term care access points. Note that presence/absence of network types is tracked but not network size or geographic distribution. Results are filtered to most recent data snapshot only.
    
    */