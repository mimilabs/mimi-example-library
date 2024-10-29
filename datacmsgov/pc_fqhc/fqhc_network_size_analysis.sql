-- TITLE: FQHC Network Reach and Multi-Location Analysis

-- BUSINESS PURPOSE:
-- This analysis identifies FQHCs operating multiple locations or having multiple NPIs
-- to understand market presence, service network breadth, and organizational scale.
-- Key business insights:
-- - Identify major FQHC networks and their geographic footprint
-- - Assess service delivery capacity through facility counts
-- - Support market entry and expansion planning
-- - Enable partnership opportunity identification

WITH fqhc_metrics AS (
  -- Group FQHCs by associate_id to analyze multi-location patterns
  SELECT 
    associate_id,
    organization_name,
    proprietary_nonprofit,
    COUNT(DISTINCT enrollment_id) as num_locations,
    COUNT(DISTINCT ccn) as num_ccns,
    COUNT(DISTINCT state) as num_states,
    MAX(CASE WHEN multiple_npi_flag = 'Y' THEN 1 ELSE 0 END) as has_multiple_npis,
    MIN(incorporation_date) as earliest_incorporation
  FROM mimi_ws_1.datacmsgov.pc_fqhc
  GROUP BY 1,2,3
)

-- Main analysis identifying significant FQHC networks
SELECT
  organization_name,
  proprietary_nonprofit as profit_status,
  num_locations,
  num_ccns,
  num_states,
  CASE WHEN has_multiple_npis = 1 THEN 'Yes' ELSE 'No' END as multiple_npis,
  earliest_incorporation,
  -- Categorize FQHC size/reach
  CASE 
    WHEN num_locations >= 10 THEN 'Large Network'
    WHEN num_locations >= 5 THEN 'Mid-size Network'
    ELSE 'Single/Small Network'
  END as network_size_category
FROM fqhc_metrics
WHERE num_locations > 1  -- Focus on multi-location networks
ORDER BY num_locations DESC, num_states DESC
LIMIT 100;

-- HOW IT WORKS:
-- 1. Creates metrics per FQHC organization using associate_id as identifier
-- 2. Calculates key network metrics: location count, state presence, CCN count
-- 3. Identifies organizations with multiple NPIs
-- 4. Categorizes networks by size
-- 5. Returns top 100 multi-location networks ordered by scale

-- ASSUMPTIONS & LIMITATIONS:
-- - associate_id reliably identifies unique FQHC organizations
-- - Current snapshot data only - no historical trends
-- - Multiple CCNs assumed to indicate separate facilities
-- - Size categories are arbitrary thresholds
-- - Geographic distribution detail limited to state count

-- POTENTIAL EXTENSIONS:
-- 1. Add geographic concentration metrics (e.g., % locations in top state)
-- 2. Include urban/rural location mix analysis
-- 3. Incorporate time-based growth metrics using incorporation dates
-- 4. Add filters for specific states or regions of interest
-- 5. Join with claims data to analyze patient volume and service patterns
-- 6. Compare network sizes between profit vs non-profit organizations
-- 7. Create market share calculations by geography

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:35:27.552080
    - Additional Notes: Query focuses on identifying large FQHC networks and their operational scale. Note that the 'Large Network' classification (10+ locations) and other thresholds may need adjustment based on specific market contexts. The 100-row limit may need modification for comprehensive analysis of smaller networks.
    
    */