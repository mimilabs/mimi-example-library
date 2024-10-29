-- Hospital Financial Status and Market Position Analysis
-- Business Purpose:
-- - Evaluate hospital market presence through incorporation age and operating structure
-- - Identify patterns in proprietary vs nonprofit status across hospital types
-- - Support market entry and partnership strategy decisions
-- - Guide investment and expansion planning in healthcare markets

WITH hospital_age AS (
  -- Calculate hospital operating duration and group by age brackets
  SELECT 
    state,
    CASE 
      WHEN DATEDIFF(CURRENT_DATE, incorporation_date)/365 < 5 THEN 'New (<5 years)'
      WHEN DATEDIFF(CURRENT_DATE, incorporation_date)/365 < 15 THEN 'Established (5-15 years)'
      WHEN DATEDIFF(CURRENT_DATE, incorporation_date)/365 < 30 THEN 'Mature (15-30 years)'
      ELSE 'Legacy (30+ years)'
    END as age_category,
    proprietary_nonprofit,
    organization_type_structure,
    COUNT(DISTINCT enrollment_id) as hospital_count,
    COUNT(DISTINCT npi) as unique_npis
  FROM mimi_ws_1.datacmsgov.pc_hospital
  WHERE incorporation_date IS NOT NULL
  GROUP BY 1,2,3,4
)

SELECT 
  state,
  age_category,
  organization_type_structure,
  CASE proprietary_nonprofit 
    WHEN 'P' THEN 'For-Profit'
    WHEN 'N' THEN 'Non-Profit'
    ELSE 'Unknown'
  END as ownership_type,
  hospital_count,
  unique_npis,
  ROUND(hospital_count * 100.0 / SUM(hospital_count) OVER (PARTITION BY state), 1) as pct_of_state_total
FROM hospital_age
WHERE hospital_count > 0
ORDER BY state, age_category, hospital_count DESC;

-- How the query works:
-- 1. Creates a CTE to categorize hospitals by age since incorporation
-- 2. Calculates key metrics including hospital counts and unique NPIs
-- 3. Computes percentage distribution within each state
-- 4. Filters for meaningful results and presents organized output

-- Assumptions and limitations:
-- - Incorporation date is a proxy for hospital age/establishment
-- - Some hospitals may have missing incorporation dates
-- - Mergers and acquisitions history not reflected
-- - Recent organizational changes may not be captured

-- Possible extensions:
-- 1. Add trend analysis by comparing against historical snapshots
-- 2. Include financial metrics if available in other tables
-- 3. Analyze correlation with specialized service offerings
-- 4. Add geographic clustering analysis for market concentration
-- 5. Compare against demographic or economic indicators by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:31:07.053580
    - Additional Notes: This query focuses on market maturity analysis through incorporation age and ownership structure, but depends heavily on the completeness of incorporation_date data. Results may be skewed in states with high rates of missing incorporation dates or recent organizational restructuring. Best used in conjunction with other market analysis tools for comprehensive market assessment.
    
    */