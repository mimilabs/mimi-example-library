-- Title: NHANES Recent Tobacco Product Transitions Analysis

-- Business Purpose:
-- - Track shifts between traditional and emerging tobacco products
-- - Identify patterns of multiple product usage (dual/poly use)
-- - Support product-specific cessation program development
-- - Guide tobacco control policy by understanding product migration

WITH user_products AS (
    -- Get users and their product combinations
    SELECT 
        seqn,
        CASE WHEN smq690a = 1 THEN 1 ELSE 0 END as uses_cigarettes,
        CASE WHEN smq690h = 1 THEN 1 ELSE 0 END as uses_ecigarettes,
        CASE WHEN smq690c = 1 THEN 1 ELSE 0 END as uses_cigars,
        CASE WHEN smq851 = 1 THEN 1 ELSE 0 END as uses_smokeless,
        CASE WHEN smq863 = 1 THEN 1 ELSE 0 END as uses_nrt
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_recent_tobacco_use
    WHERE smdany = 1 -- Focus on active tobacco users
)

SELECT 
    -- Calculate product usage patterns
    SUM(uses_cigarettes) as total_cigarette_users,
    SUM(uses_ecigarettes) as total_ecig_users,
    SUM(uses_cigars) as total_cigar_users,
    SUM(uses_smokeless) as total_smokeless_users,
    SUM(uses_nrt) as total_nrt_users,
    
    -- Calculate dual use patterns
    SUM(CASE WHEN uses_cigarettes = 1 AND uses_ecigarettes = 1 THEN 1 ELSE 0 END) as cig_and_ecig_users,
    SUM(CASE WHEN uses_cigarettes = 1 AND uses_smokeless = 1 THEN 1 ELSE 0 END) as cig_and_smokeless_users,
    
    -- Calculate poly use (3+ products)
    SUM(CASE WHEN (uses_cigarettes + uses_ecigarettes + uses_cigars + uses_smokeless) >= 3 THEN 1 ELSE 0 END) as poly_users,
    
    -- Calculate NRT adoption among different user groups
    SUM(CASE WHEN uses_cigarettes = 1 AND uses_nrt = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(uses_cigarettes), 0) as pct_cig_users_with_nrt,
    SUM(CASE WHEN uses_ecigarettes = 1 AND uses_nrt = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(uses_ecigarettes), 0) as pct_ecig_users_with_nrt
FROM user_products;

-- How the Query Works:
-- 1. Creates a CTE to normalize product usage indicators
-- 2. Calculates various product usage combinations
-- 3. Focuses on dual use and poly use patterns
-- 4. Examines NRT adoption across product types

-- Assumptions and Limitations:
-- - Assumes recent use (past 5 days) is representative of regular usage
-- - Limited to products explicitly tracked in NHANES
-- - Does not account for frequency/intensity of use
-- - Cross-sectional view only (no longitudinal tracking)

-- Possible Extensions:
-- 1. Add demographic breakdowns (age, gender, etc.)
-- 2. Include usage frequency/intensity metrics
-- 3. Compare patterns across survey years
-- 4. Add economic indicators (income, education)
-- 5. Incorporate geographic analysis if available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:29:20.816239
    - Additional Notes: Query focuses on cross-product usage patterns and transitions between traditional and emerging tobacco products. Does not include temporal analysis of transitions - represents a snapshot of concurrent use patterns. Best used in conjunction with demographic data for targeted intervention planning.
    
    */