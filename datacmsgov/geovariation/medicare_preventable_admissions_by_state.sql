-- medicare_geo_preventable_admissions.sql

-- Purpose: Analyze preventable hospital admission rates across geographic regions to identify
-- opportunities for improving primary care and reducing avoidable hospitalizations.
-- This analysis helps healthcare organizations and policymakers target interventions
-- to reduce costly hospital admissions for ambulatory care sensitive conditions.

-- Main Query
SELECT 
    year,
    bene_geo_lvl,
    bene_geo_desc,
    bene_geo_cd,
    benes_ffs_cnt,
    bene_avg_age,
    bene_dual_pct,

    -- Diabetes complications admission rates by age group
    pqi03_dbts_age_lt_65 as diabetes_adm_under65,
    pqi03_dbts_age_65_74 as diabetes_adm_65to74,
    pqi03_dbts_age_ge_75 as diabetes_adm_over75,

    -- COPD/Asthma admission rates by age group 
    pqi05_copd_asthma_age_40_64 as copd_adm_40to64,
    pqi05_copd_asthma_age_65_74 as copd_adm_65to74,
    pqi05_copd_asthma_age_ge_75 as copd_adm_over75,

    -- Heart failure admission rates by age group
    pqi08_chf_age_lt_65 as chf_adm_under65,
    pqi08_chf_age_65_74 as chf_adm_65to74,
    pqi08_chf_age_ge_75 as chf_adm_over75

FROM mimi_ws_1.datacmsgov.geovariation

-- Focus on state-level data for the most recent year
WHERE bene_geo_lvl = 'State'
AND year = (SELECT MAX(year) FROM mimi_ws_1.datacmsgov.geovariation)

-- Order by total admission burden (diabetes + COPD + CHF) for age 65+ 
ORDER BY (pqi03_dbts_age_65_74 + pqi03_dbts_age_ge_75 + 
         pqi05_copd_asthma_age_65_74 + pqi05_copd_asthma_age_ge_75 +
         pqi08_chf_age_65_74 + pqi08_chf_age_ge_75) DESC;

-- How this query works:
-- 1. Selects key demographic data and Prevention Quality Indicators (PQIs) for three major
--    chronic conditions across age groups
-- 2. Focuses on state-level variation to enable actionable geographic targeting
-- 3. Orders results by combined admission burden for 65+ population
-- 4. Uses standardized PQI measures that control for population size differences

-- Assumptions and limitations:
-- - PQI rates are per 100,000 FFS Medicare beneficiaries
-- - Analysis limited to fee-for-service Medicare population
-- - Does not account for differences in population health status or social determinants
-- - State-level analysis may mask important sub-state regional variations

-- Possible extensions:
-- 1. Add year-over-year trend analysis to identify improving/worsening regions
-- 2. Incorporate cost data to quantify financial impact of preventable admissions
-- 3. Add correlation analysis with primary care access measures
-- 4. Break out analysis by demographic factors (race, dual eligibility status)
-- 5. Include additional PQIs like UTI and pneumonia admissions
-- 6. Add county-level detail for states with highest admission rates/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:13:29.047185
    - Additional Notes: Query focuses on three key chronic conditions (diabetes, COPD, heart failure) that are commonly used as indicators of healthcare quality and access. Results are normalized per 100,000 beneficiaries for fair comparison across states. The ordering by total admission burden helps identify states that may need intervention across multiple conditions.
    
    */