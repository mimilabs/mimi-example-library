-- Title: Census Tract Analysis of Healthcare Access Risk Factors - 2018
-- Business Purpose: Identifies census tracts with multiple barriers to healthcare access,
-- combining uninsurance rates with social vulnerability factors like poverty, 
-- transportation limitations, and language barriers. This analysis helps healthcare
-- organizations target outreach and service expansion to high-need areas.

WITH healthcare_barriers AS (
    -- Calculate combined risk factors at census tract level
    SELECT 
        state,
        county,
        location,
        e_totpop as population,
        ep_uninsur as uninsured_pct,
        ep_noveh as no_vehicle_pct,
        ep_limeng as limited_english_pct,
        ep_pov as poverty_pct,
        CASE 
            WHEN ep_uninsur > 20 
            AND ep_noveh > 10 
            AND (ep_limeng > 5 OR ep_pov > 20)
            THEN 'High Risk'
            WHEN ep_uninsur > 15 
            AND (ep_noveh > 5 OR ep_limeng > 3 OR ep_pov > 15)
            THEN 'Medium Risk'
            ELSE 'Lower Risk'
        END as access_risk_level
    FROM mimi_ws_1.cdc.svi_censustract_y2018
    WHERE e_totpop >= 500  -- Focus on populated areas
)

SELECT 
    state,
    access_risk_level,
    COUNT(*) as tract_count,
    SUM(population) as total_population,
    ROUND(AVG(uninsured_pct),1) as avg_uninsured_pct,
    ROUND(AVG(no_vehicle_pct),1) as avg_no_vehicle_pct,
    ROUND(AVG(limited_english_pct),1) as avg_limited_english_pct,
    ROUND(AVG(poverty_pct),1) as avg_poverty_pct
FROM healthcare_barriers
GROUP BY state, access_risk_level
HAVING tract_count >= 5  -- Show meaningful groupings
ORDER BY state, access_risk_level;

-- How it works:
-- 1. Creates a CTE that evaluates each census tract based on key healthcare access barriers
-- 2. Assigns risk levels using combined threshold criteria
-- 3. Aggregates results by state and risk level to show population impact
-- 4. Includes average percentages for key metrics to understand barrier intensity

-- Assumptions and Limitations:
-- - Assumes tracts with population <500 are not meaningful for analysis
-- - Risk level thresholds are illustrative and should be validated
-- - Does not account for proximity to healthcare facilities
-- - Some tracts may have missing data for certain metrics

-- Possible Extensions:
-- 1. Add geographic clustering to identify contiguous high-risk areas
-- 2. Include healthcare facility density from external sources
-- 3. Create year-over-year comparison when newer data becomes available
-- 4. Add demographic breakdowns within risk levels
-- 5. Calculate distance to nearest emergency department or FQHC

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:35:54.956670
    - Additional Notes: Query identifies census tracts with healthcare access barriers by combining uninsurance rates with social determinants. Risk level thresholds (20%, 15%, etc.) may need adjustment based on local contexts. Minimum population filter of 500 may need to be modified for rural area analysis.
    
    */