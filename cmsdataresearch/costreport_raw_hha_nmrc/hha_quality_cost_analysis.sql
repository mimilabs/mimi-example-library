-- Title: Home Health Agency Quality Measure Cost Impact Analysis

-- Business Purpose:
-- This query analyzes the relationship between quality measure investments and 
-- operational costs for Home Health Agencies (HHAs) to:
-- - Quantify financial impact of quality improvement initiatives
-- - Support strategic decisions on resource allocation for quality programs
-- - Identify cost-effective quality improvement opportunities

WITH quality_costs AS (
    -- Extract quality-related costs from Worksheet A
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN line_num = 15 THEN itm_val_num ELSE 0 END) as quality_program_costs,
        SUM(CASE WHEN line_num = 16 THEN itm_val_num ELSE 0 END) as training_education_costs
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'A'
        AND clmn_num = 7  -- Total costs column
        AND YEAR(mimi_src_file_date) = 2022
    GROUP BY rpt_rec_num
),

total_operating AS (
    -- Calculate total operating expenses
    SELECT 
        rpt_rec_num,
        SUM(itm_val_num) as total_operating_costs
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'A'
        AND clmn_num = 7
        AND line_num <= 100  -- Operating cost lines
        AND YEAR(mimi_src_file_date) = 2022
    GROUP BY rpt_rec_num
)

SELECT 
    qc.rpt_rec_num,
    qc.quality_program_costs,
    qc.training_education_costs,
    t.total_operating_costs,
    ROUND(qc.quality_program_costs / t.total_operating_costs * 100, 2) as quality_cost_pct,
    ROUND(qc.training_education_costs / t.total_operating_costs * 100, 2) as training_cost_pct,
    ROUND((qc.quality_program_costs + qc.training_education_costs) / t.total_operating_costs * 100, 2) as total_quality_investment_pct
FROM quality_costs qc
JOIN total_operating t ON qc.rpt_rec_num = t.rpt_rec_num
WHERE t.total_operating_costs > 0
ORDER BY total_quality_investment_pct DESC;

-- How the Query Works:
-- 1. First CTE extracts quality-specific costs from Worksheet A
-- 2. Second CTE calculates total operating expenses
-- 3. Main query joins these together to compute quality investment percentages
-- 4. Results are filtered to exclude invalid records and sorted by investment level

-- Assumptions and Limitations:
-- - Assumes quality costs are consistently reported on specified lines
-- - Limited to 2022 data for current state analysis
-- - Does not account for indirect quality-related costs
-- - May not capture all quality investments if reported elsewhere

-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Incorporate quality outcome measures for ROI analysis
-- 3. Add geographic segmentation for regional comparisons
-- 4. Include agency size and type stratification
-- 5. Add correlation with patient satisfaction scores

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:29:06.865888
    - Additional Notes: The query focuses on 2022 data and specifically analyzes Worksheet A line items 15 and 16 for quality program and training costs. Users should verify these line numbers match their specific cost reporting requirements and may need to adjust based on different reporting years or form versions.
    
    */