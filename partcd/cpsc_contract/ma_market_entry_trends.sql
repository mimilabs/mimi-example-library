-- Medicare Advantage Plan Growth and Market Entry Analysis
--
-- Business Purpose:
--   This analysis examines temporal patterns in Medicare Advantage market entry and growth by:
--   1. Tracking new contract entries over time
--   2. Identifying emerging organization types and plan models
--   3. Revealing market maturity and innovation through plan offerings
--   
--   Key stakeholders: Market strategists, business development teams, and competitive intelligence analysts

WITH monthly_snapshots AS (
    -- Get the latest snapshot for each month to avoid duplicates
    SELECT DISTINCT
        DATE_TRUNC('month', mimi_src_file_date) as snapshot_month,
        contract_id,
        organization_type,
        plan_type,
        offers_part_d,
        contract_effective_date
    FROM mimi_ws_1.partcd.cpsc_contract
),

new_entries AS (
    -- Identify new market entrants by contract effective date
    SELECT 
        DATE_TRUNC('month', contract_effective_date) as entry_month,
        organization_type,
        plan_type,
        COUNT(DISTINCT contract_id) as new_contracts,
        SUM(CASE WHEN offers_part_d = true THEN 1 ELSE 0 END) as new_with_part_d
    FROM monthly_snapshots
    WHERE contract_effective_date IS NOT NULL
    GROUP BY 1, 2, 3
)

SELECT 
    entry_month,
    organization_type,
    plan_type,
    new_contracts,
    new_with_part_d,
    ROUND(new_with_part_d * 100.0 / new_contracts, 1) as pct_with_part_d
FROM new_entries
WHERE entry_month >= ADD_MONTHS(CURRENT_DATE, -36)  -- Focus on last 3 years
ORDER BY 
    entry_month DESC,
    new_contracts DESC;

-- How this query works:
-- 1. Creates monthly snapshots to eliminate duplicate records
-- 2. Identifies new market entrants based on contract effective dates
-- 3. Calculates key metrics about new entrants including Part D adoption
-- 4. Focuses on recent 3-year period for actionable insights

-- Assumptions and Limitations:
-- - Contract effective dates are accurate and complete
-- - Analysis focuses on initial market entry, not subsequent changes
-- - Three-year window provides relevant recent trends
-- - Does not account for contracts that may have exited the market

-- Possible Extensions:
-- 1. Add geographic analysis by joining with county-level data
-- 2. Compare entry patterns of large vs. small parent organizations
-- 3. Analyze seasonal patterns in market entry timing
-- 4. Include SNP and EGHP adoption trends for new entrants
-- 5. Calculate market entry success rates by comparing with enrollment data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T12:56:21.815863
    - Additional Notes: Query is optimized for analyzing market entry patterns over a rolling 36-month period. Results may vary based on data freshness in mimi_src_file_date. Consider adjusting the time window in ADD_MONTHS() for different analysis periods.
    
    */