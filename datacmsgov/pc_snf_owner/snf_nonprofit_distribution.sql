-- snf_nonprofit_geographic_patterns.sql
-- Analyzes the geographic distribution of non-profit vs for-profit ownership 
-- in Skilled Nursing Facilities (SNFs) to identify regional ownership patterns
--
-- Business Purpose:
-- - Help health systems identify partnership opportunities with non-profit SNFs
-- - Support state-level policy analysis of SNF ownership models
-- - Guide market entry strategies based on ownership concentration patterns

WITH owner_type_summary AS (
    -- Aggregate ownership information by state and profit status
    SELECT 
        state_owner,
        COUNT(DISTINCT enrollment_id) as total_snfs,
        SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) as nonprofit_count,
        SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as forprofit_count,
        ROUND(100.0 * SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) / 
            COUNT(DISTINCT enrollment_id), 1) as nonprofit_percentage
    FROM mimi_ws_1.datacmsgov.pc_snf_owner
    WHERE state_owner IS NOT NULL
    GROUP BY state_owner
)

SELECT 
    state_owner as state,
    total_snfs,
    nonprofit_count,
    forprofit_count,
    nonprofit_percentage,
    CASE 
        WHEN nonprofit_percentage >= 30 THEN 'High Non-Profit'
        WHEN nonprofit_percentage >= 15 THEN 'Moderate Non-Profit'
        ELSE 'Low Non-Profit'
    END as market_classification
FROM owner_type_summary
WHERE total_snfs >= 10  -- Filter out states with very few SNFs
ORDER BY nonprofit_percentage DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate ownership data by state
-- 2. Calculates counts and percentages for non-profit vs for-profit ownership
-- 3. Classifies markets based on non-profit concentration
-- 4. Filters and sorts results to highlight key patterns

-- Assumptions and Limitations:
-- - Assumes current ownership status is accurately reported
-- - Does not account for mixed ownership structures
-- - May not reflect recent ownership changes
-- - Excludes states with very few SNFs for statistical relevance

-- Possible Extensions:
-- 1. Add temporal analysis to track ownership changes over time
-- 2. Include facility size/capacity in the analysis
-- 3. Cross-reference with quality metrics
-- 4. Add county-level geographic analysis
-- 5. Incorporate demographic data for market analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:15:30.791735
    - Additional Notes: The query may undercount mixed-ownership facilities since it only looks at strict non-profit vs for-profit flags. Consider adding ownership percentage weighting for more accurate market classification. State-level aggregation might mask important local market variations.
    
    */