-- Title: Healthcare.gov Formulary Tier Analysis - Drug Cost Sharing Structure
--
-- Business Purpose:
-- This query analyzes the distribution of drug tiers across health plans to understand:
-- 1. How plans structure their drug cost sharing
-- 2. Which drugs commonly appear in specialty/high-cost tiers
-- 3. Variation in tier assignments for the same drugs across different plans
-- This information helps stakeholders understand plan benefit design and identify 
-- potential cost barriers for specific medications.

WITH tier_summary AS (
    -- Get the distribution of tier assignments per drug
    SELECT 
        drug_name,
        rxnorm_id,
        drug_tier,
        COUNT(DISTINCT plan_id) as plan_count,
        COUNT(DISTINCT plan_id) * 100.0 / SUM(COUNT(DISTINCT plan_id)) OVER(PARTITION BY rxnorm_id) as pct_of_plans
    FROM mimi_ws_1.datahealthcaregov.formulary_details
    WHERE array_contains(years, 2023)  -- Modified to use array_contains for array type
    GROUP BY drug_name, rxnorm_id, drug_tier
),

drug_tier_variation AS (
    -- Identify drugs with significant tier variation across plans
    SELECT 
        drug_name,
        rxnorm_id,
        COUNT(DISTINCT drug_tier) as unique_tier_count,
        CONCAT_WS(', ', COLLECT_SET(drug_tier)) as tier_assignments
    FROM mimi_ws_1.datahealthcaregov.formulary_details
    WHERE array_contains(years, 2023)  -- Modified to use array_contains for array type
    GROUP BY drug_name, rxnorm_id
    HAVING COUNT(DISTINCT drug_tier) > 1
)

SELECT 
    ts.drug_name,
    ts.rxnorm_id,
    ts.drug_tier,
    ts.plan_count,
    ROUND(ts.pct_of_plans, 2) as pct_of_plans,
    dtv.unique_tier_count,
    dtv.tier_assignments
FROM tier_summary ts
JOIN drug_tier_variation dtv 
    ON ts.rxnorm_id = dtv.rxnorm_id
WHERE ts.pct_of_plans >= 20  -- Focus on significant tier assignments
ORDER BY ts.rxnorm_id, ts.pct_of_plans DESC;

-- How this query works:
-- 1. tier_summary CTE calculates the distribution of tier assignments for each drug
-- 2. drug_tier_variation CTE identifies drugs with varying tier assignments
-- 3. Main query joins these results to show drugs with significant tier variation
--    and their distribution patterns

-- Assumptions and Limitations:
-- 1. Assumes current year (2023) data is most relevant
-- 2. Focuses only on drugs with multiple tier assignments
-- 3. Minimum threshold of 20% plan coverage to filter out edge cases
-- 4. Does not account for plan enrollment numbers or market share
-- 5. Years field is an array type, requiring array_contains for filtering

-- Possible Extensions:
-- 1. Add temporal analysis to track tier changes over time
-- 2. Include drug class/category analysis for broader patterns
-- 3. Correlate with plan premium data to analyze pricing strategies
-- 4. Add geographic analysis to identify regional variations
-- 5. Compare brand vs generic tier assignments for same therapeutic class

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:01:34.717248
    - Additional Notes: Query analyzes how health plans assign different tier levels to the same medications, focusing on drugs with significant variation across plans (>20% of plans). Note that the years field is expected to be an array type, and the analysis is fixed to 2023 data. Results show both the predominant tier assignments and the degree of variation across plans for each drug.
    
    */