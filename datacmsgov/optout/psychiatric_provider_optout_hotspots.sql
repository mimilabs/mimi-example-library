-- Title: Medicare Opt-Out Provider Population Health Risk Analysis

-- Business Purpose:
-- This query identifies geographical areas where high concentrations of psychiatric providers 
-- have opted out of Medicare, potentially indicating mental health access gaps for Medicare
-- beneficiaries. This analysis supports population health management, care delivery planning,
-- and targeted intervention strategies.

WITH psychiatric_providers AS (
    SELECT 
        state_code,
        city_name,
        specialty,
        COUNT(*) as provider_count,
        COUNT(CASE WHEN optout_end_date > CURRENT_DATE() THEN 1 END) as active_provider_count
    FROM mimi_ws_1.datacmsgov.optout
    WHERE specialty LIKE '%PSYCHIATR%'
        AND last_updated = (SELECT MAX(last_updated) FROM mimi_ws_1.datacmsgov.optout)
    GROUP BY 
        state_code,
        city_name,
        specialty
),

provider_rankings AS (
    SELECT 
        state_code,
        city_name,
        specialty,
        provider_count,
        active_provider_count,
        -- Calculate percentage of active opt-outs
        ROUND(active_provider_count * 100.0 / provider_count, 1) as active_optout_pct,
        -- Rank cities by opt-out volume
        ROW_NUMBER() OVER (PARTITION BY state_code ORDER BY provider_count DESC) as city_rank
    FROM psychiatric_providers
    WHERE provider_count >= 5  -- Focus on meaningful population centers
)

SELECT 
    state_code as state,
    city_name as city,
    specialty as provider_type,
    provider_count as total_optout_providers,
    active_provider_count as currently_opted_out,
    active_optout_pct as active_optout_pct,
    city_rank as city_rank_in_state
FROM provider_rankings
WHERE city_rank <= 10  -- Top 10 cities per state
ORDER BY 
    provider_count DESC,
    state_code,
    city_rank;

-- How the Query Works:
-- 1. First CTE filters for psychiatric providers and gets basic counts
-- 2. Second CTE adds rankings and percentage calculations
-- 3. Final SELECT formats and filters for top cities

-- Assumptions and Limitations:
-- - Assumes current psychiatric provider opt-outs represent access gaps
-- - Limited to cities with 5+ providers to ensure statistical relevance
-- - Does not account for total Medicare beneficiary population in each area
-- - May not capture providers who have relocated or retired

-- Possible Extensions:
-- 1. Add Medicare beneficiary density data to calculate true access ratios
-- 2. Include year-over-year trend analysis for each geographic area
-- 3. Expand to include other mental health providers (e.g., psychologists)
-- 4. Add demographic data to identify vulnerable populations in high opt-out areas
-- 5. Compare opt-out rates with local mental health outcome metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:43:44.521239
    - Additional Notes: Query focuses specifically on psychiatric care access risks by identifying geographic clusters of Medicare opt-outs. The 5-provider minimum threshold may need adjustment for rural areas. Active opt-out percentage calculation assumes current date comparison is valid measure of active status.
    
    */