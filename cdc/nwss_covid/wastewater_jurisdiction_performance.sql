-- COVID-19 Wastewater Surveillance Regional Reporting Analysis
--
-- Business Purpose: 
-- Analyze how different jurisdictions are utilizing wastewater surveillance to monitor COVID-19
-- by examining reporting patterns, population coverage, and data collection consistency.
-- This helps identify successful surveillance models and areas needing support.

WITH reporting_metrics AS (
    -- Calculate key metrics per reporting jurisdiction
    SELECT 
        reporting_jurisdiction,
        COUNT(DISTINCT wwtp_id) as total_treatment_plants,
        SUM(population_served) as total_population_covered,
        COUNT(DISTINCT key_plot_id) as total_sampling_sites,
        AVG(detect_prop_15d) as avg_detection_rate,
        -- Get most recent date for each jurisdiction
        MAX(date_end) as latest_report_date
    FROM mimi_ws_1.cdc.nwss_covid
    GROUP BY reporting_jurisdiction
),
jurisdiction_rankings AS (
    -- Rank jurisdictions by coverage and consistency
    SELECT 
        reporting_jurisdiction,
        total_treatment_plants,
        total_population_covered,
        total_sampling_sites,
        avg_detection_rate,
        latest_report_date,
        RANK() OVER (ORDER BY total_population_covered DESC) as population_rank,
        RANK() OVER (ORDER BY total_sampling_sites DESC) as coverage_rank
    FROM reporting_metrics
)

SELECT 
    reporting_jurisdiction,
    total_treatment_plants,
    FORMAT_NUMBER(total_population_covered, 0) as population_covered,
    total_sampling_sites,
    ROUND(avg_detection_rate, 2) as avg_detection_percentage,
    latest_report_date,
    population_rank,
    coverage_rank
FROM jurisdiction_rankings
WHERE total_population_covered > 0
ORDER BY total_population_covered DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE aggregates key metrics for each reporting jurisdiction
-- 2. Second CTE adds rankings based on population coverage and sampling site count
-- 3. Final query presents the top 20 jurisdictions by population covered
--
-- Assumptions and Limitations:
-- - Assumes population_served values are accurate and up-to-date
-- - Does not account for potential overlapping coverage areas
-- - Limited to jurisdictions with positive population coverage
--
-- Possible Extensions:
-- 1. Add time-based analysis to show reporting consistency over time
-- 2. Include demographic data to analyze coverage equity
-- 3. Compare detection rates with reported COVID-19 cases
-- 4. Add geographic clustering analysis
-- 5. Create month-over-month trending for key metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:37:17.606716
    - Additional Notes: Query focuses on identifying high-performing jurisdictions in wastewater surveillance based on population coverage and sampling site metrics. Results are particularly useful for program evaluation and resource allocation. Note that small jurisdictions might be underrepresented in the top 20 results despite having good coverage relative to their population size.
    
    */