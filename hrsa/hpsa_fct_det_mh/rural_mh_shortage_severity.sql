-- rural_mh_shortage_severity.sql
-- Rural Mental Health Access Crisis Analysis
--
-- This analysis focuses on identifying the most severely underserved rural areas
-- for mental health services, helping prioritize interventions and resource allocation
-- in rural communities where access barriers are often most acute.
--
-- Business Purpose:
-- - Identify rural areas with critical mental health provider shortages
-- - Quantify the scale of rural mental health access gaps
-- - Support rural healthcare investment and policy decisions
-- - Enable targeted provider recruitment strategies

WITH rural_shortage_areas AS (
    -- Focus on currently designated rural HPSAs
    SELECT 
        hpsa_name,
        common_state_name,
        common_county_name,
        hpsa_score,
        hpsa_designation_population,
        hpsa_fte,
        hpsa_formal_ratio,
        pct_of_population_below_100pct_poverty
    FROM mimi_ws_1.hrsa.hpsa_fct_det_mh
    WHERE rural_status = 'Rural'
        AND hpsa_status = 'Designated'
        AND designation_type = 'Geographic Area'
),

severity_rankings AS (
    -- Rank areas based on multiple shortage indicators
    SELECT 
        *,
        ROW_NUMBER() OVER (
            ORDER BY 
                hpsa_score DESC,
                hpsa_formal_ratio DESC,
                pct_of_population_below_100pct_poverty DESC
        ) as severity_rank
    FROM rural_shortage_areas
)

-- Present the most critical rural shortage areas
SELECT 
    common_state_name as state,
    common_county_name as county,
    hpsa_name,
    hpsa_score,
    ROUND(hpsa_designation_population) as affected_population,
    ROUND(hpsa_fte, 1) as providers_needed,
    ROUND(hpsa_formal_ratio) as population_per_provider,
    ROUND(pct_of_population_below_100pct_poverty, 1) as poverty_rate,
    severity_rank
FROM severity_rankings
WHERE severity_rank <= 20
ORDER BY severity_rank;

-- How this query works:
-- 1. Filters for rural geographic HPSAs that are currently designated
-- 2. Combines multiple metrics to rank shortage severity
-- 3. Returns top 20 most severe shortage areas with key metrics
--
-- Assumptions and Limitations:
-- - Focuses only on geographic HPSAs (excludes facility and population-based)
-- - Equal weighting given to score, ratio, and poverty in ranking
-- - Rural classification based on HRSA's definition
-- - Point-in-time analysis based on current designations
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis for shortage metrics
-- 2. Include distance to nearest mental health facilities
-- 3. Incorporate state-specific mental health funding data
-- 4. Add demographic analysis of affected populations
-- 5. Compare rural vs urban shortage patterns
-- 6. Calculate potential economic impact of provider shortages

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:19:35.034206
    - Additional Notes: Query prioritizes geographic mental health HPSAs using a composite ranking system based on HPSA score, provider ratios, and poverty rates. Limited to active rural designations only. Results capped at top 20 most severe areas to maintain focus on critical needs.
    
    */