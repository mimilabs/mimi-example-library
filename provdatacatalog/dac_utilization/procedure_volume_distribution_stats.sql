-- Clinician Procedure Volume Distribution Analysis
-- Business Purpose: 
-- 1. Understand procedure volume patterns and identify outliers
-- 2. Support credentialing and network adequacy assessments
-- 3. Guide provider outreach and engagement strategies
-- 4. Identify potential quality or efficiency concerns

WITH procedure_stats AS (
    -- Calculate key statistics for each procedure category
    SELECT 
        procedure_category,
        COUNT(DISTINCT npi) as provider_count,
        AVG(count) as avg_procedures,
        PERCENTILE(count, 0.5) as median_procedures,
        PERCENTILE(count, 0.75) as p75_procedures,
        PERCENTILE(count, 0.9) as p90_procedures
    FROM mimi_ws_1.provdatacatalog.dac_utilization
    WHERE profile_display_indicator = 'Y'
    GROUP BY procedure_category
),

high_volume_categories AS (
    -- Identify procedure categories with significant variation
    SELECT 
        procedure_category,
        provider_count,
        avg_procedures,
        median_procedures,
        p90_procedures,
        ROUND((p90_procedures - median_procedures) / median_procedures * 100, 1) as volume_variation_pct
    FROM procedure_stats
    WHERE provider_count >= 100  -- Focus on categories with sufficient data
)

SELECT 
    hvc.procedure_category,
    hvc.provider_count as total_providers,
    ROUND(hvc.median_procedures, 1) as median_procedures,
    ROUND(hvc.p90_procedures, 1) as p90_procedures,
    hvc.volume_variation_pct as volume_spread_pct,
    -- Count providers significantly above p90
    COUNT(DISTINCT CASE 
        WHEN u.count > hvc.p90_procedures * 1.5 
        THEN u.npi 
    END) as high_outlier_count
FROM high_volume_categories hvc
LEFT JOIN mimi_ws_1.provdatacatalog.dac_utilization u
    ON hvc.procedure_category = u.procedure_category
GROUP BY 
    hvc.procedure_category,
    hvc.provider_count,
    hvc.median_procedures,
    hvc.p90_procedures,
    hvc.volume_variation_pct
ORDER BY volume_spread_pct DESC
LIMIT 20;

-- How it works:
-- 1. Calculates key statistics for each procedure category
-- 2. Identifies categories with significant volume variation
-- 3. Counts providers with unusually high volumes
-- 4. Returns top 20 procedure categories by volume variation

-- Assumptions and Limitations:
-- 1. Assumes profile_display_indicator = 'Y' indicates valid records
-- 2. Focuses on categories with 100+ providers for statistical significance
-- 3. Defines high outliers as 1.5x above 90th percentile
-- 4. Limited to Medicare data, may not represent total practice volume

-- Possible Extensions:
-- 1. Add temporal analysis to track volume changes over time
-- 2. Include geographic segmentation for regional patterns
-- 3. Correlate with quality metrics or outcomes data
-- 4. Add provider specialty analysis within categories
-- 5. Develop provider peer group comparisons

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:08:33.457715
    - Additional Notes: The query focuses on procedure category-level distribution analysis rather than individual provider metrics. It uses statistical thresholds (90th percentile, 1.5x multiplier) that may need adjustment based on specific business needs. The minimum provider count of 100 per category might need to be modified for specialties with fewer practitioners.
    
    */