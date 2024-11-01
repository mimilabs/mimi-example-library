-- Title: High-Risk Senior Population Centers Analysis Using SVI 2018
-- Business Purpose: Identifies census tracts with concentrated vulnerable elderly populations
-- to support healthcare organizations in strategic planning for senior care services,
-- emergency preparedness, and community health program deployment.

WITH elderly_risk_factors AS (
    -- Calculate composite risk score for elderly populations
    SELECT 
        state,
        county,
        location,
        e_totpop,
        e_age65,
        ep_age65,
        ep_disabl,
        ep_uninsur,
        ep_pov,
        ep_noveh,
        -- Create weighted risk score
        (ep_age65 * 0.4 + 
         ep_disabl * 0.2 + 
         ep_uninsur * 0.2 + 
         ep_pov * 0.1 +
         ep_noveh * 0.1) as elderly_risk_score
    FROM mimi_ws_1.cdc.svi_censustract_y2018
    WHERE e_totpop >= 100  -- Filter out very small populations
    AND ep_age65 > 0      -- Ensure elderly population exists
),

risk_categories AS (
    -- Categorize tracts by risk level
    SELECT 
        *,
        CASE 
            WHEN elderly_risk_score >= 75 THEN 'Very High Risk'
            WHEN elderly_risk_score >= 50 THEN 'High Risk'
            WHEN elderly_risk_score >= 25 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END as risk_category
    FROM elderly_risk_factors
)

SELECT 
    state,
    county,
    risk_category,
    COUNT(*) as tract_count,
    SUM(e_age65) as total_elderly_pop,
    ROUND(AVG(ep_age65), 1) as avg_elderly_pct,
    ROUND(AVG(ep_disabl), 1) as avg_disability_pct,
    ROUND(AVG(ep_uninsur), 1) as avg_uninsured_pct,
    ROUND(AVG(ep_noveh), 1) as avg_no_vehicle_pct
FROM risk_categories
GROUP BY state, county, risk_category
HAVING total_elderly_pop >= 1000
ORDER BY state, county, 
    CASE risk_category
        WHEN 'Very High Risk' THEN 1
        WHEN 'High Risk' THEN 2
        WHEN 'Moderate Risk' THEN 3
        WHEN 'Low Risk' THEN 4
    END;

-- How the Query Works:
-- 1. Creates elderly_risk_factors CTE to calculate a weighted composite risk score
-- 2. Creates risk_categories CTE to segment tracts into risk levels
-- 3. Aggregates results by state, county, and risk category
-- 4. Applies minimum population thresholds to focus on significant populations

-- Assumptions and Limitations:
-- - Weights in risk score calculation are simplified and may need adjustment
-- - Focuses only on elderly population risks, excluding other vulnerable groups
-- - Does not account for proximity to healthcare facilities
-- - Census tract boundaries may not align with service areas

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify concentrated risk areas
-- 2. Include proximity to hospitals or healthcare facilities
-- 3. Compare against Medicare Advantage penetration rates
-- 4. Add temporal analysis using historical SVI data
-- 5. Include additional demographic factors like income levels
-- 6. Calculate potential market size for senior care services

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:52:43.795577
    - Additional Notes: The query uses a weighted scoring system (40% elderly population, 20% disability, 20% uninsured, 10% poverty, 10% no vehicle) to identify high-risk areas for senior healthcare planning. Minimum thresholds of 100 total population per tract and 1000 elderly persons per county are applied to ensure statistical significance.
    
    */