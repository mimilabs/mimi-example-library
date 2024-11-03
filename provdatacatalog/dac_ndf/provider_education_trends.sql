-- Title: Healthcare Provider Education and Training Demographics Analysis

-- Business Purpose:
-- Analyzes medical school graduation patterns and credentials of healthcare providers
-- to help healthcare organizations and policymakers:
-- 1. Understand workforce age distribution and succession planning needs
-- 2. Identify trends in medical education and specialization
-- 3. Support recruitment strategies and workforce development
-- 4. Track changes in provider education demographics over time

WITH provider_education AS (
  -- Get distinct providers and their education info to avoid duplicates
  SELECT DISTINCT
    npi,
    provider_last_name,
    provider_first_name,
    cred,
    med_sch,
    grd_yr,
    pri_spec,
    state
  FROM mimi_ws_1.provdatacatalog.dac_ndf
  WHERE grd_yr IS NOT NULL 
    AND med_sch IS NOT NULL
),

graduation_decades AS (
  -- Calculate graduation decades for trend analysis
  SELECT 
    FLOOR(grd_yr/10)*10 as grad_decade,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN cred IS NOT NULL THEN cred END) as unique_credentials,
    COUNT(DISTINCT med_sch) as unique_schools,
    COUNT(DISTINCT pri_spec) as specialty_count
  FROM provider_education
  WHERE grd_yr >= 1960  -- Filter out likely incorrect historical dates
  GROUP BY FLOOR(grd_yr/10)*10
),

state_education_summary AS (
  -- Summarize education patterns by state
  SELECT 
    state,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT med_sch) as school_count,
    ROUND(AVG(2024 - grd_yr),1) as avg_years_since_graduation
  FROM provider_education
  GROUP BY state
)

-- Final output combining key metrics
SELECT 
  g.grad_decade,
  g.provider_count,
  g.unique_credentials,
  g.unique_schools,
  g.specialty_count,
  -- Calculate percentage trend between decades
  LAG(g.provider_count, 1) OVER (ORDER BY g.grad_decade) as prev_decade_count,
  CASE 
    WHEN LAG(g.provider_count, 1) OVER (ORDER BY g.grad_decade) IS NOT NULL 
    THEN ROUND(((g.provider_count - LAG(g.provider_count, 1) OVER (ORDER BY g.grad_decade)) * 100.0 / 
      NULLIF(LAG(g.provider_count, 1) OVER (ORDER BY g.grad_decade), 0)), 1)
    ELSE NULL
  END as decade_over_decade_pct_change
FROM graduation_decades g
ORDER BY g.grad_decade DESC;

-- How the Query Works:
-- 1. Creates base table of distinct providers with education info
-- 2. Groups providers by graduation decade to show historical trends
-- 3. Calculates state-level education metrics (though not shown in final output)
-- 4. Produces final summary with decade-over-decade trending

-- Assumptions and Limitations:
-- 1. Assumes graduation years are accurate in source data
-- 2. Filters out graduation years before 1960 as potentially erroneous
-- 3. Doesn't account for international medical schools differently
-- 4. Multiple specialties or credentials per provider may exist

-- Possible Extensions:
-- 1. Add medical school rankings or categories for additional insight
-- 2. Include geographic analysis of where providers practice vs. where they studied
-- 3. Analyze correlation between graduation decade and telehealth adoption
-- 4. Track specialty choices across different graduation decades
-- 5. Include provider gender distribution across graduation decades

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:16:16.932249
    - Additional Notes: Query analyzes healthcare provider education trends by graduation decade, showing the evolution of the medical workforce over time. The decade-over-decade comparison includes NULLIF protection for division by zero. State-level metrics are calculated but not included in final output - these could be exposed by modifying the final SELECT statement.
    
    */