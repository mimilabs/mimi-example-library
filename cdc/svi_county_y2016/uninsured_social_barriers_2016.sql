-- Title: Social Determinants of Health and Uninsured Population Hotspots 2016
--
-- Business Purpose:
-- Analyzes counties with high uninsured rates in relation to key social vulnerability factors
-- to identify priority areas for healthcare access initiatives and community health programs.
-- This helps:
-- - Healthcare organizations target expansion and outreach efforts
-- - Public health departments allocate resources 
-- - Policymakers understand gaps in healthcare coverage
--

WITH UninsuredHotspots AS (
  SELECT 
    state,
    county,
    e_totpop,
    e_uninsur,
    ep_uninsur,
    -- Key social factors that often correlate with lack of insurance
    ep_pov as poverty_rate,
    ep_limeng as limited_english_rate,
    ep_minrty as minority_rate,
    ep_nohsdp as no_hs_diploma_rate
  FROM mimi_ws_1.cdc.svi_county_y2016
  WHERE ep_uninsur > 20  -- Focus on counties with >20% uninsured
  AND e_totpop > 10000   -- Filter for meaningful population size
)

SELECT
  state,
  county,
  e_totpop as population,
  ep_uninsur as uninsured_pct,
  e_uninsur as uninsured_count,
  -- Create risk tiers based on social factors
  CASE 
    WHEN poverty_rate > 25 AND 
         (limited_english_rate > 10 OR no_hs_diploma_rate > 20)
    THEN 'High Risk'
    WHEN poverty_rate > 15 OR limited_english_rate > 5 
    THEN 'Medium Risk'
    ELSE 'Lower Risk'
  END as access_risk_tier,
  -- Round key metrics for readability
  ROUND(poverty_rate,1) as poverty_rate,
  ROUND(limited_english_rate,1) as limited_english_rate,
  ROUND(minority_rate,1) as minority_rate,
  ROUND(no_hs_diploma_rate,1) as no_hs_diploma_rate
FROM UninsuredHotspots
ORDER BY ep_uninsur DESC, e_totpop DESC
LIMIT 100;

-- How it works:
-- 1. Identifies counties with high uninsured rates (>20%) and substantial population
-- 2. Pulls in key social determinant metrics known to impact healthcare access
-- 3. Creates risk tiers based on combinations of poverty and other barriers
-- 4. Ranks results by uninsured rate and population size
--
-- Assumptions & Limitations:
-- - 20% uninsured threshold is somewhat arbitrary
-- - Population minimum of 10,000 may miss some rural areas
-- - Risk tier definitions could be refined based on local context
-- - Data is from 2016 and may not reflect current conditions
--
-- Possible Extensions:
-- - Add year-over-year trend analysis when multiple years available
-- - Include proximity to healthcare facilities
-- - Calculate potential impact metrics (e.g., lives that could be covered)
-- - Add geographic clustering analysis to identify regional patterns
-- - Include state-level policy context (e.g., Medicaid expansion status)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:16:05.880529
    - Additional Notes: Query identifies healthcare access gaps by combining uninsured rates with social vulnerability metrics. The 20% uninsured threshold and 10,000 population minimum can be adjusted based on specific needs. Results are most relevant for population health management and healthcare expansion planning.
    
    */