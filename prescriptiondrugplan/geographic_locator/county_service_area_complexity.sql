-- Title: County-Level Medicare Plan Service Area Distribution
-- Business Purpose: Analyze geographic diversity and service area distribution patterns
-- at the county level to understand Medicare plan accessibility and potential coverage gaps.
-- This helps identify underserved areas and opportunities for market expansion.

WITH county_stats AS (
    -- Calculate service area metrics per county
    SELECT 
        statename,
        county,
        ma_region_code,
        pdp_region_code,
        -- Get most recent data per county
        MAX(mimi_src_file_date) as latest_data_date
    FROM mimi_ws_1.prescriptiondrugplan.geographic_locator
    GROUP BY 
        statename,
        county,
        ma_region_code,
        pdp_region_code
),

state_summary AS (
    -- Aggregate metrics at state level
    SELECT 
        statename,
        COUNT(DISTINCT county) as total_counties,
        COUNT(DISTINCT ma_region_code) as unique_ma_regions,
        COUNT(DISTINCT pdp_region_code) as unique_pdp_regions,
        -- Calculate service area density
        ROUND(COUNT(DISTINCT pdp_region_code)::DECIMAL / 
              COUNT(DISTINCT county)::DECIMAL, 2) as pdp_region_per_county_ratio
    FROM county_stats
    GROUP BY statename
)

-- Generate final ranked analysis
SELECT 
    statename,
    total_counties,
    unique_ma_regions,
    unique_pdp_regions,
    pdp_region_per_county_ratio,
    -- Identify states with high service area complexity
    CASE 
        WHEN pdp_region_per_county_ratio > 0.5 THEN 'High Complexity'
        WHEN pdp_region_per_county_ratio > 0.25 THEN 'Medium Complexity'
        ELSE 'Low Complexity'
    END as service_area_complexity
FROM state_summary
ORDER BY pdp_region_per_county_ratio DESC, total_counties DESC;

-- How This Query Works:
-- 1. First CTE establishes baseline county-level metrics
-- 2. Second CTE aggregates to state level and calculates key ratios
-- 3. Final query adds complexity categorization and sorts results

-- Assumptions and Limitations:
-- 1. Assumes current data is most relevant (uses latest_data_date)
-- 2. Does not account for population density or demographic factors
-- 3. Complexity categorization thresholds are arbitrary and may need adjustment
-- 4. Does not consider historical trends or changes over time

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in service area distribution
-- 2. Include population data to weight the analysis
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Incorporate plan enrollment data to measure market penetration
-- 5. Add rural vs urban classification to understand accessibility patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:45:32.977652
    - Additional Notes: Query calculates service area density ratios per state and assigns complexity levels based on PDP region distribution. High ratios indicate more complex service area management needs. Consider adjusting complexity thresholds (0.5, 0.25) based on specific business requirements.
    
    */