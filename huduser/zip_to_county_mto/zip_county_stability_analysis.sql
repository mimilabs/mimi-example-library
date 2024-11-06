-- Title: Primary County Assignment Changes Over Time by ZIP Code

-- Business Purpose:
-- This query analyzes how primary county assignments for ZIP codes change between
-- source file dates. This helps:
-- - Identify geographic areas with unstable county assignments
-- - Support location-based analytics that need consistent geographic mapping
-- - Monitor data quality and mapping stability over time
-- - Validate geographic hierarchies used in reporting

WITH current_mapping AS (
  SELECT 
    zip,
    county,
    usps_zip_pref_state,
    res_ratio,
    mimi_src_file_date
  FROM mimi_ws_1.huduser.zip_to_county_mto 
  WHERE mimi_src_file_date = '2024-03-20' -- Latest mapping
),

previous_mapping AS (
  SELECT 
    zip,
    county,
    usps_zip_pref_state,
    res_ratio,
    mimi_src_file_date
  FROM mimi_ws_1.huduser.zip_to_county_mto
  WHERE mimi_src_file_date = '2023-03-20' -- Previous year mapping
)

SELECT
  c.usps_zip_pref_state as state,
  COUNT(DISTINCT c.zip) as total_zips,
  COUNT(DISTINCT CASE WHEN p.county IS NULL THEN c.zip END) as new_zips,
  COUNT(DISTINCT CASE WHEN c.county != p.county THEN c.zip END) as changed_county_zips,
  ROUND(AVG(CASE WHEN c.county != p.county THEN ABS(c.res_ratio - p.res_ratio) END),3) as avg_res_ratio_change
FROM current_mapping c
LEFT JOIN previous_mapping p ON c.zip = p.zip
GROUP BY c.usps_zip_pref_state
ORDER BY total_zips DESC;

-- How the Query Works:
-- 1. Creates CTEs for current and previous year ZIP-county mappings
-- 2. Joins them to compare changes
-- 3. Calculates key metrics per state:
--    - Total ZIP codes
--    - New ZIP codes (not in previous mapping)
--    - ZIP codes with changed county assignments
--    - Average change in residential ratio for changed assignments

-- Assumptions and Limitations:
-- - Assumes annual source file updates in March
-- - Only looks at one year of change history
-- - Does not account for ZIP code retirements
-- - Changes in county assignments may be due to data improvements rather than actual changes

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Include business ratio changes
-- 3. Add county-level aggregations
-- 4. Flag ZIP codes with frequent county assignment changes
-- 5. Incorporate metropolitan statistical area (MSA) analysis
-- 6. Add drill-down capability to specific ZIP codes with significant changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:20:08.900269
    - Additional Notes: This query requires at least two source file dates to be present in the dataset for meaningful comparison. The default dates (2024-03-20 and 2023-03-20) should be adjusted based on the actual available data periods. The residential ratio change calculation only considers ZIP codes that have changed county assignments.
    
    */