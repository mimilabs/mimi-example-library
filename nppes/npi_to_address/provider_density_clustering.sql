-- Healthcare Provider Network Analysis by Geographic Proximity
--
-- Business Purpose: 
-- This query analyzes the geographic proximity of healthcare providers to identify
-- potential networks and referral patterns based on physical location clustering.
-- The analysis helps understand market dynamics, network adequacy, and access to care
-- by revealing areas with high or low provider density.

WITH provider_clusters AS (
    -- Group providers by H3 geographic cells at resolution 8 (approximately ~1km)
    SELECT 
        h3_r8_biz as location_cluster,
        COUNT(DISTINCT npi) as providers_in_cluster,
        COUNT(DISTINCT CASE WHEN entity_type_code = '1' THEN npi END) as individual_providers,
        COUNT(DISTINCT CASE WHEN entity_type_code = '2' THEN npi END) as org_providers,
        ROUND(AVG(latitude_biz), 4) as cluster_lat,
        ROUND(AVG(longitude_biz), 4) as cluster_long,
        -- Using array_join instead of string_agg for Databricks SQL compatibility
        array_join(collect_set(state_fips_biz), ',') as state_fips
    FROM mimi_ws_1.nppes.npi_to_address
    WHERE h3_r8_biz IS NOT NULL
    GROUP BY h3_r8_biz
),
cluster_density AS (
    -- Calculate density metrics for each cluster
    SELECT 
        *,
        CASE 
            WHEN providers_in_cluster >= 10 THEN 'High Density'
            WHEN providers_in_cluster >= 5 THEN 'Medium Density'
            ELSE 'Low Density'
        END as density_category
    FROM provider_clusters
)

-- Final output showing provider network clustering patterns
SELECT 
    density_category,
    COUNT(*) as cluster_count,
    SUM(providers_in_cluster) as total_providers,
    ROUND(AVG(providers_in_cluster), 1) as avg_providers_per_cluster,
    ROUND(AVG(individual_providers), 1) as avg_individual_providers,
    ROUND(AVG(org_providers), 1) as avg_org_providers,
    MAX(providers_in_cluster) as max_providers_in_cluster
FROM cluster_density
GROUP BY density_category
ORDER BY cluster_count DESC;

-- How this query works:
-- 1. Groups providers by H3 geographic cells at resolution 8
-- 2. Calculates provider counts and types within each cluster
-- 3. Categorizes clusters by density
-- 4. Summarizes clustering patterns to reveal network characteristics
--
-- Assumptions and limitations:
-- - Assumes H3 resolution 8 (~1km) is appropriate for network analysis
-- - Only considers business addresses, not mailing addresses
-- - Does not account for provider specialties or practice types
-- - Geographic barriers (rivers, highways) not considered
--
-- Possible extensions:
-- 1. Add specialty analysis to identify medical service clusters
-- 2. Compare urban vs rural clustering patterns using RUCA codes
-- 3. Analyze temporal changes in provider density
-- 4. Include distance calculations between high-density clusters
-- 5. Correlate with population demographics for network adequacy analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:08:23.887257
    - Additional Notes: This query leverages H3 geospatial indexing to identify healthcare provider clustering patterns at a ~1km resolution. It's particularly useful for analyzing market concentration and identifying potential healthcare deserts. Note that the density thresholds (5 and 10 providers) may need adjustment based on specific market characteristics and urban/rural settings.
    
    */