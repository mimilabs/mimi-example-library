-- Hospital Net Patient Revenue Analysis
-- Business Purpose: Analyze net patient revenue trends across hospitals to:
-- - Understand revenue performance and payer mix
-- - Support financial benchmarking and forecasting
-- - Identify revenue growth opportunities
-- - Guide strategic planning decisions

-- Main Query
WITH base_revenue AS (
    -- Get relevant worksheet codes for revenue
    -- Worksheet G-3 captures net patient revenue by payer
    SELECT 
        rpt_rec_num,
        line_num,
        clmn_num,
        itm_val_num,
        mimi_src_file_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'G300000'
        AND line_num IN (1, 2, 3, 4) -- Lines for Medicare, Medicaid, Other, Total
        AND clmn_num = 1 -- Column for net patient revenue
        AND itm_val_num IS NOT NULL
),

revenue_by_payer AS (
    -- Pivot revenue data by payer type
    SELECT 
        rpt_rec_num,
        mimi_src_file_date,
        MAX(CASE WHEN line_num = 1 THEN itm_val_num END) as medicare_revenue,
        MAX(CASE WHEN line_num = 2 THEN itm_val_num END) as medicaid_revenue,
        MAX(CASE WHEN line_num = 3 THEN itm_val_num END) as other_revenue,
        MAX(CASE WHEN line_num = 4 THEN itm_val_num END) as total_revenue
    FROM base_revenue
    GROUP BY rpt_rec_num, mimi_src_file_date
)

-- Calculate key revenue metrics
SELECT 
    YEAR(mimi_src_file_date) as report_year,
    COUNT(DISTINCT rpt_rec_num) as hospital_count,
    ROUND(AVG(total_revenue)/1000000, 2) as avg_total_revenue_millions,
    ROUND(AVG(medicare_revenue/total_revenue)*100, 1) as avg_medicare_pct,
    ROUND(AVG(medicaid_revenue/total_revenue)*100, 1) as avg_medicaid_pct,
    ROUND(AVG(other_revenue/total_revenue)*100, 1) as avg_other_pct
FROM revenue_by_payer
WHERE total_revenue > 0 -- Exclude invalid records
GROUP BY YEAR(mimi_src_file_date)
ORDER BY report_year;

-- How this query works:
-- 1. First CTE extracts raw revenue data from worksheet G-3
-- 2. Second CTE pivots the data to get revenue by payer type
-- 3. Final SELECT calculates average revenue and payer mix metrics by year

-- Assumptions and Limitations:
-- - Relies on accurate reporting of revenue data in cost reports
-- - Only includes hospitals with positive total revenue
-- - Does not account for hospital characteristics (size, type, location)
-- - Limited to basic revenue metrics without cost/profitability analysis

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Segment by hospital type (urban/rural, teaching status)
-- 3. Calculate year-over-year growth rates
-- 4. Add operating margin analysis
-- 5. Include bed size or case mix adjustments
-- 6. Add statistical analysis (median, percentiles)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:50:24.348456
    - Additional Notes: Query focuses on net patient revenue and payer mix distribution (Medicare/Medicaid/Other) using worksheet G-3 data. Results are aggregated annually with revenue in millions and payer percentages. Requires worksheet G300000 to be present and properly populated in the source data.
    
    */