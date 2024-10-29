-- Title: Medicare Opt-Out Provider PECOS Referral Network Impact Analysis

-- Business Purpose:
-- Analyzes the impact of Medicare opt-out providers on potential referral networks by identifying
-- providers who can still order and refer while opted out. This helps healthcare organizations
-- understand referral network gaps and opportunities, particularly important for:
-- - Health systems planning their referral networks
-- - Medical device companies targeting ordering physicians
-- - Healthcare consultants advising on network optimization

-- Main Query
WITH active_optout AS (
    SELECT 
        npi,
        first_name,
        last_name,
        specialty,
        eligible_to_order_and_refer,
        state_code,
        optout_effective_date,
        optout_end_date
    FROM mimi_ws_1.datacmsgov.optout
    WHERE optout_end_date >= CURRENT_DATE()
        AND last_updated = (SELECT MAX(last_updated) FROM mimi_ws_1.datacmsgov.optout)
),

referral_summary AS (
    SELECT 
        specialty,
        state_code,
        COUNT(*) as total_providers,
        SUM(CASE WHEN eligible_to_order_and_refer = 'Y' THEN 1 ELSE 0 END) as can_refer_count,
        ROUND(100.0 * SUM(CASE WHEN eligible_to_order_and_refer = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 2) as pct_can_refer
    FROM active_optout
    GROUP BY specialty, state_code
)

SELECT 
    specialty,
    state_code,
    total_providers,
    can_refer_count,
    pct_can_refer
FROM referral_summary
WHERE total_providers >= 5  -- Focus on specialties with meaningful presence
ORDER BY total_providers DESC, pct_can_refer DESC
LIMIT 20;

-- Query Operation Notes:
-- 1. Creates temp table of currently active opt-out providers
-- 2. Calculates referral eligibility metrics by specialty and state
-- 3. Filters for statistically significant populations
-- 4. Orders results by provider count and referral eligibility percentage

-- Assumptions & Limitations:
-- - Assumes current opt-out status based on end_date
-- - Limited to specialties with 5+ providers for statistical relevance
-- - Does not account for historical changes in referral eligibility
-- - State-level analysis may mask local market dynamics

-- Potential Extensions:
-- 1. Add temporal analysis to track referral network changes over time
-- 2. Include geographic clustering analysis at MSA/county level
-- 3. Cross-reference with Medicare claims data to quantify referral volume impact
-- 4. Add specialty-specific breakdowns for key referral patterns
-- 5. Incorporate provider demographic data for deeper insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:21:45.074395
    - Additional Notes: Query focuses on active referral network impacts, requiring table access permissions and recent data updates. Performance may be impacted with very large datasets due to window functions and multiple aggregations. Consider adding indexes on optout_end_date and specialty columns for optimization.
    
    */