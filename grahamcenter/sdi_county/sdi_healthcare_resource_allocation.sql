-- Social Deprivation Index (SDI) Healthcare Resource Allocation Analysis
-- Purpose: Identify counties with healthcare resource needs based on SDI scores and population size
-- Demonstrates strategic insights for healthcare planning and targeted interventions

WITH county_sdi_ranking AS (
    -- Rank counties by SDI score, population, and key socioeconomic indicators
    SELECT 
        county_fips,
        sdi_score,
        county_population,
        sdi,
        pct_poverty_lt100,
        pct_education_lt12years,
        pct_non_employed,
        
        -- Calculate a composite vulnerability score
        ROUND(
            (sdi_score * 0.4) +  -- SDI score weighted importance
            (pct_poverty_lt100 * 0.2) +  -- Poverty impact
            (pct_education_lt12years * 0.2) +  -- Education factor
            (pct_non_employed * 0.2),  -- Employment indicator
        2) AS vulnerability_index,

        -- Tier counties into resource allocation categories
        CASE 
            WHEN sdi_score > 0.75 THEN 'High Priority'
            WHEN sdi_score > 0.5 THEN 'Medium Priority'
            ELSE 'Low Priority'
        END AS resource_allocation_tier,

        -- Relative scale of potential healthcare intervention needs
        ROUND(sdi_score * county_population / 1000, 0) AS intervention_scale_score,

        mimi_src_file_date
    FROM 
        mimi_ws_1.grahamcenter.sdi_county
    WHERE 
        mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.grahamcenter.sdi_county)
)

SELECT 
    county_fips,
    sdi_score,
    county_population,
    vulnerability_index,
    resource_allocation_tier,
    intervention_scale_score
FROM 
    county_sdi_ranking
WHERE 
    resource_allocation_tier IN ('High Priority', 'Medium Priority')
ORDER BY 
    vulnerability_index DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Uses most recent SDI dataset
-- 2. Creates composite vulnerability index
-- 3. Categorizes counties by resource allocation needs
-- 4. Ranks counties based on intervention potential

-- Assumptions:
-- - SDI score is a reliable indicator of socioeconomic challenges
-- - Population size correlates with healthcare resource requirements
-- - Weights assigned to vulnerability index are representative

-- Potential Extensions:
-- 1. Add geospatial analysis by state/region
-- 2. Integrate with healthcare utilization data
-- 3. Time-series trend analysis of SDI changes

-- Business Value:
-- Enables targeted healthcare resource allocation
-- Supports strategic planning for community health interventions
-- Identifies counties with highest social deprivation risks

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:48:45.458052
    - Additional Notes: Query leverages Social Deprivation Index to prioritize healthcare resource needs based on county-level vulnerability. Intended for strategic planning and targeted interventions in public health policy.
    
    */