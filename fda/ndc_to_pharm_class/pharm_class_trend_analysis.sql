-- drug_class_evolution_trends.sql

-- Business Purpose:
-- Analyze temporal patterns in pharmaceutical classifications to identify emerging trends
-- and shifts in drug development focus over time. This helps:
-- - Investment planning in pharmaceutical R&D
-- - Understanding market dynamics and therapeutic focus areas
-- - Strategic planning for healthcare organizations
-- - Identifying potential gaps in drug development

WITH yearly_class_stats AS (
    -- Get base counts by year and class type
    SELECT 
        YEAR(mimi_src_file_date) as data_year,
        pharm_class_type,
        pharm_class,
        COUNT(DISTINCT cms_ndc) as drug_count
    FROM mimi_ws_1.fda.ndc_to_pharm_class 
    WHERE pharm_class_type IS NOT NULL
    GROUP BY 
        YEAR(mimi_src_file_date),
        pharm_class_type,
        pharm_class
),

ranked_classes AS (
    -- Rank classes within each type and year
    SELECT 
        data_year,
        pharm_class_type,
        pharm_class,
        drug_count,
        ROW_NUMBER() OVER (
            PARTITION BY data_year, pharm_class_type 
            ORDER BY drug_count DESC
        ) as rank_in_year
    FROM yearly_class_stats
)

-- Final output showing top classes by type and their evolution
SELECT 
    data_year,
    pharm_class_type,
    pharm_class,
    drug_count,
    ROUND(100.0 * drug_count / SUM(drug_count) OVER (
        PARTITION BY data_year, pharm_class_type
    ), 2) as percentage_within_type
FROM ranked_classes
WHERE rank_in_year <= 5
ORDER BY 
    data_year DESC,
    pharm_class_type,
    drug_count DESC;

-- How it works:
-- 1. First CTE aggregates drug counts by year and pharmacologic class
-- 2. Second CTE ranks classes within each year and type
-- 3. Final query shows top 5 classes per type per year with their relative percentages

-- Assumptions and Limitations:
-- - Uses mimi_src_file_date as proxy for temporal analysis
-- - Limited to top 5 classes per category
-- - Requires non-null pharm_class_type values
-- - Does not account for drug discontinuations or market exits

-- Possible Extensions:
-- 1. Add year-over-year growth rates for each class
-- 2. Include comparative analysis with previous periods
-- 3. Add filters for specific therapeutic areas
-- 4. Incorporate market size or revenue data through joins
-- 5. Add trend analysis using moving averages
-- 6. Compare class distributions across different manufacturers

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:08:16.454532
    - Additional Notes: Query tracks pharmacological class evolution over time, focusing on market share within each classification type. May require significant processing time for large datasets. Consider adding date range filters for performance optimization on large datasets. Results are dependent on the quality and consistency of mimi_src_file_date values.
    
    */