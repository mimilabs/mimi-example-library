/* SNF Facility Management Analysis - Bed Capacity and Services
==================================================

Business Purpose:
---------------
This query analyzes key facility management aspects from SNF cost reports to understand:
- Licensed bed capacity
- Available service types
- Service availability by facility
- Geographic coverage of specialized services

The insights help identify:
1. Service coverage gaps
2. Capacity utilization opportunities
3. Market expansion potential
4. Service line development needs */

WITH facility_data AS (
    -- Extract facility bed counts and service indicators
    SELECT 
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S-2' AND line_num = 1 AND clmn_num = 1 
            THEN itm_alphnmrc_itm_txt END) as facility_name,
        MAX(CASE WHEN wksht_cd = 'S-2' AND line_num = 1 AND clmn_num = 2 
            THEN itm_alphnmrc_itm_txt END) as facility_address,
        MAX(CASE WHEN wksht_cd = 'S-3' AND line_num = 1 AND clmn_num = 1 
            THEN itm_alphnmrc_itm_txt END) as licensed_beds,
        MAX(CASE WHEN wksht_cd = 'S-3' AND line_num = 2 AND clmn_num = 1 
            THEN itm_alphnmrc_itm_txt END) as certified_beds,
        MAX(CASE WHEN wksht_cd = 'S-7' AND line_num = 1 
            THEN itm_alphnmrc_itm_txt END) as rehabilitation_services,
        MAX(CASE WHEN wksht_cd = 'S-7' AND line_num = 2 
            THEN itm_alphnmrc_itm_txt END) as respiratory_therapy,
        MAX(CASE WHEN wksht_cd = 'S-7' AND line_num = 3 
            THEN itm_alphnmrc_itm_txt END) as specialized_care
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE mimi_src_file_date >= '2022-01-01'  -- Focus on recent data
    GROUP BY rpt_rec_num
)

SELECT 
    COUNT(DISTINCT rpt_rec_num) as total_facilities,
    COUNT(CASE WHEN rehabilitation_services = 'Y' THEN 1 END) as rehab_facilities,
    COUNT(CASE WHEN respiratory_therapy = 'Y' THEN 1 END) as respiratory_facilities,
    COUNT(CASE WHEN specialized_care = 'Y' THEN 1 END) as specialized_care_facilities,
    AVG(CAST(licensed_beds as INT)) as avg_licensed_beds,
    AVG(CAST(certified_beds as INT)) as avg_certified_beds,
    -- Calculate service availability percentages
    ROUND(100.0 * COUNT(CASE WHEN rehabilitation_services = 'Y' THEN 1 END) / 
          COUNT(DISTINCT rpt_rec_num), 2) as pct_with_rehab,
    ROUND(100.0 * COUNT(CASE WHEN respiratory_therapy = 'Y' THEN 1 END) / 
          COUNT(DISTINCT rpt_rec_num), 2) as pct_with_respiratory,
    ROUND(100.0 * COUNT(CASE WHEN specialized_care = 'Y' THEN 1 END) / 
          COUNT(DISTINCT rpt_rec_num), 2) as pct_with_specialized
FROM facility_data;

/* How this query works:
----------------------
1. Creates a CTE to extract and pivot key facility attributes
2. Aggregates data to calculate facility counts and averages
3. Computes service availability percentages
4. Focuses on most recent year to reflect current market state

Assumptions and Limitations:
--------------------------
- Assumes Y/N indicators in service fields
- Relies on accurate reporting of bed counts
- May not capture all specialty services
- Geographic analysis limited by available fields

Possible Extensions:
------------------
1. Add geographic grouping for regional analysis
2. Trend analysis across multiple years
3. Correlation analysis between bed capacity and services
4. Service combination analysis
5. Market saturation analysis by region
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:07:19.863177
    - Additional Notes: Query focuses on current year facility management metrics and service availability rates. Does not include patient volume or financial metrics. Bed count conversions assume valid numeric data in alphanumeric fields. Consider adding error handling for non-numeric bed count values in production use.
    
    */