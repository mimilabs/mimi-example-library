-- Healthcare Provider Chain Analysis: Parent-Subsidiary Relationships
--
-- Business Purpose:
-- Identifies potential healthcare organization chains and parent-subsidiary relationships
-- by analyzing organizations that share mailing addresses but have different business locations.
-- This analysis helps understand market consolidation, organizational structures,
-- and administrative centralization in healthcare delivery networks.

WITH shared_mail AS (
  -- Find organizations that share mailing addresses
  SELECT 
    h3_r12_mail,
    COUNT(DISTINCT npi) as org_count,
    COUNT(DISTINCT h3_r12_biz) as distinct_biz_locations,
    ARRAY_AGG(DISTINCT name) as org_names
  FROM mimi_ws_1.nppes.npi_to_address
  WHERE entity_type_code = '2' -- Organizations only
    AND h3_r12_mail IS NOT NULL 
    AND h3_r12_biz IS NOT NULL
  GROUP BY h3_r12_mail
  HAVING COUNT(DISTINCT npi) > 1 -- At least 2 organizations sharing mail address
    AND COUNT(DISTINCT h3_r12_biz) > 1 -- Different business locations
),

potential_chains AS (
  -- Identify the largest potential healthcare chains
  SELECT
    a.h3_r12_mail,
    a.matched_address_mail as central_office,
    a.name as potential_parent,
    sm.org_count as total_subsidiaries,
    sm.distinct_biz_locations as unique_locations,
    sm.org_names as related_organizations
  FROM mimi_ws_1.nppes.npi_to_address a
  INNER JOIN shared_mail sm ON a.h3_r12_mail = sm.h3_r12_mail
  -- Take one representative org per shared address
  QUALIFY ROW_NUMBER() OVER (PARTITION BY a.h3_r12_mail ORDER BY a.npi) = 1
)

SELECT
  central_office,
  potential_parent,
  total_subsidiaries,
  unique_locations,
  related_organizations
FROM potential_chains
ORDER BY total_subsidiaries DESC, unique_locations DESC
LIMIT 100;

-- How it works:
-- 1. First CTE finds organizations sharing mailing addresses but having different business locations
-- 2. Second CTE identifies potential parent organizations and their related entities
-- 3. Final query presents the results sorted by size of the potential healthcare chains

-- Assumptions and limitations:
-- 1. Assumes shared mailing address indicates administrative relationship
-- 2. May include false positives from shared office buildings
-- 3. Limited to current snapshot, no historical relationship tracking
-- 4. Does not account for organizations using PO boxes or third-party services

-- Possible extensions:
-- 1. Add geographic analysis of subsidiary locations vs headquarters
-- 2. Include provider specialty analysis to understand chain specialization
-- 3. Cross-reference with claims data to analyze referral patterns within chains
-- 4. Add time-series analysis to track healthcare system consolidation
-- 5. Include financial metrics to assess size and market impact of chains

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:11:30.113266
    - Additional Notes: Query identifies potential healthcare chains through shared mailing address analysis. Focuses on organizational relationships rather than individual providers. Results may need manual verification due to potential false positives from shared office buildings or mail processing centers.
    
    */