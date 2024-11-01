-- Geographic Network Expansion Opportunity Analysis
-- =====================================================
--
-- Business Purpose:
-- This analysis helps healthcare organizations identify promising geographic areas 
-- for network expansion based on patient density and current coverage gaps.
-- The insights support strategic decisions about where to establish new facilities
-- or partner with local providers.

WITH patient_clusters AS (
  -- Group patients by geographic areas and calculate key metrics
  SELECT 
    state,
    county,
    COUNT(*) as patient_count,
    COUNT(DISTINCT zip) as unique_zips,
    -- Calculate average coordinates for visualization
    AVG(lat) as center_lat,
    AVG(lon) as center_lon,
    -- Living patients only
    COUNT(CASE WHEN deathdate IS NULL THEN 1 END) as active_patients
  FROM mimi_ws_1.synthea.patients
  WHERE lat IS NOT NULL 
    AND lon IS NOT NULL
  GROUP BY state, county
),

ranked_opportunities AS (
  -- Rank areas based on patient population size
  SELECT 
    state,
    county,
    patient_count,
    unique_zips,
    center_lat,
    center_lon,
    active_patients,
    -- Calculate percentage of total patient population
    ROUND(100.0 * patient_count / SUM(patient_count) OVER(), 2) as pct_of_total,
    -- Rank areas by patient count within each state
    ROW_NUMBER() OVER (PARTITION BY state ORDER BY patient_count DESC) as state_rank
  FROM patient_clusters
)

-- Present top expansion opportunities
SELECT 
  state,
  county,
  patient_count,
  active_patients,
  unique_zips,
  pct_of_total as population_percentage,
  ROUND(center_lat, 4) as latitude,
  ROUND(center_lon, 4) as longitude
FROM ranked_opportunities
WHERE state_rank <= 3  -- Top 3 counties per state
ORDER BY patient_count DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE aggregates patient data by geographic area
-- 2. Second CTE ranks areas and calculates additional metrics
-- 3. Final output presents top opportunities based on patient population

-- Assumptions and Limitations:
-- - Assumes lat/lon coordinates are accurate and populated
-- - Does not account for existing healthcare facility locations
-- - Does not consider socioeconomic factors or competition
-- - Limited to current patient distribution in synthetic data

-- Possible Extensions:
-- 1. Add demographic breakdowns for each geographic area
-- 2. Include distance calculations to nearest existing facilities
-- 3. Incorporate healthcare expense patterns by region
-- 4. Add year-over-year growth analysis for each area
-- 5. Include competitor presence analysis
-- 6. Add population health metrics by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:11:54.928322
    - Additional Notes: Query identifies high-potential areas for healthcare network expansion based on patient density. Results are limited to top 3 counties per state and require valid geographic coordinates. Consider running analysis quarterly to track population changes and seasonal patterns.
    
    */