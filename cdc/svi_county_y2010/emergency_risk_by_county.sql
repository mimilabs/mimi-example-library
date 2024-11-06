-- emergency_response_prioritization.sql
-- Business Purpose:
-- Help emergency response planners identify counties that need the most support
-- during health emergencies by combining multiple vulnerability factors.
-- This focuses on practical resource allocation decisions.

WITH county_risk_factors AS (
    -- Calculate key risk metrics for each county
    SELECT 
        st,
        location,
        totpop,
        -- Economic vulnerability
        e_p_pov AS poverty_rate,
        -- Healthcare access risk
        e_p_noveh AS no_vehicle_rate,
        -- Language barrier risk
        e_p_limeng AS limited_english_rate,
        -- Housing vulnerability 
        e_p_crowd AS crowded_housing_rate,
        -- Overall SVI ranking
        r_pl_themes AS overall_vulnerability_rank
    FROM mimi_ws_1.cdc.svi_county_y2010
    WHERE totpop > 0  -- Exclude unpopulated areas
),

high_risk_counties AS (
    -- Identify counties with multiple high-risk factors
    SELECT 
        st,
        location,
        totpop,
        overall_vulnerability_rank,
        -- Flag counties with multiple risk factors
        CASE WHEN (poverty_rate > 0.2 
              AND limited_english_rate > 0.1
              AND (no_vehicle_rate > 0.1 OR crowded_housing_rate > 0.1))
             THEN 'High Risk'
             ELSE 'Standard Risk' 
        END AS risk_category
    FROM county_risk_factors
)

-- Final output showing priority counties for emergency planning
SELECT 
    st AS state,
    location,
    FORMAT_NUMBER(totpop, 0) AS population,
    ROUND(overall_vulnerability_rank, 2) AS vulnerability_percentile,
    risk_category,
    COUNT(*) OVER (PARTITION BY st, risk_category) AS counties_in_category_per_state
FROM high_risk_counties
WHERE risk_category = 'High Risk'
ORDER BY st, overall_vulnerability_rank DESC;

-- How this query works:
-- 1. Extracts key vulnerability metrics from the SVI dataset
-- 2. Applies practical thresholds to identify high-risk counties
-- 3. Summarizes results by state for emergency planning purposes

-- Assumptions and Limitations:
-- - Uses fixed thresholds that may need adjustment based on local context
-- - Based on 2010 data - current situations may differ
-- - Focuses on combined risk factors rather than individual measures
-- - Simplified risk categorization for practical use

-- Possible Extensions:
-- 1. Add population density calculations for resource distribution planning
-- 2. Include nearby hospital capacity data for healthcare response planning
-- 3. Incorporate natural disaster risk zones for combined risk assessment
-- 4. Add trend analysis by comparing with other years' data
-- 5. Create state-specific thresholds based on local conditions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:15:17.282207
    - Additional Notes: Query identifies high-risk counties for emergency response planning using multi-factor vulnerability analysis. Risk thresholds (20% poverty, 10% limited English, etc.) are hardcoded and may need adjustment based on regional requirements. Includes state-level aggregation for coordinated response planning.
    
    */