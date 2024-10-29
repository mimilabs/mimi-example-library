-- Hospital Revenue Per Patient Day Analysis
-- Business Purpose: Analyze hospital revenue efficiency by calculating average revenue per patient day
-- This provides key insights into:
-- - Hospital revenue generation performance
-- - Resource utilization effectiveness
-- - Benchmarking opportunities across facilities
-- - Potential areas for revenue optimization

WITH patient_days AS (
    -- Get total patient days from worksheet S-3 Part 1, line 12, column 6
    SELECT 
        rpt_rec_num,
        itm_val_num as total_patient_days,
        mimi_src_file_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'S300001'
        AND line_num = 12
        AND clmn_num = 6
        AND itm_val_num > 0
),

total_revenue AS (
    -- Get total patient revenue from worksheet G-3, line 3, column 1
    SELECT 
        rpt_rec_num,
        itm_val_num as total_patient_revenue
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'G300000'
        AND line_num = 3
        AND clmn_num = 1
        AND itm_val_num > 0
)

SELECT 
    pd.rpt_rec_num,
    pd.total_patient_days,
    tr.total_patient_revenue,
    ROUND(tr.total_patient_revenue / pd.total_patient_days, 2) as revenue_per_patient_day,
    EXTRACT(YEAR FROM pd.mimi_src_file_date) as report_year
FROM patient_days pd
JOIN total_revenue tr ON pd.rpt_rec_num = tr.rpt_rec_num
WHERE pd.total_patient_days > 0
ORDER BY revenue_per_patient_day DESC
LIMIT 1000;

-- How this query works:
-- 1. First CTE gets total patient days and file date from worksheet S-3
-- 2. Second CTE gets total patient revenue from worksheet G-3
-- 3. Main query joins these metrics and calculates revenue per patient day
-- 4. Results are filtered to exclude invalid data and sorted by efficiency

-- Assumptions and Limitations:
-- - Assumes accurate reporting of patient days and revenue
-- - Does not account for case mix or service complexity
-- - Limited to facilities with complete data for both metrics
-- - May not reflect actual collected revenue vs charged amounts

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider information
-- 2. Include trend analysis across multiple years
-- 3. Break down by hospital type (teaching vs non-teaching)
-- 4. Add peer group comparisons based on hospital size
-- 5. Include additional efficiency metrics like cost per patient day
-- 6. Analyze seasonal variations in revenue efficiency/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:11:47.122105
    - Additional Notes: Script calculates key revenue efficiency metric using CMS cost report data. Note that revenue values represent reported charges rather than actual collections, and results should be interpreted alongside other financial metrics for a complete analysis. Best used for comparative analysis across similar facility types or trending over time.
    
    */