-- Healthcare Provider Name Diversity and Historical Name Tracking Analysis
-- Purpose: Analyze healthcare provider name diversity, multiple name occurrences, and temporal name changes

WITH name_summary AS (
    -- Aggregate name usage statistics across providers
    SELECT 
        use,                        -- Name usage classification
        COUNT(DISTINCT npi) AS provider_count,
        COUNT(*) AS total_name_entries,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage_of_names
    FROM mimi_ws_1.nppes.fhir_name
    GROUP BY use
),

historical_name_tracking AS (
    -- Identify providers with multiple name entries and temporal name changes
    SELECT 
        npi,
        COUNT(DISTINCT text) AS unique_name_count,
        MIN(period_start) AS earliest_name_date,
        MAX(period_end) AS latest_name_date,
        DATEDIFF(MAX(period_end), MIN(period_start)) AS name_usage_span_days
    FROM mimi_ws_1.nppes.fhir_name
    GROUP BY npi
    HAVING unique_name_count > 1
)

SELECT 
    ns.use,
    ns.provider_count,
    ns.total_name_entries,
    ns.percentage_of_names,
    
    -- Additional insights from historical tracking
    COUNT(hnt.npi) AS multi_name_providers,
    AVG(hnt.name_usage_span_days) AS avg_name_usage_duration
FROM name_summary ns
LEFT JOIN historical_name_tracking hnt ON 1=1
GROUP BY 
    ns.use, 
    ns.provider_count, 
    ns.total_name_entries, 
    ns.percentage_of_names
ORDER BY ns.percentage_of_names DESC;

/*
Query Mechanics:
- First CTE (name_summary) aggregates name usage statistics
- Second CTE (historical_name_tracking) identifies providers with multiple names
- Main query combines insights from both CTEs

Assumptions:
- Data represents current NPPES snapshot
- Period dates are consistently and accurately populated
- NPI is unique identifier for healthcare providers

Potential Extensions:
1. Analyze name changes by provider specialty
2. Investigate regional variations in name usage
3. Create time-series visualization of name changes
4. Flag potential data quality issues with inconsistent names
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:08:47.000422
    - Additional Notes: Requires careful handling of historical name data, as periods may overlap or have incomplete date ranges. Query provides aggregated insights but should not be used for definitive individual provider name history tracking.
    
    */