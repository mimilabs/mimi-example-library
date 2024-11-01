-- COVID-19 Wastewater Surveillance Population Coverage Analysis
-- Business Purpose: 
-- Evaluate the effectiveness and reach of the CDC's wastewater surveillance program
-- by analyzing population coverage across jurisdictions and identifying potential
-- monitoring gaps to support public health resource allocation decisions.

WITH population_stats AS (
  -- Calculate total population coverage and site counts by jurisdiction
  SELECT 
    wwtp_jurisdiction,
    COUNT(DISTINCT key_plot_id) as monitoring_sites,
    SUM(population_served) as total_population_served,
    MAX(date_end) as latest_report_date,
    MIN(first_sample_date) as earliest_sample_date,
    COUNT(DISTINCT county_fips) as counties_covered
  FROM mimi_ws_1.cdc.nwss_covid
  WHERE population_served IS NOT NULL
  GROUP BY wwtp_jurisdiction
),

jurisdiction_metrics AS (
  -- Calculate key program metrics per jurisdiction
  SELECT 
    wwtp_jurisdiction,
    monitoring_sites,
    total_population_served,
    counties_covered,
    DATEDIFF(latest_report_date, earliest_sample_date) as days_monitored,
    ROUND(total_population_served / monitoring_sites, 0) as avg_population_per_site
  FROM population_stats
)

-- Final output with program coverage insights
SELECT 
  wwtp_jurisdiction as jurisdiction,
  monitoring_sites,
  counties_covered,
  total_population_served,
  days_monitored,
  avg_population_per_site,
  ROUND(monitoring_sites / NULLIF(counties_covered, 0), 2) as sites_per_county
FROM jurisdiction_metrics
WHERE total_population_served > 0
ORDER BY total_population_served DESC;

-- How this query works:
-- 1. First CTE aggregates raw surveillance data by jurisdiction
-- 2. Second CTE calculates derived metrics about program coverage
-- 3. Final SELECT formats and presents key insights about program reach
--
-- Assumptions and Limitations:
-- - Assumes population_served values are accurate and current
-- - Does not account for overlapping coverage areas
-- - Counties may be partially covered but counted as fully covered
-- - Some jurisdictions may have incomplete or missing data
--
-- Possible Extensions:
-- 1. Add time-based analysis to show program growth over time
-- 2. Include population coverage as percentage of total jurisdiction population
-- 3. Add demographic analysis of covered vs uncovered populations
-- 4. Compare coverage metrics against COVID-19 case rates
-- 5. Create coverage gap analysis by mapping uncovered counties

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:46:27.875053
    - Additional Notes: This query provides a high-level overview of the NWSS program's reach and effectiveness by analyzing population coverage and monitoring site distribution. The metrics help identify jurisdictions that may need additional monitoring sites or resources. Note that the analysis depends on accurate population_served values and may not reflect recent demographic changes.
    
    */