/*
svi_uninsured_and_disabilities.sql

Purpose: 
Analyze areas with high rates of both uninsured populations and disabilities to identify 
communities with potentially significant healthcare access challenges. This information 
helps healthcare organizations and policymakers:
- Target outreach programs and resources
- Plan accessible healthcare facilities
- Design appropriate intervention programs
- Allocate funding for healthcare support services

Business Value:
- Identifies underserved populations needing both insurance coverage and disability support
- Supports strategic planning for healthcare facility locations
- Guides resource allocation for community health programs
- Assists with healthcare policy development
*/

WITH ranked_tracts AS (
  SELECT 
    state,
    county,
    location,
    e_totpop as total_population,
    ep_uninsur as pct_uninsured,
    ep_disabl as pct_disabled,
    -- Create composite score combining uninsured and disability rates
    (ep_uninsur + ep_disabl)/2 as healthcare_need_score,
    -- Calculate relative rankings within each state
    PERCENT_RANK() OVER (PARTITION BY state ORDER BY (ep_uninsur + ep_disabl)/2) as state_rank
  FROM mimi_ws_1.cdc.svi_censustract_y2022
  WHERE e_totpop >= 100  -- Filter out very small populations
    AND ep_uninsur IS NOT NULL 
    AND ep_disabl IS NOT NULL
)

SELECT 
  state,
  county,
  location,
  total_population,
  ROUND(pct_uninsured, 1) as pct_uninsured,
  ROUND(pct_disabled, 1) as pct_disabled,
  ROUND(healthcare_need_score, 1) as healthcare_need_score,
  ROUND(state_rank * 100, 1) as state_percentile
FROM ranked_tracts
WHERE state_rank >= 0.9  -- Top 10% highest need areas within each state
ORDER BY 
  state,
  healthcare_need_score DESC;

/*
How it works:
1. Calculates a composite healthcare need score based on uninsured and disability rates
2. Ranks areas within each state using PERCENT_RANK
3. Filters for top 10% highest need areas
4. Returns detailed results sorted by state and need score

Assumptions and Limitations:
- Equal weighting given to uninsured and disability rates
- Minimum population threshold of 100 to exclude statistical outliers
- Does not account for severity of disabilities
- Does not consider proximity to healthcare facilities
- State-level rankings may mask cross-state comparisons

Possible Extensions:
1. Add income/poverty metrics to refine need assessment
2. Include distance to nearest hospitals/clinics
3. Segment by urban/rural classification
4. Incorporate age demographics
5. Add trend analysis using historical data
6. Include additional healthcare access barriers like transportation
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:08:11.789924
    - Additional Notes: Query focuses on intersection of uninsured rates and disability prevalence to identify healthcare access vulnerability hotspots. Rankings are relative within each state rather than nationally, which may mask cross-state disparities. Minimum population threshold of 100 helps ensure statistical reliability.
    
    */