-- Medicare Hospice Provider Age Analysis - Market Entry Patterns
--
-- Business Purpose: Analyze the incorporation dates and operational longevity of Medicare hospice
-- providers to understand market maturity, identify regions with emerging providers, and track
-- industry evolution patterns. This helps with:
-- - Assessing market experience and stability
-- - Identifying areas with new market entrants
-- - Understanding provider lifecycle patterns
-- - Supporting market entry strategy decisions

WITH provider_age AS (
  -- Calculate provider age and group by experience levels
  SELECT 
    state,
    incorporation_date,
    DATEDIFF(years, incorporation_date, CURRENT_DATE()) as years_in_operation,
    CASE 
      WHEN DATEDIFF(years, incorporation_date, CURRENT_DATE()) < 5 THEN 'New Entry (0-5 years)'
      WHEN DATEDIFF(years, incorporation_date, CURRENT_DATE()) < 10 THEN 'Developing (5-10 years)'
      WHEN DATEDIFF(years, incorporation_date, CURRENT_DATE()) < 20 THEN 'Established (10-20 years)'
      ELSE 'Mature (20+ years)'
    END as experience_level,
    proprietary_nonprofit,
    COUNT(*) as provider_count
  FROM mimi_ws_1.datacmsgov.pc_hospice
  WHERE incorporation_date IS NOT NULL
  GROUP BY 1,2,3,4,5
)

SELECT 
  state,
  experience_level,
  proprietary_nonprofit,
  COUNT(*) as num_providers,
  AVG(years_in_operation) as avg_years_operating,
  MIN(incorporation_date) as earliest_entry,
  MAX(incorporation_date) as latest_entry
FROM provider_age
GROUP BY 1,2,3
ORDER BY state, experience_level;

-- How This Query Works:
-- 1. Creates a CTE to calculate years in operation and assign experience levels
-- 2. Groups providers by state, experience level, and profit status
-- 3. Calculates key metrics about provider age and market entry timing
-- 4. Orders results geographically and by experience level for easy analysis

-- Assumptions and Limitations:
-- - Relies on incorporation_date being accurately reported
-- - Does not account for providers that have left the market
-- - May not reflect ownership changes or acquisitions
-- - Current date used as reference point for age calculations

-- Possible Extensions:
-- 1. Add year-over-year analysis of new market entrants
-- 2. Include geographic density analysis of provider age
-- 3. Correlate provider age with organization size/structure
-- 4. Compare market entry patterns between urban/rural areas
-- 5. Analyze relationship between provider age and ownership changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:22:23.805534
    - Additional Notes: Query performance may be impacted with large datasets due to the DATEDIFF calculations. Consider indexing incorporation_date if frequent runs are needed. Results may be skewed in states with a small number of providers.
    
    */