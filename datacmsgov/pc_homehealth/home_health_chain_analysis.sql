-- Home Health Agency Ownership Structure and Chain Analysis
-- 
-- Business Purpose: 
-- Analyzes ownership characteristics and chain relationships among home health agencies to:
-- 1. Identify potential consolidation patterns in the industry
-- 2. Map relationships between legal entities and operating locations
-- 3. Support due diligence and competitive intelligence efforts
-- 4. Flag potential compliance risks from complex ownership structures

WITH chain_metrics AS (
  -- First identify agencies that share common associate_ids
  SELECT 
    associate_id,
    COUNT(DISTINCT ccn) as locations_count,
    COUNT(DISTINCT state) as states_operated,
    MIN(incorporation_date) as earliest_incorporation,
    MAX(proprietary_nonprofit) as profit_status
  FROM mimi_ws_1.datacmsgov.pc_homehealth
  GROUP BY associate_id
  HAVING locations_count > 1
),

location_states AS (
  -- Aggregate state information separately
  SELECT 
    associate_id,
    CONCAT_WS(', ', COLLECT_SET(state)) as operating_states,
    COUNT(DISTINCT CASE WHEN practice_location_type = 'PRIVATE RESIDENCE' THEN ccn END) as private_locations,
    COUNT(DISTINCT CASE WHEN practice_location_type = 'COMMERCIAL LOCATION' THEN ccn END) as commercial_locations
  FROM mimi_ws_1.datacmsgov.pc_homehealth
  GROUP BY associate_id
)

SELECT
  -- Chain level metrics
  cm.associate_id,
  cm.locations_count,
  cm.states_operated,
  cm.earliest_incorporation,
  cm.profit_status,
  
  -- Primary organization details
  hh.organization_name,
  hh.organization_type_structure,
  hh.incorporation_state,
  
  -- Location summaries
  ls.operating_states,
  ls.private_locations,
  ls.commercial_locations

FROM chain_metrics cm
JOIN mimi_ws_1.datacmsgov.pc_homehealth hh 
  ON cm.associate_id = hh.associate_id
JOIN location_states ls
  ON cm.associate_id = ls.associate_id

-- Focus on larger multi-location operators
WHERE cm.locations_count >= 3

GROUP BY 
  cm.associate_id,
  cm.locations_count, 
  cm.states_operated,
  cm.earliest_incorporation,
  cm.profit_status,
  hh.organization_name,
  hh.organization_type_structure,
  hh.incorporation_state,
  ls.operating_states,
  ls.private_locations,
  ls.commercial_locations

ORDER BY cm.locations_count DESC
LIMIT 100

/*
How this works:
1. The first CTE identifies associate_ids that have multiple locations/CCNs
2. The second CTE handles state aggregation using Spark SQL functions
3. Main query joins everything together to show organization details and metrics
4. Filtered to focus on organizations with 3+ locations

Assumptions & Limitations:
- Associate_id reliably links related entities
- Multiple CCNs under same associate_id indicate chain relationship
- Current snapshot only - no historical trending
- May miss some relationships if entities use different associate_ids

Possible Extensions:
1. Add temporal analysis of chain growth over time
2. Include owner table linkage to identify ultimate parent companies
3. Add geographic clustering analysis of locations
4. Compare chain vs independent agency characteristics
5. Calculate market share metrics at various geographic levels
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:18:57.010356
    - Additional Notes: Query focuses on identifying and analyzing multi-location home health agencies (chains) with 3+ locations. Uses COLLECT_SET for state aggregation which may have memory implications for very large datasets. Results are limited to top 100 chains by location count.
    
    */