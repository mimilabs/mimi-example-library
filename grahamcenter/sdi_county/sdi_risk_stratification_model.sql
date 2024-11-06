-- County Social Deprivation Risk Stratification Model
-- Purpose: Categorize counties into risk tiers based on SDI scores and their core components
--          to support population health management and resource allocation decisions.
-- Valuable for: Healthcare payers, public health departments, and community health organizations

WITH ranked_counties AS (
    -- Get most recent SDI data and calculate component averages
    SELECT 
        county_fips,
        county_population,
        sdi_score,
        (education_lt12years_score + povertylt100_fpl_score + nonemployed_score)/3 as socioeconomic_risk,
        (hh_no_vehicle_score + hh_renter_occupied_score + hh_crowding_score)/3 as housing_risk,
        single_parent_fam_score as family_risk,
        CASE 
            WHEN sdi_score >= 75 THEN 'High Risk'
            WHEN sdi_score >= 50 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END as risk_tier
    FROM mimi_ws_1.grahamcenter.sdi_county
    WHERE mimi_src_file_date = (
        SELECT MAX(mimi_src_file_date) 
        FROM mimi_ws_1.grahamcenter.sdi_county
    )
)
SELECT 
    risk_tier,
    COUNT(*) as county_count,
    SUM(county_population) as total_population,
    ROUND(AVG(socioeconomic_risk), 1) as avg_socioeconomic_risk,
    ROUND(AVG(housing_risk), 1) as avg_housing_risk,
    ROUND(AVG(family_risk), 1) as avg_family_risk
FROM ranked_counties
GROUP BY risk_tier
ORDER BY 
    CASE risk_tier 
        WHEN 'High Risk' THEN 1
        WHEN 'Medium Risk' THEN 2
        WHEN 'Low Risk' THEN 3
    END;

-- How it works:
-- 1. Selects most recent SDI data using subquery
-- 2. Calculates composite risk scores for key social determinant domains
-- 3. Assigns risk tiers based on SDI score thresholds
-- 4. Aggregates population and risk metrics by tier
-- 5. Orders results from highest to lowest risk

-- Assumptions and Limitations:
-- - Uses equal weighting for component scores within domains
-- - Risk tier thresholds (75/50) are illustrative and may need adjustment
-- - Most recent data may not reflect current conditions
-- - County-level analysis masks within-county variation

-- Possible Extensions:
-- 1. Add year-over-year risk tier migration analysis
-- 2. Include geographic clustering of high-risk counties
-- 3. Correlate with health outcome data
-- 4. Create custom risk scoring algorithms
-- 5. Add demographic factors for more detailed stratification

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:05:02.893508
    - Additional Notes: This query introduces a three-tier risk stratification model based on SDI scores, with composite domain scores for socioeconomic, housing, and family risks. The 75th and 50th percentile thresholds used for risk tiers should be validated against local population health data before implementation in production environments.
    
    */