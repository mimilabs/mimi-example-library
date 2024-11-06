-- provider_specialty_trends.sql
-- Business Purpose: Analyze trends in provider specialty mix over time to inform 
-- network adequacy planning and identify potential specialty gaps in the Medi-Cal network.

WITH specialty_counts AS (
    -- Get monthly counts by specialty
    SELECT 
        DATE_TRUNC('month', mimi_src_file_date) AS month,
        fi_provider_specialty,
        COUNT(DISTINCT npi) AS provider_count,
        COUNT(DISTINCT county) AS counties_served
    FROM mimi_ws_1.stategov.california_medicaid_provider_directory
    WHERE fi_provider_specialty IS NOT NULL
    AND in_out_state = 'In State'
    GROUP BY 1, 2
),

specialty_metrics AS (
    -- Calculate month-over-month changes
    SELECT 
        month,
        fi_provider_specialty,
        provider_count,
        counties_served,
        provider_count - LAG(provider_count) OVER (
            PARTITION BY fi_provider_specialty 
            ORDER BY month
        ) AS mom_change,
        ROUND(100.0 * (provider_count - LAG(provider_count) OVER (
            PARTITION BY fi_provider_specialty 
            ORDER BY month
        )) / NULLIF(LAG(provider_count) OVER (
            PARTITION BY fi_provider_specialty 
            ORDER BY month
        ), 0), 1) AS pct_change
    FROM specialty_counts
)

SELECT 
    month,
    fi_provider_specialty,
    provider_count,
    counties_served,
    mom_change,
    pct_change
FROM specialty_metrics
WHERE month >= DATE_ADD(MONTHS, -12, (SELECT MAX(month) FROM specialty_metrics))
ORDER BY month DESC, provider_count DESC;

/* How this query works:
1. First CTE aggregates monthly provider counts and county coverage by specialty
2. Second CTE calculates month-over-month changes in absolute and percentage terms
3. Final output shows last 12 months of data, ordered by most recent month and provider count

Key assumptions and limitations:
- Uses mimi_src_file_date as the time dimension
- Focuses only on in-state providers
- Excludes records with null specialties
- Month-over-month changes may be affected by data quality/completeness

Possible extensions:
1. Add specialty-specific shortage thresholds and flag concerning trends
2. Include geographic analysis by region/county
3. Compare against beneficiary population data to calculate provider ratios
4. Add provider type analysis alongside specialty analysis
5. Create year-over-year comparisons instead of month-over-month
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:13:40.513368
    - Additional Notes: The query tracks monthly changes in provider specialties across California's Medicaid network. Key focus is on provider counts and geographic coverage per specialty, with month-over-month trend analysis. Best used for quarterly network adequacy reviews and specialty gap identification. Note that results are sensitive to data completeness in source files.
    
    */