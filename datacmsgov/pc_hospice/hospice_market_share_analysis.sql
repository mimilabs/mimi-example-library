-- Medicare Hospice Market Size Analysis - For-Profit vs Non-Profit Distribution
-- Business Purpose: Analyze market share and size metrics between for-profit and non-profit hospice
-- providers to identify market dynamics and potential consolidation opportunities.
-- Supports: Market entry analysis, M&A targeting, competitive intelligence

WITH current_hospices AS (
    -- Get latest data snapshot and basic metrics
    SELECT 
        proprietary_nonprofit,
        COUNT(DISTINCT enrollment_id) as provider_count,
        COUNT(DISTINCT organization_name) as unique_organizations,
        COUNT(DISTINCT ccn) as unique_locations,
        COUNT(DISTINCT CASE WHEN multiple_npi_flag = 'Y' THEN enrollment_id END) as multi_location_count
    FROM mimi_ws_1.datacmsgov.pc_hospice
    WHERE proprietary_nonprofit IS NOT NULL
    GROUP BY proprietary_nonprofit
),

market_metrics AS (
    -- Calculate market metrics and ratios
    SELECT
        proprietary_nonprofit,
        provider_count,
        unique_organizations,
        unique_locations,
        multi_location_count,
        ROUND(100.0 * provider_count / SUM(provider_count) OVER (), 1) as market_share_pct,
        ROUND(1.0 * unique_locations / unique_organizations, 2) as avg_locations_per_org,
        ROUND(100.0 * multi_location_count / provider_count, 1) as multi_location_pct
    FROM current_hospices
)

SELECT 
    CASE 
        WHEN proprietary_nonprofit = 'P' THEN 'For-Profit'
        WHEN proprietary_nonprofit = 'N' THEN 'Non-Profit'
    END as ownership_type,
    provider_count,
    unique_organizations,
    unique_locations,
    market_share_pct,
    avg_locations_per_org,
    multi_location_pct
FROM market_metrics
ORDER BY provider_count DESC;

-- How this query works:
-- 1. First CTE gets base counts of providers, organizations, and locations
-- 2. Second CTE calculates derived metrics like market share and ratios
-- 3. Final SELECT formats results with clear labels

-- Key assumptions:
-- - Uses enrollment_id as primary provider counter
-- - Assumes current snapshot represents active providers
-- - Multiple NPIs indicate multi-location operations
-- - Excludes records with null proprietary_nonprofit values

-- Limitations:
-- - Point-in-time analysis only, no historical trends
-- - Doesn't account for provider size/revenue
-- - May undercount actual locations if NPIs not properly tracked

-- Possible extensions:
-- 1. Add geographic segmentation by state/region
-- 2. Include time series analysis if historical data available
-- 3. Add size brackets based on location counts
-- 4. Cross-reference with owner data for chain analysis
-- 5. Add rural vs urban location analysis/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:13:43.325984
    - Additional Notes: Query provides key market structure metrics by splitting providers into for-profit vs non-profit segments. The multi-location percentage and average locations per organization metrics are particularly useful for identifying consolidation patterns. Consider pairing this analysis with financial data for complete market assessment.
    
    */