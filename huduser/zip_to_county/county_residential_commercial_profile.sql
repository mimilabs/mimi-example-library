-- zip_to_county_residential_business_analysis.sql
-- Business Purpose: Analyze the distribution of residential vs business addresses across counties
-- to identify areas with high residential or commercial concentration. This information is valuable for:
-- - Real estate investment decisions
-- - Urban planning and zoning
-- - Economic development initiatives
-- - Market analysis for retail/commercial expansion

WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT DISTINCT mimi_src_file_date
    FROM mimi_ws_1.huduser.zip_to_county 
    ORDER BY mimi_src_file_date DESC
    LIMIT 1
),

county_metrics AS (
    -- Calculate weighted averages for each county
    SELECT 
        county,
        usps_zip_pref_state,
        COUNT(DISTINCT zip) as zip_count,
        ROUND(AVG(res_ratio * 100), 2) as avg_residential_ratio,
        ROUND(AVG(bus_ratio * 100), 2) as avg_business_ratio,
        ROUND(SUM(CASE WHEN res_ratio > bus_ratio THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as pct_residential_dominant
    FROM mimi_ws_1.huduser.zip_to_county z
    WHERE mimi_src_file_date = (SELECT mimi_src_file_date FROM latest_data)
    GROUP BY county, usps_zip_pref_state
)

-- Identify counties with distinct residential/business characteristics
SELECT 
    usps_zip_pref_state as state,
    county,
    zip_count,
    avg_residential_ratio as avg_pct_residential,
    avg_business_ratio as avg_pct_business,
    pct_residential_dominant as pct_residential_zip_codes,
    CASE 
        WHEN avg_residential_ratio >= 75 THEN 'Primarily Residential'
        WHEN avg_business_ratio >= 25 THEN 'High Commercial Activity'
        ELSE 'Mixed Use'
    END as county_classification
FROM county_metrics
ORDER BY 
    usps_zip_pref_state,
    avg_residential_ratio DESC;

-- How this query works:
-- 1. Gets the most recent data snapshot using a CTE
-- 2. Aggregates ZIP-level data to county level, calculating key metrics
-- 3. Classifies counties based on their residential/business composition
-- 4. Orders results by state and residential concentration

-- Assumptions and Limitations:
-- - Uses only the most recent data snapshot
-- - Assumes ZIP codes within a county have equal weight
-- - Classification thresholds are somewhat arbitrary and may need adjustment
-- - Does not account for total number of addresses in each ZIP code

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to track changing patterns
-- 2. Include population data to weight the ratios
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Incorporate economic indicators to correlate with business ratios
-- 5. Create visualization-ready output for mapping tools
-- 6. Add filters for specific states or regions of interest
-- 7. Include analysis of "other" address types
-- 8. Add statistical measures of concentration (e.g., Gini coefficient)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:25:07.063409
    - Additional Notes: Query identifies county-level residential vs commercial patterns based on ZIP code address ratios, using averaged ratios and custom classification thresholds (75% for residential, 25% for commercial). Results provide insights for real estate analysis, urban planning, and market research purposes. Note that the classification thresholds may need adjustment based on specific regional characteristics or business requirements.
    
    */