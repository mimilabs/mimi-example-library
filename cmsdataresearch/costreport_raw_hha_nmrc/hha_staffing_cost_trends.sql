-- Title: Home Health Agency Staffing Cost Trends Analysis 

/*
Business Purpose:
This query analyzes staffing costs and labor trends across Home Health Agencies to:
- Track compensation patterns for key clinical roles
- Identify labor cost variations across reporting periods
- Support workforce planning and budget forecasting
- Enable benchmarking of staff-related expenses

The insights help agencies optimize staffing models and manage labor costs 
while maintaining quality of care.
*/

SELECT 
    rpt_rec_num,
    wksht_cd,
    -- Extract year from the source file date for trending
    YEAR(mimi_src_file_date) as report_year,
    -- Focus on salary-related line items
    line_num,
    -- Aggregate salary costs
    SUM(CASE WHEN clmn_num = 1 THEN itm_val_num ELSE 0 END) as salary_amount,
    -- Aggregate hours
    SUM(CASE WHEN clmn_num = 2 THEN itm_val_num ELSE 0 END) as total_hours,
    -- Calculate average hourly rate
    CASE 
        WHEN SUM(CASE WHEN clmn_num = 2 THEN itm_val_num ELSE 0 END) > 0 
        THEN SUM(CASE WHEN clmn_num = 1 THEN itm_val_num ELSE 0 END) / 
             SUM(CASE WHEN clmn_num = 2 THEN itm_val_num ELSE 0 END)
        ELSE 0 
    END as avg_hourly_rate
FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
-- Focus on worksheets containing staffing data
WHERE wksht_cd IN ('S1', 'S2') 
-- Filter for salary/wage line items
AND line_num BETWEEN 1 AND 50
GROUP BY 
    rpt_rec_num,
    wksht_cd,
    YEAR(mimi_src_file_date),
    line_num
HAVING total_hours > 0
ORDER BY 
    report_year DESC,
    wksht_cd,
    line_num;

/*
How It Works:
- Extracts staffing costs and hours from relevant worksheets
- Calculates key metrics like average hourly rates
- Groups data by reporting period and staff categories
- Filters out records with zero hours to ensure valid rate calculations

Assumptions & Limitations:
- Assumes consistent reporting of staff hours and wages
- Limited to direct labor costs captured in worksheets S1 and S2
- Does not include contractor or temporary staff costs
- Historical trending limited by available source file dates

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Compare costs across different agency ownership types
3. Include productivity metrics by incorporating visit/patient volumes
4. Analyze overtime patterns and seasonal staffing variations
5. Break out costs by clinical vs. administrative staff categories
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:34:39.599098
    - Additional Notes: Query excludes contractor costs and focuses on direct labor expenses from S1/S2 worksheets. Best used for year-over-year comparisons of permanent staff costs. Line numbers 1-50 assumption should be verified against specific form versions.
    
    */