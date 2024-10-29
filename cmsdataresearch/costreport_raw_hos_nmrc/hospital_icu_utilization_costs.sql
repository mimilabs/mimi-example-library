-- Hospital Intensive Care Unit (ICU) Utilization and Cost Analysis
-- Business Purpose: Analyze ICU capacity, utilization, and associated costs to:
-- - Support strategic planning for critical care services
-- - Evaluate ICU financial performance
-- - Guide resource allocation and capacity planning decisions

-- Main query tracking ICU bed counts, days, and costs
SELECT 
    rpt_rec_num,
    -- Get ICU bed counts from Worksheet S-3, Line 14, Column 6
    MAX(CASE WHEN wksht_cd = 'S300001' AND line_num = 14 AND clmn_num = 6 
        THEN itm_val_num ELSE 0 END) as icu_beds,
    
    -- Get ICU inpatient days from Worksheet S-3, Line 14, Column 8
    MAX(CASE WHEN wksht_cd = 'S300001' AND line_num = 14 AND clmn_num = 8 
        THEN itm_val_num ELSE 0 END) as icu_days,
    
    -- Calculate ICU direct costs from Worksheet C, Line 31, Column 1
    MAX(CASE WHEN wksht_cd = 'C000001' AND line_num = 31 AND clmn_num = 1 
        THEN itm_val_num ELSE 0 END) as icu_direct_costs,
    
    -- Get report period date indicator
    MAX(mimi_src_file_date) as report_date

FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
WHERE wksht_cd IN ('S300001', 'C000001')
  AND line_num IN (14, 31)
  AND clmn_num IN (1, 6, 8)
GROUP BY rpt_rec_num
HAVING icu_beds > 0  -- Only include hospitals with ICU units
ORDER BY icu_direct_costs DESC;

-- How this query works:
-- 1. Pulls key ICU metrics from specific worksheets:
--    - S-3: Facility statistics including beds and patient days
--    - C: Department-level direct costs
-- 2. Uses CASE statements to pivot the data from long to wide format
-- 3. Groups by report number to get one row per hospital
-- 4. Filters for hospitals with ICU beds

-- Assumptions and Limitations:
-- - Assumes consistent reporting of ICU statistics across hospitals
-- - Limited to direct costs, doesn't include allocated overhead
-- - May not capture all ICU types (e.g., Medical vs. Surgical ICU)
-- - Data quality depends on accurate hospital reporting

-- Possible Extensions:
-- 1. Add occupancy rate calculations (ICU days / (ICU beds * 365))
-- 2. Include other critical care units (CCU, NICU, etc.)
-- 3. Calculate cost per ICU day
-- 4. Add geographical analysis by joining with provider information
-- 5. Trend analysis across multiple reporting periods
-- 6. Compare ICU metrics against hospital size or teaching status

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:20:30.097879
    - Additional Notes: Query focuses on core ICU metrics from CMS cost reports by combining facility statistics (beds/days) with direct costs. Results are limited to hospitals reporting ICU operations and may need adjustment based on specific ICU department codes used by different facilities. Verify worksheet/line/column mappings against current CMS reporting standards before using in production.
    
    */