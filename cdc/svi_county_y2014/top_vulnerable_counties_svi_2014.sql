
/*******************************************************************************
Title: Top Counties with Highest Overall Social Vulnerability Risk Analysis 2014

Business Purpose:
This query identifies counties with the highest overall social vulnerability risks
based on CDC's Social Vulnerability Index (SVI) data from 2014. It helps:
- Target emergency preparedness resources to high-risk areas
- Prioritize disaster response planning
- Guide public health interventions in vulnerable communities

Key measures analyzed:
- Overall SVI percentile ranking (rpl_themes)
- Theme-specific vulnerabilities (socioeconomic, household composition, 
  minority status, housing/transportation)
- Population metrics to understand scale of impact
*******************************************************************************/

WITH ranked_counties AS (
  -- Calculate ranks and identify high risk counties
  SELECT 
    state,
    county,
    e_totpop as total_population,
    ROUND(rpl_themes * 100, 1) as overall_vulnerability_percentile,
    ROUND(rpl_theme1 * 100, 1) as socioeconomic_percentile,
    ROUND(rpl_theme2 * 100, 1) as household_comp_percentile, 
    ROUND(rpl_theme3 * 100, 1) as minority_lang_percentile,
    ROUND(rpl_theme4 * 100, 1) as housing_trans_percentile,
    -- Calculate vulnerability flags
    CASE WHEN rpl_themes >= 0.90 THEN 'Very High'
         WHEN rpl_themes >= 0.75 THEN 'High'
         WHEN rpl_themes >= 0.50 THEN 'Moderate'
         ELSE 'Low' END as vulnerability_level,
    RANK() OVER (ORDER BY rpl_themes DESC) as vulnerability_rank
  FROM mimi_ws_1.cdc.svi_county_y2014
  WHERE rpl_themes IS NOT NULL
)

SELECT 
  state,
  county,
  FORMAT_NUMBER(total_population, 0) as total_population,
  overall_vulnerability_percentile,
  socioeconomic_percentile,
  household_comp_percentile,
  minority_lang_percentile, 
  housing_trans_percentile,
  vulnerability_level,
  vulnerability_rank
FROM ranked_counties
WHERE vulnerability_rank <= 20
ORDER BY vulnerability_rank;

/*******************************************************************************
How it works:
1. CTE ranks counties based on overall SVI (rpl_themes)
2. Calculates percentiles for overall and theme-specific vulnerability 
3. Assigns vulnerability levels based on percentile thresholds
4. Returns top 20 most vulnerable counties with key metrics

Assumptions & Limitations:
- Uses 2014 data which may not reflect current conditions
- County-level aggregation masks within-county variations
- Rankings are relative within US, not absolute measures
- Missing values are excluded from analysis

Possible Extensions:
1. Add geographic clustering analysis to identify vulnerable regions
2. Compare with disaster incident data to validate risk levels
3. Trend analysis if combined with other years' data
4. Add demographic breakdowns of vulnerable populations
5. Include specific risk factors (poverty, housing, etc.) detail
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:16:53.314119
    - Additional Notes: Query focuses on county-level social vulnerability using CDC's SVI metrics. The results are limited to top 20 counties and include both overall and theme-specific vulnerability scores. Note that percentile calculations are multiplied by 100 for better readability. The vulnerability_level categorization uses standard quartile breakpoints (90th, 75th, 50th percentiles) which can be adjusted based on specific needs.
    
    */