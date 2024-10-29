-- medicare_demographic_disparities.sql

-- Purpose: Analyze demographic disparities in Medicare beneficiary characteristics, coverage, 
-- and dual eligibility status across geographic regions to identify potential healthcare equity gaps
-- and inform targeted intervention strategies.

-- Business value:
-- - Identifies underserved populations and demographic-based disparities
-- - Supports healthcare equity initiatives and resource allocation
-- - Informs outreach strategies for vulnerable populations
-- - Helps meet CMS health equity requirements and reporting

WITH demographic_summary AS (
  SELECT 
    year,
    bene_geo_lvl,
    bene_geo_desc,
    bene_geo_cd,
    
    -- Beneficiary counts and coverage
    benes_total_cnt,
    benes_ma_cnt,
    ma_prtcptn_rate,
    
    -- Demographics
    bene_avg_age,
    bene_feml_pct,
    bene_race_black_pct,
    bene_race_hspnc_pct,
    bene_race_wht_pct,
    bene_race_othr_pct,
    
    -- Dual eligibility as poverty indicator  
    bene_dual_pct,
    
    -- Risk score
    bene_avg_risk_scre
    
  FROM mimi_ws_1.datacmsgov.geovariation
  WHERE bene_geo_lvl = 'State' -- Focus on state level
    AND year >= 2019 -- Recent years
    AND bene_age_lvl = 'All Beneficiaries'
)

SELECT
  year,
  bene_geo_desc AS state,
  
  -- Format key metrics
  ROUND(bene_avg_age,1) as avg_age,
  ROUND(bene_feml_pct,1) as pct_female,
  ROUND(bene_race_black_pct,1) as pct_black,
  ROUND(bene_race_hspnc_pct,1) as pct_hispanic,
  ROUND(bene_dual_pct,1) as pct_dual_eligible,
  ROUND(ma_prtcptn_rate,1) as pct_medicare_advantage,
  ROUND(bene_avg_risk_scre,2) as risk_score,
  
  -- Calculate relative measures
  ROUND(bene_dual_pct / 
    AVG(bene_dual_pct) OVER (PARTITION BY year),2) 
    as dual_eligible_ratio_to_natl_avg,
    
  ROUND(bene_avg_risk_scre / 
    AVG(bene_avg_risk_scre) OVER (PARTITION BY year),2)
    as risk_score_ratio_to_natl_avg

FROM demographic_summary
ORDER BY year DESC, bene_dual_pct DESC;

/* How this query works:
1. Creates demographic_summary CTE to gather relevant demographic metrics
2. Calculates state-level summaries with relative measures compared to national averages
3. Focuses on recent years and all beneficiary age groups
4. Orders results by year and dual eligibility percentage to highlight states with highest poverty levels

Assumptions and limitations:
- Uses dual eligibility as proxy for socioeconomic status
- State-level analysis may mask county-level disparities
- Risk scores influenced by coding intensity variations
- Race/ethnicity categories may not capture full diversity

Possible extensions:
1. Add county-level analysis for targeted geographic insights
2. Include year-over-year trend analysis of demographic shifts
3. Correlate demographics with quality metrics and outcomes
4. Add statistical analysis of demographic impact on costs
5. Break out Medicare Advantage penetration by demographic segments
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:37:38.488318
    - Additional Notes: Query focuses on measuring healthcare equity gaps through demographic and socioeconomic indicators. Limited to state-level analysis and uses dual eligibility as primary poverty indicator. Results best used alongside additional social determinants of health data for comprehensive equity assessment.
    
    */