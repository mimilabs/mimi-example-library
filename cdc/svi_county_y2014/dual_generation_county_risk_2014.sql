-- dual_generation_vulnerability_2014.sql
-- 
-- Business Purpose:
-- Identify counties facing heightened vulnerability due to high concentrations of both elderly (65+)
-- and youth (17 and under) populations. This analysis helps healthcare organizations and social
-- services better plan resources and programs for communities with significant dependent populations
-- requiring specialized care and support services.

WITH county_rankings AS (
  SELECT 
    state,
    county,
    e_totpop,
    ep_age65 as pct_elderly,
    ep_age17 as pct_youth,
    -- Calculate combined dependency burden
    (ep_age65 + ep_age17) as total_dependent_pct,
    -- Rank within state for both metrics
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY ep_age65 DESC) as elderly_rank,
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY ep_age17 DESC) as youth_rank
  FROM mimi_ws_1.cdc.svi_county_y2014
  WHERE e_totpop >= 10000  -- Focus on counties with meaningful population size
)

SELECT 
  state,
  county,
  e_totpop as population,
  ROUND(pct_elderly, 1) as pct_65_plus,
  ROUND(pct_youth, 1) as pct_17_under,
  ROUND(total_dependent_pct, 1) as combined_dependent_pct,
  elderly_rank,
  youth_rank
FROM county_rankings
WHERE elderly_rank <= 5 AND youth_rank <= 5  -- Counties ranking high in both metrics
ORDER BY state, total_dependent_pct DESC;

-- How it works:
-- 1. Creates county rankings within each state based on elderly and youth percentages
-- 2. Filters for counties that rank in top 5 for both elderly and youth concentrations
-- 3. Returns key demographic metrics for these dual-generation vulnerable counties
-- 4. Sorts results by state and total dependent population percentage

-- Assumptions & Limitations:
-- - Assumes counties with <10k population may have less reliable statistics
-- - Equal weighting given to youth and elderly populations in identifying vulnerability
-- - Does not account for other factors like healthcare infrastructure or economic resources
-- - Top 5 threshold is somewhat arbitrary and could be adjusted based on needs

-- Possible Extensions:
-- 1. Add socioeconomic indicators (poverty, unemployment) to assess resources for supporting dependents
-- 2. Include healthcare facility density or proximity metrics
-- 3. Trend analysis by comparing against other years' data
-- 4. Incorporate disability rates which may correlate with dependent populations
-- 5. Add geographic clustering analysis to identify regional patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:11:31.769451
    - Additional Notes: Query identifies counties with overlapping elderly and youth vulnerability by focusing on areas ranking high in both 65+ and under-17 populations. The 10,000 population threshold and top-5 ranking criteria can be adjusted based on specific analysis needs. Results are particularly useful for social services and healthcare resource planning.
    
    */