-- Healthcare Access Vulnerability Assessment - 2016
--
-- Business Purpose: 
-- Identifies census tracts with significant healthcare access barriers by analyzing
-- the intersection of uninsured populations, transportation limitations, and socioeconomic
-- factors. This helps healthcare organizations and policymakers target interventions
-- and locate new facilities in high-need areas.
--
-- Key metrics analyzed:
-- - Uninsured population
-- - Vehicle access
-- - Per capita income
-- - Limited English proficiency
-- - Population density

WITH tract_analysis AS (
  -- Calculate key healthcare access metrics
  SELECT
    state,
    county,
    location,
    e_totpop,
    e_daypop,
    -- Healthcare coverage gap
    ep_uninsur AS pct_uninsured,
    -- Transportation barrier
    ep_noveh AS pct_no_vehicle,
    -- Economic barrier 
    e_pci AS per_capita_income,
    -- Language barrier
    ep_limeng AS pct_limited_english,
    -- Population density (people per sq mile)
    ROUND(e_totpop/area_sqmi,1) AS pop_density
  FROM mimi_ws_1.cdc.svi_censustract_y2016
  WHERE e_totpop > 0  -- Remove unpopulated tracts
)

SELECT
  state,
  county,
  location,
  e_totpop AS total_population,
  e_daypop AS daytime_population,
  pct_uninsured,
  pct_no_vehicle,
  per_capita_income,
  pct_limited_english,
  pop_density,
  -- Flag high-need tracts
  CASE WHEN pct_uninsured > 20 
       AND pct_no_vehicle > 10
       AND per_capita_income < 25000 
       THEN 'High Need'
       ELSE 'Standard' END AS access_need_category
FROM tract_analysis
ORDER BY pct_uninsured DESC, pct_no_vehicle DESC
LIMIT 1000;

-- How it works:
-- 1. Creates CTE to calculate normalized healthcare access metrics by census tract
-- 2. Applies filters to remove invalid data
-- 3. Adds categorization for high-need areas based on multiple factors
-- 4. Returns top 1000 tracts ordered by greatest apparent need
--
-- Assumptions/Limitations:
-- - Requires populated census tracts (e_totpop > 0)
-- - Threshold values for high-need categorization are illustrative
-- - Does not account for proximity to existing healthcare facilities
-- - Limited to 2016 data snapshot
--
-- Possible Extensions:
-- 1. Add distance calculations to nearest hospitals/clinics
-- 2. Include Medicare/Medicaid enrollment data if available
-- 3. Create risk scores weighted by multiple factors
-- 4. Add geographic clustering analysis
-- 5. Compare daytime vs residential population needs
-- 6. Segment analysis by urban/rural classification

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:10:28.329523
    - Additional Notes: Query focuses on identifying healthcare accessibility gaps at census tract level by combining multiple social determinants of health. The 'High Need' categorization thresholds (>20% uninsured, >10% no vehicle, <$25k per capita income) should be adjusted based on local contexts and specific program requirements.
    
    */