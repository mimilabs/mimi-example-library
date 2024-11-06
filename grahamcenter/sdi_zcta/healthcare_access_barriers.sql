-- identify_high_need_healthcare_areas.sql

-- Business Purpose:
-- This query identifies ZIP code areas with the highest combined burden of poverty 
-- and limited transportation access. Healthcare organizations can use these insights
-- to prioritize locations for mobile clinics, telehealth services, or transportation
-- assistance programs. This helps improve healthcare access in vulnerable communities
-- while optimizing resource allocation.

-- Get the latest dataset to ensure current analysis
WITH latest_data AS (
    SELECT MAX(mimi_src_file_date) as max_date
    FROM mimi_ws_1.grahamcenter.sdi_zcta
),

-- Calculate composite accessibility score and rank ZIP codes
ranked_zips AS (
    SELECT 
        zcta5_fips,
        zcta5_population,
        pct_poverty_lt100,
        pcthh_no_vehicle,
        -- Create weighted composite score (poverty 60%, vehicle access 40%)
        (pct_poverty_lt100 * 0.6) + (pcthh_no_vehicle * 0.4) as access_burden_score,
        -- Minimum population threshold to ensure statistical relevance
        CASE WHEN zcta5_population >= 1000 THEN 1 ELSE 0 END as meets_pop_threshold
    FROM mimi_ws_1.grahamcenter.sdi_zcta sdi
    CROSS JOIN latest_data ld
    WHERE sdi.mimi_src_file_date = ld.max_date
)

SELECT 
    zcta5_fips as zip_code,
    zcta5_population as population,
    ROUND(pct_poverty_lt100 * 100, 1) as poverty_rate_pct,
    ROUND(pcthh_no_vehicle * 100, 1) as no_vehicle_rate_pct,
    ROUND(access_burden_score * 100, 1) as access_burden_score
FROM ranked_zips
WHERE meets_pop_threshold = 1
-- Focus on areas with significant challenges
AND access_burden_score >= 0.25
ORDER BY access_burden_score DESC
LIMIT 100;

-- How it works:
-- 1. Identifies the most recent dataset available
-- 2. Combines poverty and vehicle access metrics into a weighted score
-- 3. Filters for statistically relevant population sizes
-- 4. Returns top 100 ZIP codes with highest access barriers
-- 5. Presents results in easily interpretable percentage format

-- Assumptions and Limitations:
-- - Assumes current data patterns reflect ongoing needs
-- - Limited to ZIP codes with 1000+ population for statistical stability
-- - Focuses only on poverty and transportation barriers
-- - Does not account for existing healthcare infrastructure
-- - Weighted scoring (60/40) based on general impact assessment

-- Possible Extensions:
-- 1. Add geographic clustering to identify regional patterns
-- 2. Include distance to nearest hospital/clinic data if available
-- 3. Segment results by urban/rural classification
-- 4. Track changes over time using different source_file_dates
-- 5. Add demographic breakdowns for more targeted interventions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:09:20.662131
    - Additional Notes: Query focuses on ZIP codes with combined poverty and transportation barriers, using a weighted scoring system (60% poverty, 40% transportation). Requires population >= 1000 for statistical validity. Score threshold of 0.25 (25%) ensures focus on areas with significant challenges. Results limited to top 100 areas for practical implementation.
    
    */