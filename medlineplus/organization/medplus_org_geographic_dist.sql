-- Title: MedlinePlus Organization Geographic Distribution Analysis

-- Business Purpose:
-- - Analyze the geographic footprint of organizations contributing to MedlinePlus
-- - Identify regional concentrations and potential coverage gaps
-- - Support strategic planning for geographic expansion and partnerships

-- Main Query
WITH org_locations AS (
  SELECT 
    -- Extract state/region from organization name where possible
    organization,
    CASE 
      WHEN organization LIKE '% AL %' OR organization LIKE '% Alabama %' THEN 'AL'
      WHEN organization LIKE '% CA %' OR organization LIKE '% California %' THEN 'CA'
      -- Add more state pattern matching as needed
      ELSE 'Unknown'
    END AS inferred_state,
    COUNT(DISTINCT site_id) as num_sites,
    MIN(mimi_src_file_date) as first_appearance,
    MAX(mimi_src_file_date) as latest_appearance
  FROM mimi_ws_1.medlineplus.organization
  GROUP BY organization
),

region_summary AS (
  SELECT
    inferred_state,
    COUNT(DISTINCT organization) as num_organizations,
    SUM(num_sites) as total_sites,
    MIN(first_appearance) as region_first_org,
    MAX(latest_appearance) as region_latest_org
  FROM org_locations
  GROUP BY inferred_state
)

SELECT 
  inferred_state,
  num_organizations,
  total_sites,
  DATEDIFF(region_latest_org, region_first_org) as region_presence_days,
  ROUND(total_sites::FLOAT / num_organizations, 2) as avg_sites_per_org
FROM region_summary
WHERE inferred_state != 'Unknown'
ORDER BY total_sites DESC;

-- How it works:
-- 1. First CTE (org_locations) identifies geographic location from organization names
-- 2. Second CTE (region_summary) aggregates metrics by region
-- 3. Final SELECT provides key geographic distribution metrics

-- Assumptions and Limitations:
-- - Relies on organization names containing geographic identifiers
-- - May miss organizations that don't follow standard naming patterns
-- - Geographic inference may have false positives
-- - Current state pattern matching is limited to example states

-- Possible Extensions:
-- 1. Add more sophisticated geographic parsing using regex
-- 2. Include temporal analysis to show regional growth patterns
-- 3. Add visualization coordinates for mapping
-- 4. Cross-reference with external geographic databases
-- 5. Analyze cross-state organization presence

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:59:43.707999
    - Additional Notes: Geographic inference logic requires maintenance of state/region patterns in CASE statement. Current implementation only includes example states (AL, CA). For production use, complete list of state patterns should be added. Consider adding data quality checks for organization naming conventions to improve location inference accuracy.
    
    */