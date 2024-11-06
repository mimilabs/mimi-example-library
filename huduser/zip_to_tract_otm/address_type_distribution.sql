-- usps_address_type_mix_analysis.sql
-- =============================================
-- Business Purpose:
-- Analyze the mix of address types (residential, business, other) within ZIP codes
-- to identify market segments and potential real estate opportunities. This helps:
-- - Real estate developers assess market composition
-- - Businesses evaluate location strategies
-- - Healthcare organizations understand service area characteristics

-- Get the address type distribution and total coverage for each ZIP code,
-- focusing on areas with significant presence (>10% total coverage)

SELECT 
    usps_zip_pref_state AS state,
    zip,
    usps_zip_pref_city AS city,
    -- Calculate average ratios across tracts for each address type
    ROUND(AVG(res_ratio), 3) AS avg_residential_ratio,
    ROUND(AVG(bus_ratio), 3) AS avg_business_ratio,
    ROUND(AVG(oth_ratio), 3) AS avg_other_ratio,
    -- Get total coverage
    ROUND(SUM(tot_ratio), 3) AS total_coverage,
    -- Count distinct census tracts
    COUNT(DISTINCT tract) AS tract_count

FROM mimi_ws_1.huduser.zip_to_tract_otm

WHERE tot_ratio >= 0.10  -- Focus on meaningful coverage areas

GROUP BY 
    usps_zip_pref_state,
    zip,
    usps_zip_pref_city

HAVING total_coverage >= 0.90  -- Ensure comprehensive coverage

ORDER BY 
    usps_zip_pref_state,
    avg_residential_ratio DESC,
    total_coverage DESC

LIMIT 1000;

-- How this query works:
-- 1. Groups data by state, ZIP, and city
-- 2. Calculates average ratios for each address type
-- 3. Filters for meaningful coverage (>10% per tract)
-- 4. Ensures comprehensive total coverage (>90%)
-- 5. Orders results by state and residential ratio

-- Assumptions and limitations:
-- - Assumes current address type distributions are representative
-- - Limited to areas with significant coverage
-- - Averages may mask tract-level variations
-- - Does not account for seasonal variations

-- Possible extensions:
-- 1. Add time-based trending by incorporating mimi_src_file_date
-- 2. Include population density data for deeper analysis
-- 3. Add geographic clustering analysis
-- 4. Incorporate distance to key amenities
-- 5. Cross-reference with property values or healthcare facility locations

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:56:50.752635
    - Additional Notes: Query focuses on balanced geographic coverage by analyzing the mix of residential, business, and other address types within ZIP codes. The 90% total coverage threshold ensures comprehensive results while the 10% individual tract threshold filters out negligible mappings. Best used for market analysis and location planning where understanding the complete address type composition is critical.
    
    */