-- File: mpox_wastewater_detection_source_comparison.sql
-- Title: Comparative Analysis of Mpox Wastewater Detection Sources 

/*
Business Purpose:
Analyze and compare different data sources (CDC Biobot, Verily, NWSS, WSS) 
for mpox wastewater surveillance to assess data collection reliability, 
coverage, and detection consistency across the United States. 

Key Business Value:
- Evaluate the performance of different surveillance data sources
- Identify geographic variations in mpox detection capabilities
- Provide insights for public health resource allocation and monitoring strategies
*/

WITH source_summary AS (
    -- Aggregate detection metrics by data source and jurisdiction
    SELECT 
        source,
        jurisdiction,
        COUNT(DISTINCT key_plot_id) AS unique_sewersheds,
        SUM(population_served) AS total_population_monitored,
        SUM(pos_samples) AS total_positive_samples,
        SUM(total_samples) AS total_samples_collected,
        ROUND(100.0 * SUM(pos_samples) / NULLIF(SUM(total_samples), 0), 2) AS overall_detection_rate,
        MAX(sample_collect_date) AS latest_collection_date
    FROM mimi_ws_1.cdc.nwss_mpox
    WHERE source IS NOT NULL
    GROUP BY source, jurisdiction
),
source_ranking AS (
    -- Rank sources by detection coverage and sample volume
    SELECT 
        source,
        unique_sewersheds,
        total_population_monitored,
        total_positive_samples,
        total_samples_collected,
        overall_detection_rate,
        latest_collection_date,
        RANK() OVER (ORDER BY unique_sewersheds DESC) AS sewershed_coverage_rank,
        RANK() OVER (ORDER BY total_population_monitored DESC) AS population_coverage_rank,
        RANK() OVER (ORDER BY overall_detection_rate DESC) AS detection_rate_rank
    FROM source_summary
)

-- Primary query to compare and rank mpox wastewater surveillance sources
SELECT 
    source,
    unique_sewersheds,
    total_population_monitored,
    total_positive_samples,
    total_samples_collected,
    overall_detection_rate,
    latest_collection_date,
    sewershed_coverage_rank,
    population_coverage_rank,
    detection_rate_rank
FROM source_ranking
ORDER BY detection_rate_rank, sewershed_coverage_rank;

/*
Query Mechanics:
1. First CTE (source_summary) aggregates data by source and jurisdiction
2. Second CTE (source_ranking) ranks sources across multiple dimensions
3. Final SELECT provides a comprehensive comparison of surveillance sources

Assumptions and Limitations:
- Data assumes consistent collection and reporting methods
- Rankings are relative within the current dataset
- Does not account for sampling frequency or regional variations

Potential Query Extensions:
1. Add temporal trend analysis by including time-based comparisons
2. Incorporate geospatial analysis to map detection capabilities
3. Create alerts or flags for significant changes in detection patterns
4. Develop predictive models based on source reliability and detection rates
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:01:46.491056
    - Additional Notes: Provides a comparative analysis of different mpox wastewater surveillance data sources, ranking them by detection capabilities, population coverage, and sample collection. Useful for public health officials evaluating monitoring strategies across multiple data providers.
    
    */