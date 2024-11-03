-- geographic_data_completeness_audit.sql
-- Business Purpose: This query audits the completeness and quality of geographic data relationships 
-- between Census Tracts and ZIP codes to ensure reliable spatial analysis and resource allocation.
-- This helps organizations validate their geographic data foundations before conducting detailed
-- demographic or market analyses.

WITH latest_data AS (
    -- Get the most recent data snapshot
    SELECT MAX(mimi_src_file_date) as latest_date
    FROM mimi_ws_1.huduser.tract_to_zip
),

completeness_metrics AS (
    -- Calculate key quality metrics for tract-zip relationships 
    SELECT 
        ROUND(COUNT(DISTINCT tract) / 100000.0, 3) as tract_coverage_ratio,
        ROUND(COUNT(DISTINCT zip) / 43000.0, 3) as zip_coverage_ratio,
        COUNT(*) as total_relationships,
        ROUND(AVG(tot_ratio), 3) as avg_coverage_ratio,
        COUNT(CASE WHEN tot_ratio = 1 THEN 1 END) as perfect_matches,
        COUNT(CASE WHEN tot_ratio < 0.1 THEN 1 END) as weak_relationships
    FROM mimi_ws_1.huduser.tract_to_zip t
    WHERE mimi_src_file_date = (SELECT latest_date FROM latest_data)
),

state_coverage AS (
    -- Analyze coverage by state to identify potential gaps
    SELECT 
        usps_zip_pref_state,
        COUNT(DISTINCT tract) as tract_count,
        COUNT(DISTINCT zip) as zip_count,
        ROUND(AVG(tot_ratio), 3) as state_avg_coverage
    FROM mimi_ws_1.huduser.tract_to_zip t
    WHERE mimi_src_file_date = (SELECT latest_date FROM latest_data)
    GROUP BY usps_zip_pref_state
)

SELECT 
    'Overall Coverage' as metric_type,
    m.tract_coverage_ratio as tract_coverage,
    m.zip_coverage_ratio as zip_coverage,
    m.total_relationships,
    m.avg_coverage_ratio,
    m.perfect_matches,
    m.weak_relationships,
    (
        SELECT COUNT(DISTINCT usps_zip_pref_state) 
        FROM state_coverage 
        WHERE tract_count > 100
    ) as states_with_good_coverage
FROM completeness_metrics m;

-- How this query works:
-- 1. Identifies the most recent data snapshot
-- 2. Calculates overall coverage metrics using known US totals as denominators
-- 3. Identifies perfect matches and weak relationships
-- 4. Analyzes state-level coverage patterns
-- 5. Returns a single row summary for easy monitoring

-- Assumptions and limitations:
-- - Assumes approximately 100,000 Census tracts and 43,000 ZIP codes in the US
-- - Perfect matches (tot_ratio = 1) represent ideal 1:1 relationships
-- - Weak relationships (tot_ratio < 0.1) may need special attention
-- - State-level analysis considers states with >100 tracts as having good coverage

-- Possible extensions:
-- 1. Add trend analysis by comparing metrics across multiple time periods
-- 2. Include data quality checks for missing or invalid values
-- 3. Add geographic clustering analysis to identify regional patterns
-- 4. Create alerts for significant changes in coverage metrics
-- 5. Add validation against external geographic reference data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:19:41.327976
    - Additional Notes: This query focuses on high-level geographic data quality assessment, using approximate US Census tract and ZIP code totals as benchmarks. The results provide a quick health check of the geographic relationship coverage and can be used as a foundation for more detailed quality assurance processes. Consider updating the assumed total counts (100,000 tracts and 43,000 ZIP codes) if these reference numbers change significantly.
    
    */