
/*******************************************************************************
Title: Medicare Provider Opt-Out Analysis by Specialty and State

Business Purpose:
This query analyzes the distribution of healthcare providers who have opted out 
of Medicare across different specialties and states. Understanding these patterns
helps identify:
- Which medical specialties have higher opt-out rates
- Geographic variations in Medicare participation
- Current active opt-out status trends

This information is valuable for:
- Healthcare policy planning
- Provider network management 
- Access to care analysis
*******************************************************************************/

WITH current_optouts AS (
    -- Filter to only currently active opt-outs
    SELECT *
    FROM mimi_ws_1.datacmsgov.optout
    WHERE optout_effective_date <= current_date()
    AND optout_end_date >= current_date()
)

SELECT 
    -- Group providers by specialty and state
    specialty,
    state_code,
    
    -- Calculate key metrics
    COUNT(*) as provider_count,
    COUNT(DISTINCT city_name) as unique_cities,
    
    -- Calculate percentage eligible to order/refer
    ROUND(100.0 * SUM(CASE WHEN eligible_to_order_and_refer = 'Y' THEN 1 ELSE 0 END) 
          / COUNT(*), 1) as pct_eligible_refer,
          
    -- Get most recent opt-out date
    MAX(optout_effective_date) as latest_optout_date

FROM current_optouts

GROUP BY specialty, state_code

-- Focus on meaningful groupings
HAVING COUNT(*) >= 5

-- Order by volume
ORDER BY provider_count DESC

LIMIT 20;

/*******************************************************************************
How this query works:
1. Creates CTE of currently opted-out providers
2. Groups providers by specialty and state
3. Calculates summary metrics for each group
4. Filters to groups with at least 5 providers
5. Orders by total provider count

Assumptions & Limitations:
- Only includes currently active opt-outs
- Minimum group size of 5 providers
- Does not account for historical trends
- Specialty and state fields assumed to be standardized

Possible Extensions:
1. Add year-over-year trend analysis
2. Include geographic clustering analysis
3. Add provider demographic breakdowns
4. Compare to total provider populations
5. Analyze opt-out duration patterns
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:48:20.783280
    - Additional Notes: Query focuses on active opt-outs only and requires minimum group size of 5 providers. Results are limited to top 20 specialty-state combinations by volume. The effective/end date filtering assumes dates are in valid format and timezone settings are properly configured.
    
    */