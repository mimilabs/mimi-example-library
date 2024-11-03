-- Title: County-ZIP Code Geographic Coverage Analysis

-- Business Purpose:
-- Analyzes how completely ZIP codes cover counties based on address ratios
-- This helps identify areas where:
-- 1. ZIP code boundaries align well or poorly with county boundaries
-- 2. Geographic service coverage may need special attention
-- 3. Population distribution patterns require strategic planning

WITH latest_data AS (
    -- Get most recent data snapshot
    SELECT DISTINCT mimi_src_file_date
    FROM mimi_ws_1.huduser.county_to_zip
    ORDER BY mimi_src_file_date DESC
    LIMIT 1
),

coverage_metrics AS (
    -- Calculate coverage metrics for each county
    SELECT 
        county,
        COUNT(DISTINCT zip) as zip_count,
        SUM(res_ratio) as total_res_coverage,
        SUM(bus_ratio) as total_bus_coverage,
        MAX(res_ratio) as max_single_zip_coverage,
        MIN(res_ratio) as min_single_zip_coverage
    FROM mimi_ws_1.huduser.county_to_zip cz
    INNER JOIN latest_data ld ON cz.mimi_src_file_date = ld.mimi_src_file_date
    GROUP BY county
)

SELECT 
    cm.*,
    -- Categorize counties based on coverage patterns
    CASE 
        WHEN max_single_zip_coverage > 0.8 THEN 'Single ZIP Dominant'
        WHEN zip_count >= 10 AND max_single_zip_coverage < 0.3 THEN 'Highly Dispersed'
        ELSE 'Mixed Coverage'
    END as coverage_pattern,
    -- Calculate coverage completeness
    ROUND(total_res_coverage, 2) as coverage_completeness,
    -- Flag potential data quality issues
    CASE 
        WHEN total_res_coverage < 0.95 OR total_res_coverage > 1.05 THEN 'Review Required'
        ELSE 'Normal'
    END as data_quality_flag
FROM coverage_metrics cm
ORDER BY zip_count DESC;

-- How this query works:
-- 1. Identifies the most recent data snapshot
-- 2. Calculates key coverage metrics per county
-- 3. Categorizes counties based on ZIP code distribution patterns
-- 4. Flags potential data quality issues
-- 5. Orders results by number of ZIP codes to highlight complex areas

-- Assumptions and limitations:
-- 1. Assumes current data snapshot is representative
-- 2. Does not account for seasonal or temporal variations
-- 3. Coverage completeness should theoretically sum to 1.0
-- 4. May need adjustment for very small or very large counties

-- Possible extensions:
-- 1. Add temporal analysis to track coverage changes over time
-- 2. Include state-level aggregations for regional patterns
-- 3. Incorporate population density data for context
-- 4. Add geographic adjacency analysis
-- 5. Include demographic or economic indicators for deeper insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:08:56.843895
    - Additional Notes: Query uses relative thresholds (0.8 for dominant ZIP, 0.3 for dispersed) that may need adjustment based on specific geographic contexts. Coverage completeness values outside 0.95-1.05 range are flagged for review, which may need calibration for specific use cases.
    
    */