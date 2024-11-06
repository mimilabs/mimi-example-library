-- residential_density_by_cbsa.sql
-- Business Purpose: Analyze residential concentration across Core-Based Statistical Areas (CBSAs)
-- Provides insights into urban population distribution and potential market segmentation opportunities

WITH cbsa_residential_summary AS (
    -- Aggregate residential ratios and ZIP code counts by CBSA
    SELECT 
        cbsa,
        usps_zip_pref_state,
        COUNT(DISTINCT zip) AS total_zip_codes,
        ROUND(AVG(res_ratio), 4) AS avg_residential_ratio,
        ROUND(SUM(res_ratio), 2) AS total_residential_coverage,
        COUNT(DISTINCT CASE WHEN res_ratio >= 0.5 THEN zip END) AS high_residential_zips,
        COUNT(DISTINCT CASE WHEN res_ratio < 0.5 THEN zip END) AS partial_residential_zips
    FROM mimi_ws_1.huduser.zip_to_cbsa
    WHERE cbsa != '99999'  -- Exclude non-CBSA areas
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.zip_to_cbsa)
    GROUP BY cbsa, usps_zip_pref_state
)

SELECT 
    cbsa,
    usps_zip_pref_state,
    total_zip_codes,
    avg_residential_ratio,
    total_residential_coverage,
    high_residential_zips,
    partial_residential_zips,
    CASE 
        WHEN avg_residential_ratio >= 0.75 THEN 'High Density Urban'
        WHEN avg_residential_ratio BETWEEN 0.5 AND 0.75 THEN 'Moderate Density Urban'
        ELSE 'Low Density Urban'
    END AS urban_density_category
FROM cbsa_residential_summary
WHERE total_zip_codes > 5  -- Focus on more substantial CBSAs
ORDER BY total_residential_coverage DESC
LIMIT 100;

/*
Query Mechanics:
- Filters most recent data snapshot
- Calculates residential distribution metrics per CBSA
- Categorizes CBSAs by residential density
- Provides comprehensive view of urban area composition

Assumptions & Limitations:
- Uses most recent data file
- Excludes areas without CBSA assignment
- Focuses on CBSAs with more than 5 ZIP codes
- Residential ratio is proxy for population density

Potential Extensions:
1. Join with additional demographic datasets
2. Compare residential vs business ratios
3. Time-series analysis of CBSA composition
4. Regional clustering based on residential characteristics
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:00:06.639569
    - Additional Notes: Query provides insights into urban population distribution across Core-Based Statistical Areas, filtering for most recent data and focusing on meaningful CBSA compositions with more than 5 ZIP codes.
    
    */