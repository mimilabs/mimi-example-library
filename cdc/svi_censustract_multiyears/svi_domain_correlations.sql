-- vulnerability_domain_correlations.sql
--
-- Business Purpose:
-- Analyzes correlations between different SVI domains to understand which vulnerability 
-- factors tend to occur together. This helps healthcare organizations and disaster response
-- teams better predict compound risks and design more effective interventions.
--
-- The analysis focuses on the most recent year and identifies census tracts where
-- multiple vulnerability domains overlap significantly.

WITH recent_year AS (
  SELECT MAX(year) as max_year
  FROM mimi_ws_1.cdc.svi_censustract_multiyears
),

domain_correlations AS (
  SELECT 
    state_abbr,
    county_name,
    -- Identify high-vulnerability areas across multiple domains
    COUNT(*) as tract_count,
    AVG(svi) as avg_total_vulnerability,
    -- Calculate how many tracts have high vulnerability in multiple domains
    SUM(CASE WHEN rpl_socioeconomic > 0.75 
             AND rpl_householdcomp > 0.75 THEN 1 ELSE 0 END) as socio_household_overlap,
    SUM(CASE WHEN rpl_minoritystatus > 0.75 
             AND rpl_housingtransport > 0.75 THEN 1 ELSE 0 END) as minority_housing_overlap,
    -- Calculate average domain scores
    AVG(rpl_socioeconomic) as avg_socioeconomic,
    AVG(rpl_householdcomp) as avg_household,
    AVG(rpl_minoritystatus) as avg_minority,
    AVG(rpl_housingtransport) as avg_housing
  FROM mimi_ws_1.cdc.svi_censustract_multiyears svi
  JOIN recent_year r ON svi.year = r.max_year
  GROUP BY state_abbr, county_name
)

SELECT 
  state_abbr,
  county_name,
  tract_count,
  ROUND(avg_total_vulnerability, 3) as avg_vulnerability,
  -- Calculate percentage of tracts with overlapping vulnerabilities
  ROUND(socio_household_overlap * 100.0 / tract_count, 1) as pct_socio_household_overlap,
  ROUND(minority_housing_overlap * 100.0 / tract_count, 1) as pct_minority_housing_overlap,
  -- Identify dominant vulnerability domain
  GREATEST(avg_socioeconomic, avg_household, avg_minority, avg_housing) as highest_domain_score,
  CASE 
    WHEN avg_socioeconomic >= GREATEST(avg_household, avg_minority, avg_housing) THEN 'Socioeconomic'
    WHEN avg_household >= GREATEST(avg_socioeconomic, avg_minority, avg_housing) THEN 'Household'
    WHEN avg_minority >= GREATEST(avg_socioeconomic, avg_household, avg_housing) THEN 'Minority'
    ELSE 'Housing' 
  END as dominant_vulnerability
FROM domain_correlations
WHERE tract_count >= 5  -- Focus on counties with meaningful sample size
ORDER BY avg_total_vulnerability DESC
LIMIT 100;

-- How it works:
-- 1. Identifies the most recent year in the dataset
-- 2. Calculates various overlap metrics between vulnerability domains
-- 3. Determines the dominant vulnerability type for each county
-- 4. Returns results for counties with sufficient data points
--
-- Assumptions and Limitations:
-- - Assumes that vulnerabilities > 75th percentile are "high"
-- - Limited to counties with 5+ census tracts for statistical relevance
-- - Uses the most recent year only; historical trends not considered
-- - Equal weighting given to all domains in overlap calculations
--
-- Possible Extensions:
-- 1. Add year-over-year change in domain correlations
-- 2. Include population-weighted calculations
-- 3. Add geographic clustering analysis for similar vulnerability patterns
-- 4. Create vulnerability combination profiles (e.g., "high socio-housing" vs "high minority-household")
-- 5. Incorporate external factors like disaster history or healthcare access metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:40:02.671777
    - Additional Notes: Query focuses on counties with 5+ census tracts and identifies overlapping vulnerability patterns. Results are limited to top 100 most vulnerable counties based on average total SVI score. Domain overlap calculations use 75th percentile as threshold for 'high vulnerability'.
    
    */