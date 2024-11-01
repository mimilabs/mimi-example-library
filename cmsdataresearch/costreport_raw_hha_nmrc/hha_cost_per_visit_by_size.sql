-- Title: Home Health Agency Cost Per Visit Assessment by Provider Size
-- Business Purpose:
-- This query analyzes HHA cost per visit across different provider sizes to:
-- - Identify cost efficiency patterns based on agency scale
-- - Support strategic planning around optimal agency size
-- - Inform growth and consolidation decisions
-- - Benchmark cost performance against industry peers

WITH visits_by_provider AS (
    -- Get total visits from Worksheet S3 Part I (wksht_cd = 'S3PI')
    -- Line 1-6 represent different visit types, Column 4 has visit counts
    SELECT 
        rpt_rec_num,
        SUM(itm_val_num) as total_visits
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'S3PI' 
    AND line_num BETWEEN 1 AND 6
    AND clmn_num = 4
    GROUP BY rpt_rec_num
),

total_costs AS (
    -- Get total costs from Worksheet F1 (wksht_cd = 'F1')
    -- Line 26 represents total costs, Column 2 has cost amounts
    SELECT 
        rpt_rec_num,
        SUM(itm_val_num) as total_cost
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc 
    WHERE wksht_cd = 'F1'
    AND line_num = 26 
    AND clmn_num = 2
    GROUP BY rpt_rec_num
)

-- Calculate cost per visit and segment by provider size
SELECT 
    CASE 
        WHEN v.total_visits < 10000 THEN 'Small (<10K visits)'
        WHEN v.total_visits < 50000 THEN 'Medium (10K-50K visits)'
        ELSE 'Large (>50K visits)'
    END as agency_size,
    COUNT(DISTINCT v.rpt_rec_num) as provider_count,
    ROUND(AVG(v.total_visits)) as avg_annual_visits,
    ROUND(AVG(c.total_cost/v.total_visits), 2) as avg_cost_per_visit,
    ROUND(MIN(c.total_cost/v.total_visits), 2) as min_cost_per_visit,
    ROUND(MAX(c.total_cost/v.total_visits), 2) as max_cost_per_visit
FROM visits_by_provider v
JOIN total_costs c ON v.rpt_rec_num = c.rpt_rec_num
WHERE v.total_visits > 0  -- Exclude invalid records
GROUP BY 
    CASE 
        WHEN v.total_visits < 10000 THEN 'Small (<10K visits)'
        WHEN v.total_visits < 50000 THEN 'Medium (10K-50K visits)'
        ELSE 'Large (>50K visits)'
    END
ORDER BY avg_annual_visits;

-- How this query works:
-- 1. First CTE aggregates total visits across all visit types from Worksheet S3 Part I
-- 2. Second CTE pulls total costs from Worksheet F1
-- 3. Main query joins these metrics and segments providers by visit volume
-- 4. Calculates average, min, and max cost per visit for each size segment

-- Assumptions and limitations:
-- - Assumes Worksheet S3PI and F1 data is complete and accurate
-- - Size categories are simplified; may need adjustment based on market specifics
-- - Outliers could significantly impact min/max values
-- - Does not account for case mix or service complexity differences

-- Possible extensions:
-- 1. Add geographic segmentation to compare size effects across regions
-- 2. Include year-over-year trending to show scale effects over time
-- 3. Break down costs by major expense categories
-- 4. Add quality metrics to assess size vs. quality relationships
-- 5. Include ownership type analysis within size segments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:41:39.961068
    - Additional Notes: Query groups HHAs into size categories based on annual visit volume and calculates key cost efficiency metrics. Size thresholds (10K/50K visits) may need adjustment based on specific market analysis needs. Consider adding filters for specific reporting periods if analyzing temporal trends.
    
    */