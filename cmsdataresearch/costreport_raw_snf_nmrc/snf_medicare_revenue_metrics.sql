-- SNF Medicare Revenue and Utilization Analysis
-- Business Purpose: Analyze Medicare revenue and utilization patterns across skilled nursing facilities
-- to identify financial performance trends and opportunities for operational optimization.
-- This analysis helps healthcare organizations and investors understand market dynamics
-- and make data-driven decisions about SNF investments and operations.

WITH base_metrics AS (
    -- Extract key Medicare revenue and utilization metrics from specific worksheets
    SELECT 
        rpt_rec_num,
        -- Total Medicare Revenue (Worksheet G-2, Part I, Column 6)
        MAX(CASE WHEN wksht_cd = 'G200001' AND clmn_num = 6 AND line_num = 18 
            THEN itm_val_num ELSE 0 END) as total_medicare_revenue,
        -- Medicare Days (Worksheet S-3, Part I, Column 6)
        MAX(CASE WHEN wksht_cd = 'S300001' AND clmn_num = 6 AND line_num = 1 
            THEN itm_val_num ELSE 0 END) as medicare_days,
        -- Extract year from source file date
        YEAR(mimi_src_file_date) as reporting_year
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_nmrc
    WHERE mimi_src_file_date >= '2019-01-01'
    GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
)

SELECT 
    reporting_year,
    COUNT(DISTINCT rpt_rec_num) as facility_count,
    ROUND(AVG(total_medicare_revenue), 2) as avg_medicare_revenue,
    ROUND(AVG(medicare_days), 2) as avg_medicare_days,
    -- Calculate revenue per day
    ROUND(SUM(total_medicare_revenue) / NULLIF(SUM(medicare_days), 0), 2) as revenue_per_day,
    -- Calculate YoY growth in revenue (placeholder for extension)
    ROUND(AVG(total_medicare_revenue), 2) as revenue_baseline
FROM base_metrics
WHERE total_medicare_revenue > 0 AND medicare_days > 0
GROUP BY reporting_year
ORDER BY reporting_year DESC;

/* How it works:
1. The base_metrics CTE extracts key Medicare financial and utilization metrics from specific worksheets
2. Main query aggregates these metrics by year and calculates key performance indicators
3. Filters remove invalid/zero values to ensure data quality
4. Results show trends in Medicare revenue, utilization, and efficiency metrics

Assumptions and Limitations:
- Assumes worksheet codes and line numbers are consistent across reports
- Limited to Medicare revenue analysis; doesn't include other payer types
- Simplified approach to revenue per day calculation
- Does not account for inflation or regional cost variations

Possible Extensions:
1. Add geographic segmentation by incorporating facility location data
2. Include trend analysis with year-over-year growth calculations
3. Add quality metrics correlation analysis
4. Incorporate case mix adjustment factors
5. Add operational cost analysis to calculate margins
6. Segment analysis by facility size or ownership type
7. Add seasonal utilization patterns analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:47:31.710730
    - Additional Notes: Query focuses on key Medicare revenue and utilization metrics from SNF cost reports, utilizing specific worksheet codes G200001 and S300001. The 2019+ date filter ensures recent data analysis. Results are aggregated annually for strategic planning and performance benchmarking. Revenue per day calculation requires non-zero Medicare days to avoid division errors.
    
    */