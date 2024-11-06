/*
PACE Rate Book Payment Rate Trends by State
Author: Healthcare Analytics Team
Purpose: Analyze year-over-year trends in PACE payment rates at the state level to identify 
growth opportunities and market dynamics
*/

WITH yearly_state_rates AS (
    -- Calculate average rates and year-over-year changes by state
    SELECT 
        state,
        YEAR(mimi_src_file_date) as rate_year,
        COUNT(DISTINCT code) as county_count,
        ROUND(AVG(parts_ab_rate), 2) as avg_non_esrd_rate,
        ROUND(AVG(parts_ab_esrd_rate), 2) as avg_esrd_rate
    FROM mimi_ws_1.cmspayment.pace_ratebook
    GROUP BY state, YEAR(mimi_src_file_date)
),

state_growth AS (
    -- Calculate year-over-year growth rates
    SELECT 
        state,
        rate_year,
        county_count,
        avg_non_esrd_rate,
        avg_esrd_rate,
        ROUND(((avg_non_esrd_rate - LAG(avg_non_esrd_rate) OVER (PARTITION BY state ORDER BY rate_year)) 
            / LAG(avg_non_esrd_rate) OVER (PARTITION BY state ORDER BY rate_year) * 100), 1) as yoy_growth_pct
    FROM yearly_state_rates
)

SELECT 
    state,
    rate_year,
    county_count,
    avg_non_esrd_rate,
    avg_esrd_rate,
    yoy_growth_pct,
    -- Flag high-growth opportunities
    CASE 
        WHEN yoy_growth_pct > 5 THEN 'High Growth'
        WHEN yoy_growth_pct > 0 THEN 'Moderate Growth'
        ELSE 'Flat/Declining'
    END as growth_category
FROM state_growth
WHERE rate_year >= YEAR(CURRENT_DATE) - 3  -- Focus on recent years
ORDER BY state, rate_year DESC;

/*
How This Query Works:
1. Creates a summary of average PACE rates by state and year
2. Calculates year-over-year growth rates for each state
3. Categorizes states based on growth patterns
4. Focuses on the most recent 3 years of data

Assumptions & Limitations:
- Assumes mimi_src_file_date represents the effective date for rates
- State-level averages may mask county-level variations
- Growth rates are simplified and don't account for factors like inflation

Possible Extensions:
1. Add population weighting to state averages
2. Include geographic region groupings for regional analysis
3. Incorporate minimum/maximum county rates within each state
4. Add filters for specific states or growth thresholds
5. Compare ESRD vs non-ESRD growth rates
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:06:40.939922
    - Additional Notes: Query focuses on state-level trends and may need adjustment for states with varying county counts or population distributions. Consider adding population weighting for more accurate market analysis. Growth rate calculations assume linear year-over-year progression.
    
    */