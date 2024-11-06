-- Hospital Emergency Department Volume and Efficiency Analysis
-- Business Purpose: Analyze emergency department utilization and efficiency metrics to:
-- - Evaluate ED capacity and throughput
-- - Support staffing and resource allocation decisions
-- - Compare ED performance across facilities
-- - Identify opportunities for operational improvements

WITH base_metrics AS (
    -- Get key ED metrics from Worksheet S-3 Part 1
    SELECT 
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S300001' AND line_num = 22 AND clmn_num = 15 
            THEN itm_val_num END) as total_ed_visits,
        MAX(CASE WHEN wksht_cd = 'S300001' AND line_num = 22 AND clmn_num = 13 
            THEN itm_val_num END) as ed_admissions,
        MAX(CASE WHEN wksht_cd = 'G300000' AND line_num = 5 AND clmn_num = 1 
            THEN itm_val_num END) as ed_operating_costs,
        YEAR(mimi_src_file_date) as report_year
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd IN ('S300001', 'G300000')
    GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
),
calculated_metrics AS (
    -- Calculate key performance indicators
    SELECT
        report_year,
        COUNT(DISTINCT rpt_rec_num) as hospitals_reporting,
        AVG(total_ed_visits) as avg_annual_ed_visits,
        AVG(ed_admissions/NULLIF(total_ed_visits,0))*100 as admission_rate_pct,
        AVG(ed_operating_costs/NULLIF(total_ed_visits,0)) as cost_per_visit
    FROM base_metrics
    WHERE total_ed_visits > 0
    GROUP BY report_year
    ORDER BY report_year
)
SELECT 
    report_year,
    hospitals_reporting,
    ROUND(avg_annual_ed_visits,0) as avg_annual_ed_visits,
    ROUND(admission_rate_pct,1) as admission_rate_pct,
    ROUND(cost_per_visit,2) as cost_per_visit
FROM calculated_metrics
WHERE report_year >= 2018;

-- How this works:
-- 1. First CTE extracts key ED metrics from specific worksheets and lines
-- 2. Second CTE calculates hospital-level KPIs and averages across facilities
-- 3. Final SELECT formats and filters results for recent years

-- Assumptions & Limitations:
-- - Relies on consistent reporting of ED visits and costs across hospitals
-- - Does not account for ED acuity mix or hospital characteristics
-- - Cost allocation methods may vary between facilities
-- - Missing or zero values are excluded from calculations

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include ED staffing metrics correlation
-- 3. Compare metrics by hospital type (urban/rural)
-- 4. Add trending analysis with year-over-year changes
-- 5. Include ED revenue metrics for margin analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:45:50.017142
    - Additional Notes: Query focuses on key emergency department efficiency metrics (visits, admission rates, costs) and supports operational decision-making. Results are aggregated at yearly level with hospital averages. Requires worksheet codes S300001 and G300000 to have complete data for meaningful results.
    
    */