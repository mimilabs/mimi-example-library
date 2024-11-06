-- high_risk_healthcare_counties_2018.sql

/*
Business Purpose:
This query identifies counties with both high healthcare needs and access barriers by analyzing
the intersection of uninsured rates, disability prevalence, and elderly populations.
This analysis helps healthcare organizations and policymakers:
- Target locations for new healthcare facilities or mobile health units
- Prioritize telehealth program expansion
- Allocate resources for community health workers
- Design specialized outreach programs for vulnerable populations
*/

WITH healthcare_metrics AS (
    -- Calculate key healthcare vulnerability indicators
    SELECT 
        state,
        county,
        e_totpop AS total_population,
        ep_uninsur AS pct_uninsured,
        ep_age65 AS pct_elderly,
        ep_disabl AS pct_disabled,
        ep_noveh AS pct_no_vehicle,
        ep_pov AS pct_poverty
    FROM mimi_ws_1.cdc.svi_county_y2018
    WHERE e_totpop > 1000  -- Focus on counties with meaningful population size
),

risk_scores AS (
    -- Calculate composite risk score based on multiple factors
    SELECT 
        state,
        county,
        total_population,
        ROUND((pct_uninsured + pct_elderly + pct_disabled + pct_no_vehicle + pct_poverty) / 5, 2) AS composite_risk_score
    FROM healthcare_metrics
)

-- Identify and rank highest-risk counties
SELECT 
    state,
    county,
    total_population,
    composite_risk_score,
    RANK() OVER (PARTITION BY state ORDER BY composite_risk_score DESC) as risk_rank_in_state
FROM risk_scores
WHERE composite_risk_score > 20  -- Focus on counties with above-average risk
ORDER BY composite_risk_score DESC, total_population DESC
LIMIT 100;

/*
How it works:
1. First CTE establishes baseline healthcare vulnerability metrics
2. Second CTE creates a composite risk score
3. Final query ranks counties and filters to highest risk areas

Assumptions and Limitations:
- Equal weighting of risk factors in composite score
- Population threshold may exclude some small but high-need rural areas
- Does not account for proximity to healthcare facilities
- Based on 2018 data which may not reflect current conditions

Possible Extensions:
1. Add geographic clustering analysis to identify regional patterns
2. Include healthcare facility density from external data sources
3. Create separate risk scores for different population segments
4. Add time-based analysis using historical data
5. Include Medicare/Medicaid enrollment data if available
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:04:47.306729
    - Additional Notes: The composite risk score calculation uses a simplified averaging approach that may need adjustment based on specific program priorities. Consider local healthcare infrastructure data and geographical distance factors for more precise risk assessment.
    
    */