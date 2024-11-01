-- Title: Medicare Special Needs Plan (SNP) Market Coverage Analysis

-- Business Purpose: 
-- This analysis identifies the distribution and characteristics of Medicare Special Needs Plans
-- to help healthcare organizations:
-- - Understand market penetration of SNPs across different regions
-- - Evaluate opportunities for expanding specialized Medicare coverage
-- - Compare SNP offerings across different organization types
-- - Assess the quality ratings of SNP programs

WITH snp_summary AS (
    -- Get base metrics for SNP plans
    SELECT 
        state,
        organization_type,
        special_needs_plan_type,
        COUNT(DISTINCT contract_id || plan_id) as num_plans,
        COUNT(DISTINCT organization_name) as num_organizations,
        ROUND(AVG(COALESCE(overall_star_rating, 0)), 2) as avg_star_rating,
        ROUND(AVG(COALESCE(part_c_premium, 0)), 2) as avg_part_c_premium,
        ROUND(AVG(COALESCE(part_d_total_premium, 0)), 2) as avg_part_d_premium
    FROM mimi_ws_1.partcd.landscape_plan_premium_report
    WHERE special_needs_plan = 'Yes'
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.partcd.landscape_plan_premium_report)
    GROUP BY state, organization_type, special_needs_plan_type
),
state_totals AS (
    -- Calculate state-level totals for market share analysis
    SELECT 
        state,
        SUM(num_plans) as total_state_snp_plans
    FROM snp_summary
    GROUP BY state
)

SELECT 
    s.state,
    s.organization_type,
    s.special_needs_plan_type,
    s.num_plans,
    s.num_organizations,
    s.avg_star_rating,
    s.avg_part_c_premium,
    s.avg_part_d_premium,
    ROUND(s.num_plans * 100.0 / t.total_state_snp_plans, 1) as pct_of_state_snps
FROM snp_summary s
JOIN state_totals t ON s.state = t.state
WHERE t.total_state_snp_plans >= 5  -- Focus on states with meaningful SNP presence
ORDER BY t.total_state_snp_plans DESC, s.num_plans DESC;

-- How this query works:
-- 1. Creates a summary of SNP plans using the most recent data
-- 2. Calculates state-level totals for market share analysis
-- 3. Joins the summaries with totals to compute market share percentages
-- 4. Filters for states with significant SNP presence
-- 5. Orders results to highlight states with the most SNP activity

-- Assumptions and Limitations:
-- - Uses only the most recent data snapshot
-- - Excludes states with fewer than 5 SNP plans
-- - Assumes all plan records are valid and complete
-- - Star ratings may be null for some plans
-- - Premium calculations exclude plans with null values

-- Possible Extensions:
-- 1. Add year-over-year trend analysis for SNP market growth
-- 2. Include county-level penetration analysis
-- 3. Add benefit package comparison across SNP types
-- 4. Incorporate demographic data to identify underserved populations
-- 5. Add analysis of drug coverage and formulary differences
-- 6. Compare SNP performance metrics against non-SNP Medicare Advantage plans

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:12:34.646221
    - Additional Notes: Query provides market penetration metrics for Special Needs Plans and filters out states with low SNP presence (<5 plans). Results are most meaningful for strategic planning in states with established SNP markets. Premium and star rating averages exclude null values which may affect completeness of analysis in some regions.
    
    */