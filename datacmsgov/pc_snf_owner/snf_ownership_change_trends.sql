-- snf_ownership_transitions.sql
-- Analyzes ownership changes and transitions in Skilled Nursing Facilities (SNFs)
-- to identify acquisition patterns and ownership stability
--
-- Business Purpose:
-- - Identify SNFs with recent ownership changes for M&A targeting
-- - Assess ownership stability in different regions
-- - Support due diligence by revealing ownership transfer patterns
-- - Enable market entry strategy by understanding ownership dynamics

WITH recent_transitions AS (
    -- Get ownership transitions by comparing association dates
    SELECT 
        organization_name,
        state_owner,
        association_date_owner,
        type_owner,
        role_text_owner,
        percentage_ownership,
        -- Flag if created specifically for acquisition
        created_for_acquisition_owner,
        -- Calculate days since association
        DATEDIFF(current_date(), association_date_owner) as days_since_association
    FROM mimi_ws_1.datacmsgov.pc_snf_owner
    WHERE association_date_owner IS NOT NULL
),

ownership_summary AS (
    -- Summarize ownership patterns
    SELECT
        state_owner,
        COUNT(DISTINCT organization_name) as total_facilities,
        COUNT(CASE WHEN days_since_association <= 365 THEN 1 END) as recent_transitions,
        AVG(percentage_ownership) as avg_ownership_stake,
        COUNT(CASE WHEN created_for_acquisition_owner = 'Y' THEN 1 END) as acquisition_vehicles
    FROM recent_transitions
    GROUP BY state_owner
)

SELECT
    state_owner,
    total_facilities,
    recent_transitions,
    ROUND(recent_transitions * 100.0 / total_facilities, 1) as pct_recent_transition,
    ROUND(avg_ownership_stake, 1) as avg_ownership_stake,
    acquisition_vehicles
FROM ownership_summary
WHERE total_facilities >= 5  -- Filter for meaningful state-level data
ORDER BY pct_recent_transition DESC;

-- How this query works:
-- 1. Creates CTE for ownership transitions using association dates
-- 2. Summarizes transitions and ownership patterns by state
-- 3. Calculates key metrics like recent transition % and average ownership stake
-- 4. Filters for states with meaningful sample sizes
--
-- Assumptions & Limitations:
-- - Association dates are reliable indicators of ownership changes
-- - Recent defined as within last 365 days
-- - May not capture complex ownership structures or indirect control
-- - Limited to states with 5+ facilities for statistical relevance
--
-- Possible Extensions:
-- - Add time series analysis of ownership transition patterns
-- - Include facility size/revenue in analysis
-- - Compare chain vs independent ownership transitions
-- - Incorporate quality metrics to assess impact of ownership changes
-- - Add geographic clustering analysis of ownership changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:25:31.011363
    - Additional Notes: Query focuses on ownership transition patterns in SNFs at the state level. Requires reliable association_date_owner data and sufficient facility count per state for meaningful analysis. Consider adjusting the 365-day window and 5-facility threshold based on specific analysis needs.
    
    */