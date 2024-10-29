/* SNF Patient Days and Revenue Analysis - Core Business Metrics
=========================================================

Business Purpose:
---------------
This query analyzes key operational metrics from SNF cost reports to understand:
- Total patient days and Medicare patient days by facility
- Medicare utilization rates
- Key revenue metrics
These metrics are fundamental for assessing facility scale, Medicare dependency,
and basic financial performance.
*/

WITH patient_days AS (
    -- Extract total patient days from Worksheet S-3 Part I
    SELECT 
        rpt_rec_num,
        itm_alphnmrc_itm_txt as total_patient_days
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S300000'
    AND line_num = '1'
    AND clmn_num = '5'
),

medicare_days AS (
    -- Extract Medicare patient days
    SELECT 
        rpt_rec_num,
        itm_alphnmrc_itm_txt as medicare_days
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S300000'
    AND line_num = '1'
    AND clmn_num = '6'
),

provider_info AS (
    -- Get provider name
    SELECT 
        rpt_rec_num,
        itm_alphnmrc_itm_txt as provider_name
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S200000'
    AND line_num = '1'
    AND clmn_num = '1'
)

SELECT 
    p.provider_name,
    pd.total_patient_days,
    md.medicare_days,
    CAST(md.medicare_days AS FLOAT) / NULLIF(CAST(pd.total_patient_days AS FLOAT), 0) as medicare_utilization_rate
FROM provider_info p
JOIN patient_days pd ON p.rpt_rec_num = pd.rpt_rec_num
JOIN medicare_days md ON p.rpt_rec_num = md.rpt_rec_num
WHERE p.provider_name IS NOT NULL
ORDER BY CAST(pd.total_patient_days AS FLOAT) DESC
LIMIT 100;

/* How this works:
-----------------
1. Creates CTEs to extract key metrics from specific worksheets/lines
2. Joins the data to create a consolidated view by facility
3. Calculates Medicare utilization rate
4. Orders by total patient days to show largest facilities first
5. Limits to top 100 for manageability

Assumptions & Limitations:
------------------------
- Assumes data is reported consistently across facilities
- Limited to facilities with complete data for all metrics
- Does not account for reporting period variations
- Text-to-number conversions may fail for malformed data

Possible Extensions:
------------------
1. Add trending analysis by incorporating multiple reporting periods
2. Include additional metrics like:
   - Average length of stay
   - Revenue per patient day
   - Occupancy rates
3. Add geographical analysis by incorporating facility location
4. Compare metrics across ownership types or facility sizes
5. Include quality metrics for correlation analysis
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:06:33.565339
    - Additional Notes: This query focuses on key operational metrics like patient days and Medicare utilization rates. Note that the numeric calculations depend on successful text-to-number conversions from the alphanumeric fields, which should be validated for production use. Consider adding error handling for data type conversions and NULL checks for more robust analysis.
    
    */