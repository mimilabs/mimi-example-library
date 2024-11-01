-- geographic_variation_snf_costs.sql
-- Business Purpose: Analyze geographical variation in SNF costs to identify regional 
-- cost patterns and potential optimization opportunities across different markets.
-- This analysis helps healthcare organizations make strategic decisions about 
-- market expansion, cost benchmarking, and resource allocation.

WITH provider_summary AS (
    -- Extract provider details from worksheet S-2 where identifying info is stored
    SELECT 
        rpt_rec_num,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = 1 AND clmn_num = 1 THEN itm_val_num END) as provider_num,
        MAX(CASE WHEN wksht_cd = 'S200001' AND line_num = 1 AND clmn_num = 2 THEN itm_val_num END) as state_code
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_nmrc
    GROUP BY rpt_rec_num
),

total_costs AS (
    -- Calculate total costs from worksheet G-2
    SELECT 
        rpt_rec_num,
        SUM(CASE WHEN wksht_cd = 'G200000' AND line_num = 100 THEN itm_val_num ELSE 0 END) as total_operating_costs
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_nmrc
    GROUP BY rpt_rec_num
)

-- Combine provider info with costs and calculate metrics
SELECT 
    p.state_code,
    COUNT(DISTINCT p.rpt_rec_num) as num_facilities,
    AVG(t.total_operating_costs) as avg_operating_costs,
    STDDEV(t.total_operating_costs) as std_dev_costs,
    MIN(t.total_operating_costs) as min_operating_costs,
    MAX(t.total_operating_costs) as max_operating_costs
FROM provider_summary p
JOIN total_costs t ON p.rpt_rec_num = t.rpt_rec_num
WHERE t.total_operating_costs > 0  -- Remove invalid/zero cost entries
GROUP BY p.state_code
ORDER BY avg_operating_costs DESC;

-- How this query works:
-- 1. First CTE extracts provider identification details from worksheet S-2
-- 2. Second CTE calculates total operating costs from worksheet G-2
-- 3. Main query joins these together and calculates state-level statistics
-- 4. Results show cost variation by state with key statistical measures

-- Assumptions and Limitations:
-- - Assumes worksheet codes and line numbers are consistent across reports
-- - Limited to operating costs; doesn't include capital costs
-- - State codes are numeric; may need mapping to state names
-- - Doesn't account for facility size or case mix differences

-- Possible Extensions:
-- 1. Add year-over-year trend analysis by incorporating report periods
-- 2. Include facility size normalization using bed counts
-- 3. Add urban/rural designation analysis
-- 4. Incorporate quality metrics to analyze cost-quality relationships
-- 5. Add specific cost categories (labor, supplies, etc.) breakdown

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:24:44.195414
    - Additional Notes: Query focuses on state-level cost variations for SNFs and requires worksheet codes S200001 and G200000 to be present in the dataset. Cost calculations are limited to operating costs and may not reflect total facility expenses. State codes in results are numeric and require external mapping for state names.
    
    */