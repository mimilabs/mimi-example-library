-- Hospital Teaching Status Financial Profile Analysis
-- Business Purpose: Analyze key financial metrics by hospital teaching status to:
-- - Compare efficiency and scale between teaching and non-teaching hospitals
-- - Support strategic planning and benchmarking for academic medical centers
-- - Identify opportunities for operational improvements based on peer comparison

WITH teaching_status AS (
    -- Get teaching status from worksheet S-2 line 57
    SELECT DISTINCT 
        rpt_rec_num,
        CASE 
            WHEN wksht_cd = 'S200001' AND line_num = 57 AND clmn_num = 1 AND itm_val_num = 1 
            THEN 'Teaching'
            ELSE 'Non-Teaching' 
        END AS hospital_type
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'S200001' AND line_num = 57
),

total_beds AS (
    -- Get total bed count from worksheet S-3 line 14
    SELECT 
        rpt_rec_num,
        itm_val_num as bed_count
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'S300001' AND line_num = 14 AND clmn_num = 2
),

operating_metrics AS (
    -- Get key operating metrics from worksheet G-3
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN line_num = 3 THEN itm_val_num ELSE 0 END) as total_revenue,
        SUM(CASE WHEN line_num = 4 THEN itm_val_num ELSE 0 END) as total_costs
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'G300000' 
    AND line_num IN (3,4)
    GROUP BY rpt_rec_num
)

SELECT 
    t.hospital_type,
    COUNT(DISTINCT o.rpt_rec_num) as hospital_count,
    ROUND(AVG(b.bed_count)) as avg_beds,
    ROUND(AVG(o.total_revenue/1000000),2) as avg_revenue_millions,
    ROUND(AVG(o.total_costs/1000000),2) as avg_costs_millions,
    ROUND(AVG((o.total_revenue - o.total_costs)/o.total_revenue * 100),2) as avg_margin_percent
FROM teaching_status t
JOIN total_beds b ON t.rpt_rec_num = b.rpt_rec_num
JOIN operating_metrics o ON t.rpt_rec_num = o.rpt_rec_num
GROUP BY t.hospital_type
ORDER BY t.hospital_type;

-- How this works:
-- 1. First CTE identifies teaching status from worksheet S-2
-- 2. Second CTE pulls total bed count from worksheet S-3
-- 3. Third CTE calculates revenue and costs from worksheet G-3
-- 4. Final query joins these together and calculates key metrics by teaching status

-- Assumptions and limitations:
-- - Assumes accurate reporting of teaching status on worksheet S-2
-- - Limited to hospitals that report all required metrics
-- - Does not account for regional cost variations
-- - Simple binary teaching/non-teaching classification

-- Possible extensions:
-- 1. Add geographic segmentation
-- 2. Include case mix index adjustment
-- 3. Add year-over-year trend analysis
-- 4. Break out resident-to-bed ratios for teaching hospitals
-- 5. Include quality metrics correlation analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:11:35.958289
    - Additional Notes: Query aggregates performance metrics at the hospital level based on teaching status, providing insights into operational scale and financial efficiency differences between teaching and non-teaching institutions. Note that results depend on complete reporting across worksheets S-2, S-3, and G-3, which may limit the sample size.
    
    */