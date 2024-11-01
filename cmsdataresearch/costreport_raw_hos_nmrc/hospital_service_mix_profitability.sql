-- Hospital Service Mix Profitability Analysis
-- Business Purpose: Analyze the distribution of hospital services and their contribution to profitability
-- This analysis helps healthcare organizations and investors:
-- - Understand which service lines drive revenue and profitability
-- - Make informed decisions about service line investments
-- - Compare service mix strategies across facilities

WITH service_revenues AS (
    -- Extract service-specific revenues from Worksheet G-2, Part I
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN wksht_cd = 'G200001' AND line_num BETWEEN 1 AND 30 
            THEN itm_val_num ELSE 0 END) as inpatient_revenue,
        SUM(CASE WHEN wksht_cd = 'G200001' AND line_num BETWEEN 31 AND 60 
            THEN itm_val_num ELSE 0 END) as outpatient_revenue,
        SUM(CASE WHEN wksht_cd = 'G200001' AND line_num BETWEEN 61 AND 90 
            THEN itm_val_num ELSE 0 END) as ancillary_revenue
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE YEAR(mimi_src_file_date) = 2022
    GROUP BY rpt_rec_num
),
service_costs AS (
    -- Extract service-specific costs from Worksheet A
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN wksht_cd = 'A000000' AND line_num BETWEEN 30 AND 46 
            THEN itm_val_num ELSE 0 END) as inpatient_cost,
        SUM(CASE WHEN wksht_cd = 'A000000' AND line_num BETWEEN 50 AND 77 
            THEN itm_val_num ELSE 0 END) as outpatient_cost,
        SUM(CASE WHEN wksht_cd = 'A000000' AND line_num BETWEEN 80 AND 100 
            THEN itm_val_num ELSE 0 END) as ancillary_cost
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE YEAR(mimi_src_file_date) = 2022
    GROUP BY rpt_rec_num
)

SELECT 
    COUNT(DISTINCT r.rpt_rec_num) as total_hospitals,
    
    -- Revenue Mix Analysis
    AVG(inpatient_revenue / NULLIF(inpatient_revenue + outpatient_revenue + ancillary_revenue, 0)) * 100 as avg_inpatient_revenue_pct,
    AVG(outpatient_revenue / NULLIF(inpatient_revenue + outpatient_revenue + ancillary_revenue, 0)) * 100 as avg_outpatient_revenue_pct,
    AVG(ancillary_revenue / NULLIF(inpatient_revenue + outpatient_revenue + ancillary_revenue, 0)) * 100 as avg_ancillary_revenue_pct,
    
    -- Profitability Analysis
    AVG((inpatient_revenue - inpatient_cost) / NULLIF(inpatient_revenue, 0)) * 100 as avg_inpatient_margin_pct,
    AVG((outpatient_revenue - outpatient_cost) / NULLIF(outpatient_revenue, 0)) * 100 as avg_outpatient_margin_pct,
    AVG((ancillary_revenue - ancillary_cost) / NULLIF(ancillary_revenue, 0)) * 100 as avg_ancillary_margin_pct
FROM service_revenues r
JOIN service_costs c ON r.rpt_rec_num = c.rpt_rec_num;

-- How this query works:
-- 1. Creates two CTEs to separately calculate revenues and costs by service type
-- 2. Joins the CTEs to calculate key metrics:
--    - Service mix percentages
--    - Service-specific profit margins
-- 3. Returns aggregated results across all hospitals

-- Assumptions and Limitations:
-- - Assumes consistent reporting across hospitals for service line categorization
-- - Limited to specific worksheet ranges for service classification
-- - Does not account for indirect costs or overhead allocation
-- - Focused on 2022 data only

-- Possible Extensions:
-- 1. Add geographic segmentation to compare service mix by region
-- 2. Include trend analysis across multiple years
-- 3. Add hospital size or type classifications for peer group analysis
-- 4. Incorporate quality metrics to analyze service line performance
-- 5. Add detailed breakdowns of specific high-value service lines

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:29:33.813600
    - Additional Notes: The query focuses on three main service categories (inpatient, outpatient, ancillary) using specific worksheet ranges that should be validated against the latest CMS reporting guidelines. Revenue and cost mappings may need adjustment based on specific hospital reporting structures.
    
    */