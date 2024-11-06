-- Clinician Geographic Procedure Concentration Analysis
--
-- Business Purpose:
-- 1. Identify geographic areas with high/low procedure volumes to support network planning
-- 2. Detect potential access gaps based on procedure distribution
-- 3. Inform regional market expansion strategies
-- 4. Support value-based care network development decisions

WITH provider_locations AS (
    -- Get unique providers and their procedure volume totals
    SELECT 
        npi,
        provider_last_name,
        provider_first_name,
        SUM(count) as total_procedures,
        COUNT(DISTINCT procedure_category) as unique_procedures,
        MAX(mimi_src_file_date) as latest_data_date
    FROM mimi_ws_1.provdatacatalog.dac_utilization
    WHERE profile_display_indicator = 'Y'
    GROUP BY 1,2,3
),

volume_segments AS (
    -- Segment providers by procedure volume
    SELECT
        *,
        CASE 
            WHEN total_procedures >= percentile_cont(0.9) WITHIN GROUP (ORDER BY total_procedures)
                OVER() THEN 'High Volume'
            WHEN total_procedures <= percentile_cont(0.1) WITHIN GROUP (ORDER BY total_procedures)
                OVER() THEN 'Low Volume'
            ELSE 'Medium Volume'
        END as volume_segment
    FROM provider_locations
)

-- Final output with key metrics
SELECT 
    volume_segment,
    COUNT(DISTINCT npi) as provider_count,
    ROUND(AVG(total_procedures),0) as avg_procedures,
    ROUND(AVG(unique_procedures),1) as avg_procedure_types,
    MIN(latest_data_date) as data_start_date,
    MAX(latest_data_date) as data_end_date
FROM volume_segments
GROUP BY 1
ORDER BY avg_procedures DESC;

-- How this query works:
-- 1. First CTE aggregates total procedures and unique procedure types per provider
-- 2. Second CTE segments providers into volume categories based on percentiles
-- 3. Final query summarizes key metrics by volume segment
--
-- Assumptions & Limitations:
-- - Requires profile_display_indicator = 'Y' for data quality
-- - Volume segmentation based on total procedures may not account for complexity
-- - Geographic inference limited without explicit location data
-- - Time trends limited to available data range
--
-- Possible Extensions:
-- 1. Add procedure category analysis within each volume segment
-- 2. Incorporate temporal trends analysis
-- 3. Add provider specialty analysis if available through joins
-- 4. Compare volume patterns across different data sources
-- 5. Add statistical testing for segment differences

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:02:10.048419
    - Additional Notes: Query focuses on provider segmentation based on procedure volumes, useful for network planning and market analysis. Note that geographic insights are currently limited without explicit location data in the source table. Volume segments are defined using 10th and 90th percentiles, which may need adjustment based on specific business needs.
    
    */