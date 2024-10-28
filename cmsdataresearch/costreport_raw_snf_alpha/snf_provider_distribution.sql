
/* 
SNF Cost Report Analysis - Basic Provider Information 
===================================================

Business Purpose:
---------------
This query extracts key provider information from SNF cost reports to understand:
- Provider locations and characteristics 
- Facility types and ownership models
- Basic operating statistics

This serves as a foundation for analyzing SNF cost structures and operations.
*/

WITH provider_info AS (
  -- Get latest provider details from worksheet S-2 
  SELECT DISTINCT 
    rpt_rec_num,
    -- Extract provider name from line 1
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00101' AND clmn_num = '0100' 
        THEN itm_alphnmrc_itm_txt END) AS provider_name,
    -- Get address from lines 2-4
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00102' AND clmn_num = '0100'
        THEN itm_alphnmrc_itm_txt END) AS street_address,
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00103' AND clmn_num = '0100'
        THEN itm_alphnmrc_itm_txt END) AS city,
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00104' AND clmn_num = '0100'
        THEN itm_alphnmrc_itm_txt END) AS state,
    -- Get facility type from line 19
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00119' AND clmn_num = '0100'
        THEN itm_alphnmrc_itm_txt END) AS facility_type,
    -- Get fiscal year end date
    MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '00118' AND clmn_num = '0100'
        THEN itm_alphnmrc_itm_txt END) AS fiscal_year_end
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
  WHERE wksht_cd = 'S200001'
  GROUP BY rpt_rec_num
)

-- Main query that summarizes provider distribution
SELECT 
  state,
  facility_type,
  COUNT(*) as provider_count,
  -- Fiscal year distribution
  COUNT(DISTINCT fiscal_year_end) as distinct_fiscal_years
FROM provider_info
WHERE state IS NOT NULL
GROUP BY state, facility_type
ORDER BY state, provider_count DESC;

/*
How this works:
--------------
1. CTE extracts key provider information from worksheet S-2 using CASE statements
2. Groups data by report record number to get one row per provider
3. Main query aggregates by state and facility type to show distribution

Assumptions & Limitations:
------------------------
- Uses only worksheet S-2 data which contains provider characteristics
- Assumes data quality in provider reported information
- Limited to basic demographic analysis

Possible Extensions:
------------------
1. Add financial metrics from other worksheets
2. Include trend analysis across multiple years
3. Add geographic analysis using city/state data
4. Compare metrics across different facility types
5. Join with other CMS data sources for quality metrics
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:32:19.251797
    - Additional Notes: Query focuses on provider demographics from worksheet S-2 only. Consider adding fiscal_year as a filter parameter if analyzing specific time periods. Data completeness depends on accurate provider reporting in worksheet S-2, particularly for state and facility type fields.
    
    */