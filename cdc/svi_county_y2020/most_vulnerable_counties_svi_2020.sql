
/*******************************************************************************
Title: Most Socially Vulnerable Counties Analysis - 2020
 
Business Purpose:
This query identifies the counties with the highest overall social vulnerability
based on CDC's Social Vulnerability Index (SVI) data from 2020. It helps
decision makers target resources and support to communities most in need during
disasters or public health emergencies.

The analysis examines:
- Overall vulnerability ranking 
- Key contributing factors across the 4 SVI themes:
  1. Socioeconomic Status
  2. Household Composition
  3. Racial/Ethnic Minority Status
  4. Housing/Transportation
*******************************************************************************/

WITH county_summary AS (
  SELECT 
    state,
    county,
    e_totpop as total_population,
    
    -- Overall vulnerability scores
    ROUND(rpl_themes * 100, 1) as overall_vulnerability_percentile,
    
    -- Theme-specific vulnerability scores 
    ROUND(rpl_theme1 * 100, 1) as socioeconomic_percentile,
    ROUND(rpl_theme2 * 100, 1) as household_comp_percentile, 
    ROUND(rpl_theme3 * 100, 1) as minority_percentile,
    ROUND(rpl_theme4 * 100, 1) as housing_trans_percentile,
    
    -- Key contributing factors
    ROUND(ep_pov150, 1) as pct_below_poverty,
    ROUND(ep_unemp, 1) as unemployment_rate,
    ROUND(ep_minrty, 1) as pct_minority,
    ROUND(ep_noveh, 1) as pct_no_vehicle
    
  FROM mimi_ws_1.cdc.svi_county_y2020
  WHERE e_totpop > 0  -- Exclude invalid population records
)

SELECT
  state,
  county,
  total_population,
  overall_vulnerability_percentile,
  socioeconomic_percentile,
  household_comp_percentile,
  minority_percentile, 
  housing_trans_percentile,
  pct_below_poverty,
  unemployment_rate,
  pct_minority,
  pct_no_vehicle

FROM county_summary 
WHERE overall_vulnerability_percentile >= 90 -- Focus on most vulnerable counties
ORDER BY overall_vulnerability_percentile DESC
LIMIT 20;

/*******************************************************************************
How this query works:
1. Creates a CTE to calculate key vulnerability metrics for each county
2. Filters to counties with overall vulnerability in top 10%
3. Returns the 20 most vulnerable counties with key contributing factors

Assumptions and Limitations:
- Uses 2020 data only - vulnerability patterns may have changed since then
- Equal weighting given to all themes in overall vulnerability score
- Population threshold could be adjusted based on analysis needs
- MOE (Margin of Error) values not considered in this basic analysis

Possible Extensions:
1. Add year-over-year comparison to identify trending vulnerability
2. Include geographic clustering analysis to find regional patterns
3. Cross-reference with disaster impact data
4. Add statistical significance testing using MOE values
5. Create vulnerability categories/tiers for different intervention strategies
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:46:46.999328
    - Additional Notes: Query focuses on top 20 counties by overall SVI score. Ensure table access permissions as the dataset contains sensitive demographic information. The 90th percentile threshold for vulnerability can be adjusted based on analysis needs. Population filtering may exclude some smaller vulnerable communities.
    
    */