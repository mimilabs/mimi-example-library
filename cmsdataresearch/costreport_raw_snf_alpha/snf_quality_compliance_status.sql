-- SNF Patient Safety & Quality Measures Assessment
-- =========================================================

-- Business Purpose:
-- ---------------
-- This query analyzes patient safety and quality-related measures from SNF cost reports
-- to understand:
-- - Infection control program status
-- - Quality assessment activities
-- - Patient safety protocols
-- Key stakeholders: Clinical Quality teams, Compliance officers, Risk Management

WITH quality_measures AS (
    -- Extract quality-related indicators from specific worksheets
    SELECT DISTINCT
        rpt_rec_num,
        MAX(CASE 
            WHEN wksht_cd = 'S001' AND line_num = '26' 
            THEN itm_alphnmrc_itm_txt 
        END) as infection_control_status,
        MAX(CASE 
            WHEN wksht_cd = 'S001' AND line_num = '27' 
            THEN itm_alphnmrc_itm_txt 
        END) as quality_assessment_status,
        MAX(CASE 
            WHEN wksht_cd = 'S001' AND line_num = '28' 
            THEN itm_alphnmrc_itm_txt 
        END) as patient_safety_protocol
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd = 'S001' 
    AND line_num IN ('26', '27', '28')
    GROUP BY rpt_rec_num
),

latest_reports AS (
    -- Get the most recent report for each facility
    SELECT 
        rpt_rec_num,
        MAX(mimi_src_file_date) as latest_report_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    GROUP BY rpt_rec_num
)

-- Final result combining quality measures with latest report dates
SELECT 
    q.rpt_rec_num,
    l.latest_report_date,
    q.infection_control_status,
    q.quality_assessment_status,
    q.patient_safety_protocol,
    -- Calculate compliance percentages
    COUNT(*) OVER() as total_facilities,
    SUM(CASE WHEN q.infection_control_status = 'Y' THEN 1 ELSE 0 END) OVER() * 100.0 / COUNT(*) OVER() as infection_control_compliance_pct,
    SUM(CASE WHEN q.quality_assessment_status = 'Y' THEN 1 ELSE 0 END) OVER() * 100.0 / COUNT(*) OVER() as quality_assessment_compliance_pct
FROM quality_measures q
JOIN latest_reports l ON q.rpt_rec_num = l.rpt_rec_num
ORDER BY l.latest_report_date DESC;

-- How this query works:
-- 1. First CTE extracts quality-related indicators from worksheet S001
-- 2. Second CTE identifies the most recent report for each facility
-- 3. Main query combines the data and calculates compliance percentages
-- 4. Results ordered by report date to show most recent status first

-- Assumptions and Limitations:
-- - Assumes worksheet S001 contains standardized quality measure reporting
-- - Y/N responses in the alphanumeric fields indicate compliance
-- - Based on self-reported data which may have inherent reporting biases
-- - Limited to measures explicitly captured in cost reports

-- Possible Extensions:
-- 1. Add trending analysis to show changes in compliance over time
-- 2. Include geographic analysis to identify regional patterns
-- 3. Correlate quality measures with staffing levels or financial metrics
-- 4. Add drill-down capability for specific quality measure components
-- 5. Include comparison with national benchmarks if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:07:38.047752
    - Additional Notes: Query focuses on three key quality compliance indicators from worksheet S001, providing both individual facility status and aggregate compliance rates. Best used for quarterly compliance monitoring and trend analysis. Note that worksheet S001 data availability may vary across reporting periods.
    
    */