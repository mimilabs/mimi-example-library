-- hha_service_mix_analysis.sql

-- Business Purpose: This query analyzes the mix of services provided by Home Health Agencies
-- by examining worksheet entries related to service types and patient visits.
-- Understanding service mix helps identify market opportunities, optimize resource allocation,
-- and guide business development strategies for healthcare organizations.

WITH service_data AS (
  SELECT 
    rpt_rec_num,
    wksht_cd,
    line_num,
    itm_alphnmrc_itm_txt,
    mimi_src_file_date
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_alpha
  -- Focus on S-3 worksheet which contains service statistics
  WHERE wksht_cd = 'S300000'
    -- Filter for lines containing service type descriptions
    AND line_num IN ('100', '200', '300', '400', '500')
    -- Look at the descriptive column
    AND clmn_num = '0'
),

provider_summary AS (
  SELECT
    rpt_rec_num,
    EXTRACT(YEAR FROM mimi_src_file_date) AS report_year,
    COUNT(DISTINCT line_num) as service_type_count,
    -- Removed STRING_AGG function as it's not supported
    COUNT(DISTINCT itm_alphnmrc_itm_txt) as unique_services
  FROM service_data
  GROUP BY rpt_rec_num, EXTRACT(YEAR FROM mimi_src_file_date)
)

SELECT
  report_year,
  COUNT(DISTINCT rpt_rec_num) as provider_count,
  AVG(service_type_count) as avg_services_per_provider,
  AVG(unique_services) as avg_unique_services,
  -- Calculate percentage of providers offering multiple services
  COUNT(CASE WHEN service_type_count > 1 THEN 1 END) * 100.0 / 
    COUNT(rpt_rec_num) as pct_multiple_services
FROM provider_summary
GROUP BY report_year
ORDER BY report_year DESC;

-- How this query works:
-- 1. First CTE extracts relevant service type data from worksheet S-3
-- 2. Second CTE summarizes services at the provider level
-- 3. Final query aggregates data by year to show service mix trends

-- Assumptions and Limitations:
-- - Assumes worksheet S-3 contains consistent service type coding across years
-- - Limited to services explicitly listed in the cost report structure
-- - Does not account for potential reporting gaps or errors
-- - May not capture all specialized services offered by HHAs

-- Possible Extensions:
-- 1. Add geographic analysis by joining with provider location data
-- 2. Include volume metrics for each service type
-- 3. Analyze correlation between service mix and financial performance
-- 4. Compare service patterns across different ownership types
-- 5. Track emergence of new service types over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:38:54.702420
    - Additional Notes: Query focuses on measuring service diversity and multi-service adoption patterns among Home Health Agencies over time. Key metrics include average service counts and percentage of providers offering multiple services. The analysis is limited to worksheet S-3 data and may not capture all service variations.
    
    */