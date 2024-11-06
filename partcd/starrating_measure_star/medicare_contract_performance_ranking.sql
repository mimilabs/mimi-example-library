-- Title: Medicare Contract Performance Trend and Quality Stratification Analysis

/*
Business Purpose:
- Identify high-performing Medicare contracts with consistent star rating trends
- Enable strategic benchmarking of contract performance across different dimensions
- Provide insights for potential investment, partnership, or improvement opportunities

Key Business Questions Addressed:
- Which contracts demonstrate sustained high-quality performance?
- How do measure values vary across different performance years?
- What potential correlations exist between contract characteristics and performance?
*/

WITH contract_performance_summary AS (
    -- Calculate key performance metrics for each contract
    SELECT 
        contract_id,
        organization_type,
        contract_name,
        parent_organization,
        measure_code,
        measure_desc,
        
        -- Aggregate performance metrics
        ROUND(AVG(measure_value), 2) AS avg_measure_value,
        ROUND(STDDEV(measure_value), 2) AS measure_value_volatility,
        
        -- Performance trend indicators
        MIN(performance_year) AS earliest_year,
        MAX(performance_year) AS latest_year,
        COUNT(DISTINCT performance_year) AS years_of_data
    
    FROM mimi_ws_1.partcd.starrating_measure_star
    
    -- Filter for meaningful measure values and ensure data quality
    WHERE measure_value IS NOT NULL 
      AND measure_value > 0
      AND performance_year IS NOT NULL
    
    GROUP BY 
        contract_id, 
        organization_type, 
        contract_name, 
        parent_organization,
        measure_code,
        measure_desc
),

performance_ranking AS (
    -- Rank contracts based on consistent high performance
    SELECT 
        *,
        -- Custom performance score combining average value and consistency
        ROUND(
            avg_measure_value * (years_of_data / 5.0) * 
            (1 - LEAST(measure_value_volatility / avg_measure_value, 1)), 
        2) AS performance_score,
        
        -- Percentile ranking within organization type
        PERCENT_RANK() OVER (
            PARTITION BY organization_type 
            ORDER BY avg_measure_value
        ) AS org_type_percentile
    
    FROM contract_performance_summary
)

-- Final output: Top performing contracts with strategic insights
SELECT 
    contract_id,
    contract_name,
    organization_type,
    parent_organization,
    measure_code,
    measure_desc,
    
    avg_measure_value,
    performance_score,
    org_type_percentile,
    
    earliest_year,
    latest_year,
    years_of_data
    
FROM performance_ranking

WHERE years_of_data >= 3  -- Ensure sufficient historical data
  AND performance_score > 3.5  -- Focus on high performers
ORDER BY performance_score DESC
LIMIT 50;

/*
How the Query Works:
- First CTE (contract_performance_summary) aggregates contract performance metrics
- Second CTE (performance_ranking) creates a custom performance scoring mechanism
- Final SELECT identifies top-performing contracts with nuanced metrics

Assumptions and Limitations:
- Assumes measure_value is comparable across different measures
- Performance score is a simplified, custom calculation
- Limited to contracts with at least 3 years of data

Potential Extensions:
1. Add geographic filtering
2. Include more complex performance scoring algorithms
3. Compare performance across specific measure categories
4. Integrate with cost or patient satisfaction data
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:37:44.328407
    - Additional Notes: Query provides a strategic performance analysis of Medicare contracts, using a custom scoring mechanism that considers measure value, consistency, and data availability. Performance scoring combines average value, data years, and volatility to identify top-performing contracts.
    
    */