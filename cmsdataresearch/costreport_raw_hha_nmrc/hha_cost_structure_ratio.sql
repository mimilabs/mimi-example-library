-- Title: Home Health Agency Direct vs. Indirect Cost Structure Analysis

-- Business Purpose:
-- This query analyzes the ratio of direct patient care costs to indirect/overhead costs
-- across Home Health Agencies to:
-- - Identify operational efficiency in cost allocation
-- - Support benchmarking of administrative overhead ratios
-- - Guide strategic decisions about resource allocation

WITH direct_costs AS (
    -- Extract direct patient care costs from Worksheet A
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN line_num BETWEEN 1 AND 15 THEN itm_val_num ELSE 0 END) as total_direct_cost
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'A'
    AND clmn_num = 7  -- Total costs column
    GROUP BY rpt_rec_num
),

indirect_costs AS (
    -- Extract indirect/overhead costs from Worksheet A
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN line_num BETWEEN 16 AND 30 THEN itm_val_num ELSE 0 END) as total_indirect_cost
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'A'
    AND clmn_num = 7  -- Total costs column
    GROUP BY rpt_rec_num
)

SELECT 
    d.rpt_rec_num,
    d.total_direct_cost,
    i.total_indirect_cost,
    d.total_direct_cost + i.total_indirect_cost as total_cost,
    ROUND(d.total_direct_cost / NULLIF(d.total_direct_cost + i.total_indirect_cost, 0) * 100, 2) as direct_cost_ratio,
    ROUND(i.total_indirect_cost / NULLIF(d.total_direct_cost + i.total_indirect_cost, 0) * 100, 2) as indirect_cost_ratio
FROM direct_costs d
JOIN indirect_costs i ON d.rpt_rec_num = i.rpt_rec_num
WHERE d.total_direct_cost > 0 
  AND i.total_indirect_cost > 0
ORDER BY total_cost DESC;

-- How the Query Works:
-- 1. The direct_costs CTE isolates costs from direct patient care cost centers (lines 1-15)
-- 2. The indirect_costs CTE captures overhead and administrative costs (lines 16-30)
-- 3. The main query joins these together and calculates key ratios
-- 4. Results are filtered to exclude invalid entries and sorted by total cost

-- Assumptions and Limitations:
-- - Assumes standard cost center structure on Worksheet A
-- - Does not account for variations in cost allocation methodologies
-- - May not capture all overhead costs if reported in non-standard locations
-- - Limited to single reporting period analysis

-- Possible Extensions:
-- 1. Add trending analysis by incorporating multiple reporting periods
-- 2. Include provider characteristics (size, ownership, location) for segmentation
-- 3. Add benchmarking against industry standards or peer groups
-- 4. Incorporate quality metrics to analyze cost efficiency vs. care quality
-- 5. Add detailed breakdown of specific cost center categories
-- 6. Enhance with statistical analysis of cost ratio distributions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:22:03.363582
    - Additional Notes: Query specifically focuses on Worksheet A cost allocations and requires careful validation of line number mappings to ensure accurate classification of direct vs indirect costs. Results may need adjustment based on specific provider's cost reporting structure.
    
    */