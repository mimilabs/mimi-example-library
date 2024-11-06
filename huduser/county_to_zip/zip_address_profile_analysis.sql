-- Title: ZIP Code Address Type Distribution Analysis

-- Business Purpose:
-- This script analyzes the distribution of different address types (residential, business, other)
-- across ZIP codes to help:
-- 1. Identify specialized ZIP codes (primarily residential vs business districts)
-- 2. Support market segmentation and targeting strategies
-- 3. Optimize resource allocation based on address type concentrations
-- 4. Guide location-based business decisions

-- Main Query
WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT DISTINCT mimi_src_file_date
    FROM mimi_ws_1.huduser.county_to_zip
    ORDER BY mimi_src_file_date DESC
    LIMIT 1
),

address_distributions AS (
    -- Calculate address type distributions by ZIP code
    SELECT 
        zip,
        usps_zip_pref_city,
        usps_zip_pref_state,
        COUNT(DISTINCT county) as county_count,
        ROUND(AVG(res_ratio * 100), 2) as avg_residential_pct,
        ROUND(AVG(bus_ratio * 100), 2) as avg_business_pct,
        ROUND(AVG(oth_ratio * 100), 2) as avg_other_pct
    FROM mimi_ws_1.huduser.county_to_zip c
    WHERE mimi_src_file_date = (SELECT mimi_src_file_date FROM latest_data)
    GROUP BY zip, usps_zip_pref_city, usps_zip_pref_state
)

SELECT 
    zip,
    usps_zip_pref_city,
    usps_zip_pref_state,
    county_count,
    avg_residential_pct,
    avg_business_pct,
    avg_other_pct,
    CASE 
        WHEN avg_residential_pct >= 70 THEN 'Primarily Residential'
        WHEN avg_business_pct >= 50 THEN 'Business District'
        ELSE 'Mixed Use'
    END as zone_type
FROM address_distributions
WHERE county_count > 0
ORDER BY 
    CASE 
        WHEN avg_residential_pct >= 70 THEN 1
        WHEN avg_business_pct >= 50 THEN 2
        ELSE 3
    END,
    avg_residential_pct DESC;

-- How it works:
-- 1. The query first identifies the most recent data snapshot
-- 2. For each ZIP code, it calculates average percentages of different address types
-- 3. Classifies ZIP codes into zone types based on address type concentrations
-- 4. Results are ordered by zone type and residential percentage

-- Assumptions and Limitations:
-- 1. Uses the most recent data snapshot only
-- 2. Zone type classification thresholds are arbitrary and may need adjustment
-- 3. Averages across counties may mask significant variations within ZIP codes
-- 4. Does not account for total address volume in each ZIP code

-- Possible Extensions:
-- 1. Add total address count and density metrics
-- 2. Include year-over-year trend analysis
-- 3. Add geographic clustering analysis
-- 4. Include demographic data overlay
-- 5. Add filtering by state or metropolitan area
-- 6. Enhance zone type classification with more nuanced categories
-- 7. Add population density correlations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:12:03.959463
    - Additional Notes: The script assumes uniform thresholds for classifying zone types (70% for residential, 50% for business) which may need adjustment based on specific business requirements. For areas with unique distributions, consider modifying these thresholds or adding more classification criteria.
    
    */