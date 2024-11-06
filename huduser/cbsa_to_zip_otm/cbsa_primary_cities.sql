-- cbsa_preferred_locations.sql

-- Business Purpose: Identify the preferred city and state names used by USPS for each CBSA
-- to help healthcare organizations better align their provider directory locations and 
-- network adequacy reporting with official USPS designations. This mapping is crucial for:
-- - Accurate provider directory maintenance
-- - Network adequacy reporting to CMS
-- - Member communications and service area planning

WITH cbsa_locations AS (
    -- Get the most representative ZIP codes for each CBSA based on residential ratio
    SELECT 
        cbsa,
        usps_zip_pref_city,
        usps_zip_pref_state,
        res_ratio,
        ROW_NUMBER() OVER (PARTITION BY cbsa ORDER BY res_ratio DESC) as rank
    FROM mimi_ws_1.huduser.cbsa_to_zip_otm
    WHERE cbsa != '99999' -- Exclude non-CBSA areas
)

SELECT 
    c.cbsa,
    c.usps_zip_pref_city as primary_city,
    c.usps_zip_pref_state as primary_state,
    c.res_ratio as primary_residential_ratio,
    COUNT(DISTINCT cz.zip) as total_zip_codes,
    COUNT(DISTINCT cz.usps_zip_pref_city) as total_cities,
    ROUND(AVG(cz.res_ratio) * 100, 2) as avg_residential_ratio
FROM cbsa_locations c
JOIN mimi_ws_1.huduser.cbsa_to_zip_otm cz 
    ON c.cbsa = cz.cbsa
WHERE c.rank = 1 -- Take only the primary location for each CBSA
GROUP BY 1,2,3,4
ORDER BY total_zip_codes DESC
LIMIT 100;

-- How it works:
-- 1. First CTE identifies the primary city/state for each CBSA based on highest residential ratio
-- 2. Main query joins back to get aggregate statistics about each CBSA
-- 3. Results show the primary location along with diversity metrics

-- Assumptions and Limitations:
-- - Assumes the ZIP code with highest residential ratio is most representative
-- - Limited to CBSAs (excludes non-CBSA areas with code '99999')
-- - Current snapshot only (no historical trends)
-- - Top 100 CBSAs by ZIP code count shown

-- Possible Extensions:
-- 1. Add year-over-year comparison of primary locations
-- 2. Include secondary/tertiary preferred cities
-- 3. Add population or demographic data
-- 4. Compare USPS preferred names vs census/administrative names
-- 5. Create provider network coverage analysis using this as reference

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:38:58.745186
    - Additional Notes: This query specifically focuses on USPS preferred locations rather than census or administrative boundaries, making it particularly valuable for healthcare organizations that need to align their provider directories with USPS standards. The residential ratio weighting helps identify the most representative cities for each CBSA, though users should note that secondary cities might also be significant in larger metropolitan areas.
    
    */