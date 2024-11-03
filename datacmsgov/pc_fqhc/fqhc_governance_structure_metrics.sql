-- TITLE: FQHC Organizational Governance and Chain Operations Analysis

-- BUSINESS PURPOSE:
-- Analyzes FQHCs with and without owner information to:
-- - Identify potential healthcare chains vs independently governed centers
-- - Understand the scale of board-governed vs owner-operated facilities 
-- - Highlight patterns in NPI and CCN assignments that indicate operational complexity
-- This insight helps:
--   1. Private equity firms evaluate market consolidation opportunities
--   2. Healthcare systems understand competitive landscape
--   3. Policy makers assess healthcare delivery models

-- Main Query
WITH governance_metrics AS (
  SELECT 
    CASE 
      WHEN multiple_npi_flag = 'Y' THEN 'Multiple NPIs'
      ELSE 'Single NPI'
    END AS operational_complexity,
    proprietary_nonprofit,
    organization_type_structure,
    COUNT(DISTINCT enrollment_id) as num_facilities,
    COUNT(DISTINCT ccn) as num_ccns,
    COUNT(DISTINCT associate_id) as num_unique_owners,
    COUNT(DISTINCT npi) as num_npis
  FROM mimi_ws_1.datacmsgov.pc_fqhc
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.pc_fqhc)
  GROUP BY 
    CASE 
      WHEN multiple_npi_flag = 'Y' THEN 'Multiple NPIs'
      ELSE 'Single NPI'
    END,
    proprietary_nonprofit,
    organization_type_structure
)

SELECT 
  operational_complexity,
  proprietary_nonprofit,
  organization_type_structure,
  num_facilities,
  num_ccns,
  num_npis,
  num_unique_owners,
  ROUND(num_ccns * 1.0 / num_facilities, 2) as ccns_per_facility,
  ROUND(num_npis * 1.0 / num_facilities, 2) as npis_per_facility
FROM governance_metrics
ORDER BY 
  num_facilities DESC,
  operational_complexity,
  proprietary_nonprofit;

-- HOW IT WORKS:
-- 1. Creates temp table with aggregated metrics by operational complexity and ownership type
-- 2. Calculates ratios of CCNs and NPIs per facility to identify operational patterns
-- 3. Groups results by key organizational characteristics
-- 4. Orders by facility count to highlight dominant governance models

-- ASSUMPTIONS & LIMITATIONS:
-- - Uses latest data snapshot only
-- - Assumes CCN and NPI counts indicate operational complexity
-- - Cannot directly identify board-governed vs owner-operated without joining to owner table
-- - May undercount facilities if enrollment_ids are duplicated

-- POSSIBLE EXTENSIONS:
-- 1. Join with owner table to explicitly identify board-governed facilities
-- 2. Add geographic analysis to identify regional governance patterns
-- 3. Track changes in governance models over time using historical snapshots
-- 4. Add revenue or patient volume metrics to correlate with governance type
-- 5. Analyze incorporation dates to identify governance model trends
-- 6. Include detailed address analysis to identify facility clusters

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:36:20.779569
    - Additional Notes: This query focuses on identifying organizational patterns through NPI and CCN relationships, which can indicate healthcare system consolidation and operational complexity. The metrics are particularly useful for understanding market structure and identifying potential healthcare chains. Note that full governance analysis requires joining with the owner table (pc_fqhc_owner) which is not included in this base query.
    
    */