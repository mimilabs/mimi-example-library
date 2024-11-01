-- provider_geographic_market_analysis.sql
--
-- Business Purpose:
-- - Identify geographic market concentrations and gaps in provider coverage
-- - Support market expansion and network development strategies
-- - Evaluate regional competitive landscape in healthcare services
-- - Inform decisions about where to establish new practices or partnerships
--
-- Created by: Healthcare Analytics Team
-- Last Modified: 2024-02-12

-- Main Analysis Query
WITH provider_density AS (
  -- Calculate provider concentrations by state and city
  SELECT 
    state,
    city,
    COUNT(DISTINCT id) as provider_count,
    COUNT(DISTINCT speciality) as specialty_count,
    COUNT(DISTINCT organization) as org_count,
    -- Calculate percentage of providers with key specialties
    SUM(CASE WHEN speciality IN ('Family Practice', 'Internal Medicine', 'Pediatrics') THEN 1 ELSE 0 END) * 100.0 / 
      COUNT(*) as primary_care_pct
  FROM mimi_ws_1.synthea.providers
  WHERE state IS NOT NULL
  GROUP BY state, city
),
state_summary AS (
  -- Roll up metrics to state level
  SELECT 
    state,
    SUM(provider_count) as total_providers,
    AVG(provider_count) as avg_providers_per_city,
    AVG(primary_care_pct) as avg_primary_care_pct
  FROM provider_density
  GROUP BY state
)

-- Final output combining city and state metrics
SELECT 
  pd.state,
  pd.city,
  pd.provider_count,
  pd.specialty_count,
  pd.org_count,
  ROUND(pd.primary_care_pct, 1) as primary_care_pct,
  ss.total_providers as state_total_providers,
  ROUND(pd.provider_count * 100.0 / ss.total_providers, 1) as pct_of_state_providers
FROM provider_density pd
JOIN state_summary ss ON pd.state = ss.state
WHERE pd.provider_count >= 5  -- Focus on meaningful market presence
ORDER BY pd.state, pd.provider_count DESC;

-- How this query works:
-- 1. First CTE (provider_density) calculates key metrics at the city level
-- 2. Second CTE (state_summary) creates state-level aggregations
-- 3. Final query joins these together to show market concentration patterns
--
-- Assumptions and Limitations:
-- - Assumes provider addresses are complete and accurate
-- - Does not account for population density or demographic needs
-- - Primary care definition limited to three main specialties
-- - Minimum threshold of 5 providers may exclude rural areas
--
-- Possible Extensions:
-- 1. Add population data to calculate provider-to-population ratios
-- 2. Include distance analysis between cities to identify coverage gaps
-- 3. Incorporate provider utilization metrics for capacity analysis
-- 4. Add temporal analysis to track market evolution over time
-- 5. Include specialty-specific market share analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:55:38.126189
    - Additional Notes: Query focuses on geographical concentration of healthcare providers and market presence metrics. Threshold of 5 providers may need adjustment based on specific market analysis needs. Consider local population data integration for more meaningful market penetration insights.
    
    */