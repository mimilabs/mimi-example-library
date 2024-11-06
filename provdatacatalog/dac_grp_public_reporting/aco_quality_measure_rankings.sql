-- analyze_aco_measure_performance.sql

-- Business Purpose: Analyze measure performance patterns across Accountable Care Organizations (ACOs)
-- to identify high-performing ACOs and their key quality metrics. This analysis helps:
-- 1. Identify successful ACO quality management strategies
-- 2. Guide provider group decisions about ACO partnerships
-- 3. Support value-based care program optimization

WITH aco_measures AS (
    -- Get distinct ACO-measure combinations and aggregate performance
    SELECT 
        COALESCE(aco_nm_1, aco_nm_2, aco_nm_3) as aco_name,
        measure_cd,
        measure_title,
        COUNT(DISTINCT org_pac_id) as provider_group_count,
        AVG(CAST(prf_rate AS DOUBLE)) as avg_performance_rate,
        AVG(CAST(star_value AS DOUBLE)) as avg_star_rating,
        SUM(CAST(patient_count AS BIGINT)) as total_patients
    FROM mimi_ws_1.provdatacatalog.dac_grp_public_reporting
    WHERE 
        -- Focus on ACO-affiliated groups
        (aco_nm_1 IS NOT NULL OR aco_nm_2 IS NOT NULL OR aco_nm_3 IS NOT NULL)
        -- Exclude non-performance measures
        AND prf_rate IS NOT NULL 
    GROUP BY 
        COALESCE(aco_nm_1, aco_nm_2, aco_nm_3),
        measure_cd,
        measure_title
)

-- Identify top performing measures for each ACO
SELECT 
    aco_name,
    measure_title,
    provider_group_count,
    ROUND(avg_performance_rate, 2) as avg_performance_rate,
    ROUND(avg_star_rating, 1) as avg_star_rating,
    total_patients,
    -- Rank measures within each ACO by performance
    ROW_NUMBER() OVER (
        PARTITION BY aco_name 
        ORDER BY avg_star_rating DESC, avg_performance_rate DESC
    ) as measure_rank
FROM aco_measures
WHERE 
    -- Filter for statistical significance
    provider_group_count >= 5
    AND total_patients >= 100
ORDER BY 
    aco_name,
    measure_rank
LIMIT 100;

-- How this query works:
-- 1. Creates a CTE to aggregate measure performance at the ACO level
-- 2. Combines multiple ACO name columns into a single column
-- 3. Calculates key performance metrics: average rates, star ratings, patient volumes
-- 4. Ranks measures within each ACO to identify strengths
-- 5. Applies minimum thresholds for statistical relevance

-- Assumptions and Limitations:
-- 1. ACOs are identified by name matches across aco_nm columns
-- 2. Performance rates are assumed to be comparable across measures
-- 3. Minimum thresholds (5 groups, 100 patients) may need adjustment
-- 4. Does not account for measure complexity or risk adjustment

-- Possible Extensions:
-- 1. Add trending analysis across multiple periods
-- 2. Include geographic analysis of ACO performance
-- 3. Compare ACO performance to non-ACO groups
-- 4. Add measure category analysis (Quality vs PI vs IA)
-- 5. Incorporate inverse measure adjustments
-- 6. Add benchmark comparisons using five_star_benchmark

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:23:58.718572
    - Additional Notes: Query focuses on ACO performance metrics with minimum thresholds of 5 provider groups and 100 patients for statistical relevance. Performance rankings may be affected by measure mix and patient population differences across ACOs. Consider adjusting thresholds based on specific analysis needs.
    
    */