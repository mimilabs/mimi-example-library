/* SNF Staffing Analysis - Nurse Coverage and Services
==================================================

Business Purpose:
---------------
This query analyzes nursing staffing ratios and service coverage from SNF cost reports to understand:
- Full-time equivalent (FTE) staffing levels for different nursing roles
- Distribution of nursing hours across direct patient care
- Identification of facilities with potential staffing challenges

This provides critical insights for:
1. Workforce planning and optimization
2. Quality of care assessment
3. Operational efficiency benchmarking
4. Regulatory compliance monitoring */

WITH nursing_staff AS (
    -- Extract nursing staff FTEs from Worksheet S-3 Part II
    SELECT 
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S300002' AND line_num = '1' THEN itm_alphnmrc_itm_txt END) as facility_name,
        MAX(CASE WHEN wksht_cd = 'S300002' AND line_num = '3' THEN itm_alphnmrc_itm_txt END) as rn_ftes,
        MAX(CASE WHEN wksht_cd = 'S300002' AND line_num = '4' THEN itm_alphnmrc_itm_txt END) as lpn_ftes,
        MAX(CASE WHEN wksht_cd = 'S300002' AND line_num = '5' THEN itm_alphnmrc_itm_txt END) as nurse_aide_ftes
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S300002' 
    AND line_num IN ('1','3','4','5')
    GROUP BY rpt_rec_num
),

facility_details AS (
    -- Get facility characteristics from Worksheet S-2
    SELECT DISTINCT
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '1' THEN itm_alphnmrc_itm_txt END) as provider_number,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = '4' THEN itm_alphnmrc_itm_txt END) as bed_count
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S200001'
    AND line_num IN ('1','4')
    GROUP BY rpt_rec_num
)

SELECT 
    n.facility_name,
    f.provider_number,
    f.bed_count,
    n.rn_ftes,
    n.lpn_ftes,
    n.nurse_aide_ftes,
    -- Calculate total nursing staff
    CAST(n.rn_ftes AS FLOAT) + CAST(n.lpn_ftes AS FLOAT) + CAST(n.nurse_aide_ftes AS FLOAT) as total_nursing_ftes,
    -- Calculate staffing ratios
    CAST(n.rn_ftes AS FLOAT) / NULLIF(CAST(f.bed_count AS FLOAT), 0) as rn_per_bed,
    CAST(n.nurse_aide_ftes AS FLOAT) / NULLIF(CAST(f.bed_count AS FLOAT), 0) as aide_per_bed
FROM nursing_staff n
JOIN facility_details f ON n.rpt_rec_num = f.rpt_rec_num
WHERE f.bed_count > 0
ORDER BY total_nursing_ftes DESC;

/* How this query works:
----------------------
1. First CTE extracts nursing staff FTEs from Worksheet S-3
2. Second CTE pulls facility characteristics from Worksheet S-2
3. Main query joins these together and calculates key staffing ratios
4. Results show staffing levels normalized by facility size

Assumptions and Limitations:
-------------------------
- Assumes accurate reporting of FTE counts
- Limited to facilities with valid bed counts
- Does not account for temporary or contract staff
- May not reflect seasonal staffing variations

Possible Extensions:
------------------
1. Add geographic analysis by including facility location
2. Compare staffing levels against quality metrics
3. Analyze staffing trends over time using mimi_src_file_date
4. Include salary and wage information for cost analysis
5. Segment analysis by facility type or ownership structure */

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:15:33.547677
    - Additional Notes: Query calculates core staffing ratios (RN/bed, aide/bed) from CMS cost report data. Note that FTE values are stored as text in the alpha table and require casting to numeric for calculations. Some facilities may show null ratios if bed count is zero or FTE data is missing.
    
    */