-- Title: Medicare Plan Segment Distribution Analysis

-- Business Purpose:
-- This query analyzes how Medicare plans utilize segmentation strategies across regions
-- to understand:
-- - Market segmentation patterns that may indicate targeted benefit designs
-- - Potential correlation between segmentation and regional characteristics
-- - Plan complexity and administrative overhead by contract
-- This insight helps stakeholders optimize plan designs and identify operational efficiency opportunities.

WITH segment_counts AS (
    -- Calculate segment counts per contract/plan combination
    SELECT 
        contract_id,
        plan_id,
        contract_year,
        region,
        COUNT(DISTINCT segment_id) as num_segments,
        COUNT(*) as total_offerings
    FROM mimi_ws_1.partcd.pbp_plan_region_area
    WHERE contract_year >= 2020  -- Focus on recent years
    AND pending_flag = 'N'       -- Exclude pending plans
    GROUP BY 
        contract_id,
        plan_id, 
        contract_year,
        region
),

segment_summary AS (
    -- Summarize segmentation patterns
    SELECT
        contract_year,
        region,
        AVG(num_segments) as avg_segments_per_plan,
        MAX(num_segments) as max_segments_per_plan,
        COUNT(DISTINCT contract_id) as num_contracts,
        SUM(total_offerings) as total_regional_offerings
    FROM segment_counts
    GROUP BY 
        contract_year,
        region
)

-- Final output with key segmentation metrics
SELECT 
    contract_year,
    region,
    num_contracts,
    ROUND(avg_segments_per_plan, 2) as avg_segments_per_plan,
    max_segments_per_plan,
    total_regional_offerings,
    ROUND(total_regional_offerings::FLOAT / num_contracts, 2) as offerings_per_contract
FROM segment_summary
ORDER BY 
    contract_year DESC,
    total_regional_offerings DESC;

-- How it works:
-- 1. First CTE counts distinct segments for each contract/plan/region combination
-- 2. Second CTE aggregates to regional level with key segmentation metrics
-- 3. Final query presents results in a business-friendly format

-- Assumptions and Limitations:
-- - Assumes segment_id is consistently assigned across years
-- - Excludes pending plans as they may not represent final configurations
-- - Regional comparisons may be affected by market size differences
-- - Analysis starts from 2020 to focus on current patterns

-- Possible Extensions:
-- 1. Add plan_type analysis to understand segmentation by plan category
-- 2. Include benefit_coverage_type to analyze relationship with segmentation
-- 3. Trend analysis comparing year-over-year changes in segmentation
-- 4. Cross-reference with enrollment data to assess impact of segmentation
-- 5. Add geographic groupings to identify regional segmentation patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:47:03.417276
    - Additional Notes: Query focuses on plan segmentation strategies which can serve as a proxy for market sophistication and operational complexity. Results are filtered to post-2020 for current relevance. Consider memory usage when extending to longer time periods or adding additional metrics.
    
    */