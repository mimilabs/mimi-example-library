-- Title: Medicare Part D Generic Drug Tier Coverage Analysis

-- Business Purpose:
-- This analysis examines the distribution of generic drugs across Medicare Part D formulary tiers 
-- to identify potential cost-saving opportunities and access barriers for beneficiaries.
-- Key objectives:
-- 1. Identify the proportion of generic drugs placed in preferred vs non-preferred tiers
-- 2. Understand patterns of tier placement for commonly prescribed generics
-- 3. Support formulary strategy and benefit design decisions

WITH generic_tier_summary AS (
    -- Filter to most recent data and aggregate generic drug tier placement
    SELECT 
        contract_year,
        tier_level_value,
        COUNT(DISTINCT rxcui) as drug_count,
        COUNT(DISTINCT formulary_id) as formulary_count,
        ROUND(AVG(CASE WHEN prior_authorization_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_pa,
        ROUND(AVG(CASE WHEN quantity_limit_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_ql
    FROM mimi_ws_1.prescriptiondrugplan.basic_drugs_formulary
    WHERE contract_year = 2024  -- Focus on current contract year
        AND tier_level_value IN (1,2) -- Focus on generic tiers (typically 1 and 2)
    GROUP BY contract_year, tier_level_value
)

SELECT
    tier_level_value as tier,
    drug_count,
    formulary_count,
    pct_with_pa as prior_auth_pct,
    pct_with_ql as quantity_limit_pct,
    ROUND(drug_count * 100.0 / SUM(drug_count) OVER (), 1) as pct_of_total_drugs
FROM generic_tier_summary
ORDER BY tier_level_value;

-- How this query works:
-- 1. Creates a CTE to summarize generic drug coverage patterns
-- 2. Filters to current contract year and generic tiers
-- 3. Calculates key metrics including drug counts and restriction percentages
-- 4. Presents results in final summary format showing tier distribution

-- Assumptions:
-- 1. Tiers 1 and 2 are typically used for generic drugs
-- 2. Contract year 2024 represents current formulary designs
-- 3. PA and QL are key restriction metrics for generics

-- Limitations:
-- 1. Does not account for specific drug classes or therapeutic categories
-- 2. Does not include cost-sharing amounts
-- 3. May not capture all generic drugs if some are placed in higher tiers

-- Possible Extensions:
-- 1. Add trending over multiple years
-- 2. Include therapeutic class analysis
-- 3. Compare patterns across different plan types
-- 4. Add cost-sharing data by linking to beneficiary_cost table
-- 5. Analyze regional variations in generic tier placement

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:41:56.009709
    - Additional Notes: Query focuses specifically on tier 1-2 drug distribution which may miss some generic drugs placed in higher tiers. Consider adjusting tier_level_value filter if analysis of all generic drugs regardless of tier placement is needed. Performance may be impacted for large datasets due to distinct counts.
    
    */