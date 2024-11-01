-- TITLE: FQHC Provider Type and Service Specialization Analysis

-- BUSINESS PURPOSE:
-- This analysis examines the provider types and specializations of FQHCs to understand:
-- - Primary care vs specialty service distribution
-- - Market specialization patterns
-- - Care delivery model variations
-- Critical for healthcare strategy, network planning, and service gap analysis

SELECT 
    -- Categorize provider types
    provider_type_text,
    
    -- Count unique facilities
    COUNT(DISTINCT enrollment_id) as facility_count,
    
    -- Calculate percentage distribution
    ROUND(COUNT(DISTINCT enrollment_id) * 100.0 / 
          SUM(COUNT(DISTINCT enrollment_id)) OVER (), 1) as pct_of_total,
    
    -- Get unique organization count to understand consolidation
    COUNT(DISTINCT organization_name) as unique_orgs,
    
    -- Analyze profit status mix
    SUM(CASE WHEN proprietary_nonprofit = 'P' THEN 1 ELSE 0 END) as for_profit_count,
    SUM(CASE WHEN proprietary_nonprofit = 'N' THEN 1 ELSE 0 END) as non_profit_count,
    
    -- Calculate average NPIs per facility type
    ROUND(AVG(CASE WHEN multiple_npi_flag = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_multi_npi

FROM mimi_ws_1.datacmsgov.pc_fqhc

-- Get most recent data snapshot
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.datacmsgov.pc_fqhc
)

GROUP BY provider_type_text
ORDER BY facility_count DESC;

-- HOW IT WORKS:
-- 1. Aggregates FQHCs by provider type to show service mix
-- 2. Calculates key metrics for each provider type:
--    - Facility counts and percentages
--    - Organization counts to show consolidation
--    - Profit status distribution
--    - Multi-NPI prevalence
-- 3. Uses most recent data snapshot for currency
-- 4. Results ordered by facility count to highlight dominant types

-- ASSUMPTIONS & LIMITATIONS:
-- - Provider types are accurately reported and maintained
-- - Single snapshot analysis doesn't show temporal trends
-- - Multiple NPIs may indicate service breadth or administrative structure
-- - Organization names may have variations affecting unique counts

-- POSSIBLE EXTENSIONS:
-- 1. Add geographic dimension to analyze regional specialization
-- 2. Compare provider type mix between urban/rural areas
-- 3. Track provider type evolution over time
-- 4. Cross-reference with quality metrics or outcomes data
-- 5. Analyze correlation between specialization and financial metrics
-- 6. Include additional service indicators from linked datasets

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:12:04.388236
    - Additional Notes: The query effectively analyzes provider specialization distribution but current grouping by provider_type_text may need refinement if there are many sparse categories. Consider adding a HAVING clause to filter out provider types with very low counts or implementing a category grouping logic for better interpretability.
    
    */