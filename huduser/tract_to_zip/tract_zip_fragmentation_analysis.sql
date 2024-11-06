-- mixed_geography_analysis.sql

-- Business Purpose: This query analyzes areas where Census Tracts are split across multiple ZIP codes,
-- highlighting potential challenges in service delivery, resource allocation, and community planning.
-- Understanding these geographic overlaps is crucial for healthcare organizations, government agencies,
-- and service providers who need to make decisions about territory assignments and resource distribution.

WITH tract_splits AS (
    -- Identify Census Tracts that are split across multiple ZIP codes
    SELECT 
        tract,
        COUNT(DISTINCT zip) as zip_count,
        MAX(res_ratio) as max_res_ratio,
        MIN(res_ratio) as min_res_ratio,
        AVG(res_ratio) as avg_res_ratio
    FROM mimi_ws_1.huduser.tract_to_zip
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.huduser.tract_to_zip)
    GROUP BY tract
    HAVING COUNT(DISTINCT zip) > 1
)

SELECT 
    -- Categorize tracts based on split complexity
    CASE 
        WHEN zip_count >= 5 THEN 'Highly Fragmented'
        WHEN zip_count >= 3 THEN 'Moderately Split'
        ELSE 'Minimally Split'
    END as split_category,
    
    -- Calculate summary statistics
    COUNT(*) as tract_count,
    AVG(zip_count) as avg_zips_per_tract,
    AVG(max_res_ratio - min_res_ratio) as avg_res_ratio_spread,
    
    -- Show distribution characteristics
    ROUND(AVG(avg_res_ratio), 3) as avg_residential_distribution,
    ROUND(MIN(min_res_ratio), 3) as min_res_ratio_found,
    ROUND(MAX(max_res_ratio), 3) as max_res_ratio_found

FROM tract_splits
GROUP BY 
    CASE 
        WHEN zip_count >= 5 THEN 'Highly Fragmented'
        WHEN zip_count >= 3 THEN 'Moderately Split'
        ELSE 'Minimally Split'
    END
ORDER BY 
    CASE split_category
        WHEN 'Highly Fragmented' THEN 1
        WHEN 'Moderately Split' THEN 2
        WHEN 'Minimally Split' THEN 3
    END;

-- How this query works:
-- 1. Creates a CTE that identifies Census Tracts split across multiple ZIP codes
-- 2. Calculates key metrics about the splits including count and residential ratios
-- 3. Categorizes the splits into three levels of complexity
-- 4. Provides summary statistics for each category

-- Assumptions and Limitations:
-- 1. Uses the most recent data snapshot available
-- 2. Focuses only on tracts that are split across multiple ZIP codes
-- 3. Categories are defined based on common splitting patterns
-- 4. Residential ratio is used as the primary measure of population distribution

-- Possible Extensions:
-- 1. Add temporal analysis to track how splits change over time
-- 2. Include business ratio analysis for commercial impact assessment
-- 3. Add geographic clustering to identify regional patterns
-- 4. Incorporate demographic data to understand population characteristics
-- 5. Create targeted lists of high-priority areas for service coordination

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:21:47.427332
    - Additional Notes: Query provides insights into geographic complexity where Census Tracts intersect with multiple ZIP codes, making it particularly valuable for organizations needing to understand service area overlaps and resource allocation challenges. Best used with most recent data snapshots and may need adjustment of fragmentation thresholds (3 and 5 ZIP codes) based on specific regional characteristics.
    
    */