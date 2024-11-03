-- minority_health_equity_analysis_2000.sql

-- Business Purpose:
-- Identify census tracts with high concentrations of minority populations and socioeconomic challenges
-- to support health equity initiatives and culturally-competent healthcare program planning.
-- This analysis helps healthcare organizations and public health departments target resources
-- and develop culturally-appropriate interventions in underserved communities.

WITH minority_metrics AS (
    SELECT 
        state_name,
        county,
        -- Calculate minority population size and percentage
        SUM(g3v1n) as total_minority_pop,
        SUM(totpop2000) as total_pop,
        ROUND(SUM(g3v1n)*100.0/SUM(totpop2000),1) as minority_pct,
        -- Calculate key health equity indicators
        ROUND(AVG(g3v2r)*100,1) as limited_english_pct,
        ROUND(AVG(g1v1r)*100,1) as poverty_pct,
        ROUND(AVG(g4v4r)*100,1) as no_vehicle_pct,
        -- Calculate average vulnerability scores
        ROUND(AVG(usg3tp),1) as minority_vulnerability_score,
        ROUND(AVG(usg1tp),1) as socioeconomic_vulnerability_score
    FROM mimi_ws_1.cdc.svi_censustract_y2000
    GROUP BY state_name, county
    HAVING SUM(totpop2000) > 10000  -- Focus on areas with significant population
)

SELECT 
    state_name,
    county,
    total_minority_pop,
    minority_pct,
    limited_english_pct,
    poverty_pct,
    no_vehicle_pct,
    minority_vulnerability_score,
    socioeconomic_vulnerability_score
FROM minority_metrics
WHERE minority_pct > 30  -- Focus on areas with substantial minority populations
  AND (minority_vulnerability_score > 0.75 OR socioeconomic_vulnerability_score > 0.75)
ORDER BY minority_pct DESC, total_minority_pop DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE that aggregates minority population and key health equity metrics at county level
-- 2. Calculates percentages for minority population, limited English proficiency, poverty, and transportation access
-- 3. Includes vulnerability scores for minority status and socioeconomic factors
-- 4. Filters results to focus on counties with significant minority populations and high vulnerability scores

-- Assumptions and Limitations:
-- - Analysis is limited to year 2000 data
-- - County-level aggregation may mask tract-level disparities
-- - Population threshold of 10,000 excludes smaller communities
-- - Does not break down specific minority groups
-- - Does not account for changes in demographics since 2000

-- Possible Extensions:
-- 1. Add specific minority group breakdowns if available
-- 2. Include healthcare facility proximity analysis
-- 3. Compare with health outcome data if available
-- 4. Add geographic clustering analysis
-- 5. Incorporate language-specific service needs
-- 6. Compare with current community health needs assessments
-- 7. Add analysis of healthcare workforce diversity needs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:27:13.636111
    - Additional Notes: Query aggregates data at county level which may obscure granular tract-level patterns. The 30% minority population threshold and 10,000 population minimum should be adjusted based on specific regional demographics and analysis needs. Consider supplementing with tract-level analysis for more detailed local insights.
    
    */