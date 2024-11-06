
-- Medicare Advantage Plan Composition and Market Insights Analysis
-- File: ma_plan_market_analysis.sql
-- Purpose: Analyze Medicare Advantage contract characteristics to understand market structure and plan diversity

WITH plan_summary AS (
    -- Aggregate plan characteristics by organization type
    SELECT 
        organization_type,
        COUNT(DISTINCT contract_number) AS total_contracts,
        SUM(CASE WHEN snp_offered = 'Y' THEN 1 ELSE 0 END) AS snp_contract_count,
        SUM(enrollment_yearend) AS total_enrollment,
        ROUND(AVG(CASE WHEN snp_offered = 'Y' THEN enrollment_yearend ELSE NULL END), 2) AS avg_snp_enrollment,
        COUNT(DISTINCT plan_type) AS unique_plan_types,
        MAX(hedis_year) AS most_recent_year
    FROM mimi_ws_1.partcd.hedis_general
    WHERE population_type = 'Medicare'
    GROUP BY organization_type
)

SELECT 
    organization_type,
    total_contracts,
    snp_contract_count,
    ROUND(snp_contract_count * 100.0 / total_contracts, 2) AS snp_contract_percentage,
    total_enrollment,
    avg_snp_enrollment,
    unique_plan_types,
    most_recent_year
FROM plan_summary
ORDER BY total_contracts DESC;

-- Query Insights:
-- 1. Provides a comprehensive view of Medicare Advantage contract diversity
-- 2. Highlights Special Needs Plan (SNP) penetration across organization types
-- 3. Enables quick market structure assessment

-- Limitations:
-- - Single-year snapshot
-- - Aggregated data loses granular details
-- - Dependent on data submission completeness

-- Potential Extensions:
-- 1. Add geographic region analysis
-- 2. Trend analysis across multiple years
-- 3. Enrollment and plan type correlation studies


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:11:12.515678
    - Additional Notes: Query focuses on Medicare Advantage contract characteristics, highlighting plan diversity and Special Needs Plan (SNP) market penetration. Requires careful interpretation due to aggregated nature of the data.
    
    */