-- Home Infusion Provider Service Line Analysis
--
-- Business Purpose: 
-- Analyzes home infusion therapy providers by their legal business names and patterns
-- to identify major service organizations and potential consolidation opportunities.
-- This helps understand market dynamics and competitive landscape.

WITH provider_orgs AS (
    -- Get unique provider organizations and standardize names
    SELECT DISTINCT
        legal_business_name,
        state,
        COUNT(*) OVER (PARTITION BY legal_business_name) as location_count,
        COUNT(*) OVER (PARTITION BY legal_business_name, state) as state_location_count
    FROM mimi_ws_1.datacmsgov.pc_homeinfusion
    WHERE legal_business_name IS NOT NULL
),

size_categories AS (
    -- Categorize providers by size based on location count
    SELECT 
        CASE 
            WHEN location_count >= 10 THEN 'Large (10+ locations)'
            WHEN location_count >= 5 THEN 'Medium (5-9 locations)'
            ELSE 'Small (1-4 locations)'
        END AS organization_size,
        COUNT(DISTINCT legal_business_name) as provider_count,
        COUNT(*) as total_locations
    FROM provider_orgs
    GROUP BY 
        CASE 
            WHEN location_count >= 10 THEN 'Large (10+ locations)'
            WHEN location_count >= 5 THEN 'Medium (5-9 locations)'
            ELSE 'Small (1-4 locations)'
        END
)

SELECT 
    organization_size,
    provider_count,
    total_locations,
    ROUND(100.0 * provider_count / SUM(provider_count) OVER (), 1) as pct_of_providers,
    ROUND(100.0 * total_locations / SUM(total_locations) OVER (), 1) as pct_of_locations
FROM size_categories
ORDER BY 
    CASE organization_size
        WHEN 'Large (10+ locations)' THEN 1
        WHEN 'Medium (5-9 locations)' THEN 2
        ELSE 3
    END;

-- How it works:
-- 1. First CTE gets unique provider organizations and counts their locations
-- 2. Second CTE categorizes providers into size segments
-- 3. Final query calculates market share metrics by size category
--
-- Assumptions and Limitations:
-- - Legal business names are assumed to be consistently formatted
-- - Multiple locations under slightly different names may not be consolidated
-- - Current snapshot only - doesn't show historical trends
-- - Doesn't account for parent company relationships
--
-- Possible Extensions:
-- 1. Add year-over-year comparison to track consolidation trends
-- 2. Include revenue estimates or Medicare claims volume if available
-- 3. Add geographic concentration analysis for large providers
-- 4. Analyze common words in business names to identify service patterns
-- 5. Create provider similarity clusters based on name patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:39:10.251808
    - Additional Notes: Query focuses on market segmentation by provider size and could be useful for competitive analysis and M&A targeting. Consider adding fuzzy matching logic for business names to better handle variations in provider naming conventions.
    
    */