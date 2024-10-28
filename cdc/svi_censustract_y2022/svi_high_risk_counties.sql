
/*************************************************************************
Social Vulnerability Index (SVI) Analysis - High Risk Areas by Theme
************************************************************************* 

This query identifies census tracts with the highest social vulnerability 
across the four main SVI themes, helping identify communities most in need
of support during emergencies and disasters.

Business Purpose:
- Identify most vulnerable communities to prioritize emergency planning
- Target resources and interventions to highest-risk areas  
- Support data-driven decisions for public health preparedness

Themes analyzed:
1. Socioeconomic Status
2. Household Composition & Disability
3. Minority Status & Language
4. Housing Type & Transportation
*/

WITH high_risk_tracts AS (
  SELECT 
    state,
    county,
    location,
    e_totpop as population,
    
    -- Theme rankings (higher = more vulnerable)
    rpl_theme1 as socioeconomic_rank,
    rpl_theme2 as household_rank, 
    rpl_theme3 as minority_rank,
    rpl_theme4 as housing_transport_rank,
    rpl_themes as overall_rank,
    
    -- Flag if in top 10% most vulnerable for any theme
    CASE WHEN rpl_theme1 >= 0.9 THEN 1 ELSE 0 END as high_socioeconomic_risk,
    CASE WHEN rpl_theme2 >= 0.9 THEN 1 ELSE 0 END as high_household_risk,
    CASE WHEN rpl_theme3 >= 0.9 THEN 1 ELSE 0 END as high_minority_risk,
    CASE WHEN rpl_theme4 >= 0.9 THEN 1 ELSE 0 END as high_housing_risk,
    CASE WHEN rpl_themes >= 0.9 THEN 1 ELSE 0 END as high_overall_risk
    
  FROM mimi_ws_1.cdc.svi_censustract_y2022
  WHERE e_totpop > 0  -- Exclude unpopulated tracts
)

SELECT
  state,
  county,
  COUNT(*) as total_tracts,
  SUM(population) as total_population,
  
  -- Count high risk tracts by theme
  SUM(high_socioeconomic_risk) as socioeconomic_risk_tracts,
  SUM(high_household_risk) as household_risk_tracts,  
  SUM(high_minority_risk) as minority_risk_tracts,
  SUM(high_housing_risk) as housing_risk_tracts,
  SUM(high_overall_risk) as overall_risk_tracts,
  
  -- Calculate % of population in high risk tracts
  ROUND(SUM(CASE WHEN high_overall_risk = 1 THEN population ELSE 0 END) * 100.0 / SUM(population), 1) 
    as pct_pop_high_risk

FROM high_risk_tracts
GROUP BY state, county
HAVING total_tracts >= 5  -- Only include counties with sufficient data
ORDER BY pct_pop_high_risk DESC
LIMIT 100;

/*
HOW IT WORKS:
1. CTE identifies census tracts in top 10% most vulnerable for each theme
2. Main query aggregates to county level to show geographic patterns
3. Calculates both count of high-risk tracts and affected population %
4. Focuses on counties with adequate sample size (5+ tracts)

ASSUMPTIONS & LIMITATIONS:
- Uses 90th percentile threshold for "high risk" - could be adjusted
- County-level aggregation may mask local variations
- Does not account for interaction effects between themes
- Population-weighted metrics may better reflect impact

POSSIBLE EXTENSIONS:
1. Add time trends by comparing across different years
2. Break down contributing factors within each theme
3. Map results or add geographic clustering analysis
4. Correlate with health outcomes or disaster impacts
5. Create vulnerability indexes for specific hazard types
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:26:39.844549
    - Additional Notes: Query focuses on county-level SVI risk patterns across the four CDC vulnerability themes. The results are filtered to counties with 5+ census tracts for statistical reliability and include both absolute counts of high-risk tracts and population-weighted metrics. Consider adjusting the 90th percentile threshold (0.9) in the CTE based on specific use cases.
    
    */