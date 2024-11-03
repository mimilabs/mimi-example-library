-- Title: Geographic Technology Market Share Analysis for Healthcare IT Vendors

/* Business Purpose:
This query analyzes market share and penetration of healthcare IT vendors across different
states/territories to:
- Identify dominant vendors in each region
- Highlight opportunities for market expansion
- Support strategic partner selection decisions
- Guide sales territory planning and resource allocation
*/

WITH vendor_state_stats AS (
    -- Calculate vendor presence by state
    SELECT 
        practice_state_or_us_territory as state,
        developer,
        COUNT(DISTINCT provider_key) as provider_count,
        COUNT(DISTINCT grp_key) as practice_count
    FROM mimi_ws_1.healthit.chit_cpip
    GROUP BY practice_state_or_us_territory, developer
),

state_totals AS (
    -- Get total providers and practices per state for market share calculation
    SELECT 
        practice_state_or_us_territory as state,
        COUNT(DISTINCT provider_key) as total_providers,
        COUNT(DISTINCT grp_key) as total_practices
    FROM mimi_ws_1.healthit.chit_cpip
    GROUP BY practice_state_or_us_territory
)

SELECT 
    vs.state,
    vs.developer,
    vs.provider_count,
    vs.practice_count,
    ROUND(100.0 * vs.provider_count / st.total_providers, 2) as provider_market_share,
    ROUND(100.0 * vs.practice_count / st.total_practices, 2) as practice_market_share,
    st.total_providers as state_total_providers,
    st.total_practices as state_total_practices
FROM vendor_state_stats vs
JOIN state_totals st ON vs.state = st.state
WHERE vs.provider_count >= 10  -- Filter for meaningful market presence
ORDER BY 
    vs.state,
    vs.provider_count DESC

/* How this query works:
1. First CTE calculates provider and practice counts by vendor for each state
2. Second CTE gets state-level totals for market share calculation
3. Main query joins these together to calculate market share percentages
4. Results filtered to show only vendors with significant presence

Assumptions and Limitations:
- Assumes provider_key and grp_key are reliable identifiers
- Market share based on count of providers/practices, not revenue
- Current state location may not reflect historical adoption patterns
- Small sample sizes in some states may affect percentages

Possible Extensions:
1. Add time-based trending using mimi_src_file_date
2. Include practice size segments for more detailed analysis
3. Compare market share across editions (2014 vs 2015)
4. Add geographic regions/divisions for regional analysis
5. Incorporate specialty focus for targeted market analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:47:57.654802
    - Additional Notes: Query provides geographic market penetration metrics for health IT vendors but may underrepresent small practices or rural areas due to the 10-provider minimum threshold. Market share calculations are based on provider/practice counts rather than revenue or patient volume, which may not fully reflect vendor market dominance.
    
    */