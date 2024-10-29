/* hha_staffing_patterns.sql 

Business Purpose: This query analyzes Home Health Agency staffing patterns and certifications
by examining worksheet entries related to personnel qualifications and employment status.
Understanding staffing composition helps assess operational efficiency, compliance, and care delivery capacity.

Key business value:
- Evaluate workforce composition and credentials
- Identify staffing gaps and optimization opportunities 
- Support workforce planning and recruitment strategies
- Monitor compliance with staffing requirements
*/

WITH staff_records AS (
    SELECT 
        rpt_rec_num,
        wksht_cd,
        line_num,
        clmn_num,
        itm_alphnmrc_itm_txt,
        mimi_src_file_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_alpha
    WHERE wksht_cd IN ('S-3') -- Worksheet S-3 contains staffing information
    AND line_num BETWEEN 1 AND 30 -- Lines containing staff categories
    AND itm_alphnmrc_itm_txt IS NOT NULL
),

qualified_staff AS (
    SELECT
        rpt_rec_num,
        EXTRACT(YEAR FROM mimi_src_file_date) AS report_year,
        COUNT(DISTINCT CASE WHEN line_num IN (1,2,3) THEN itm_alphnmrc_itm_txt END) AS registered_nurses,
        COUNT(DISTINCT CASE WHEN line_num IN (4,5) THEN itm_alphnmrc_itm_txt END) AS licensed_practitioners,
        COUNT(DISTINCT CASE WHEN line_num IN (6,7,8) THEN itm_alphnmrc_itm_txt END) AS therapy_staff,
        COUNT(DISTINCT CASE WHEN line_num IN (9,10) THEN itm_alphnmrc_itm_txt END) AS home_health_aides
    FROM staff_records
    GROUP BY 1, 2
)

SELECT
    report_year,
    COUNT(DISTINCT rpt_rec_num) AS total_agencies,
    AVG(registered_nurses) AS avg_rn_count,
    AVG(licensed_practitioners) AS avg_lp_count,
    AVG(therapy_staff) AS avg_therapy_count,
    AVG(home_health_aides) AS avg_aide_count,
    AVG(registered_nurses + licensed_practitioners + therapy_staff + home_health_aides) AS avg_total_staff
FROM qualified_staff
GROUP BY 1
ORDER BY 1;

/* How this query works:
1. Filters cost report data to focus on staffing-related worksheet S-3
2. Identifies different staff categories based on line numbers
3. Calculates average staffing levels by year across agencies
4. Provides trend analysis of staffing composition over time

Assumptions and Limitations:
- Assumes consistent reporting of staff categories across years
- Limited to staff types captured in worksheet S-3
- May not capture contract or temporary staff
- Does not account for full-time vs part-time status

Possible Extensions:
1. Add geographic grouping to compare regional staffing patterns
2. Include analysis of staff turnover by comparing year-over-year changes
3. Correlate staffing levels with quality metrics or patient outcomes
4. Break down analysis by agency size or ownership type
5. Compare staff mix ratios to industry benchmarks
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:23:14.118602
    - Additional Notes: Query focuses specifically on Worksheet S-3 staff categorization. Results are aggregated at annual level and may need adjustment if analyzing at more granular time periods. Line number ranges (1-30) should be validated against latest CMS form specifications to ensure all relevant staff categories are captured.
    
    */