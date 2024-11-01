-- clinician_facility_coverage_analysis.sql
-- Business Purpose: Analyze geographical coverage and facility type distribution
-- to identify potential gaps in healthcare access and opportunities for network expansion.
-- This helps healthcare organizations optimize their provider networks and improve access to care.

WITH facility_summary AS (
  -- Get unique clinician-facility combinations to avoid duplicates
  SELECT DISTINCT
    npi,
    facility_type,
    facility_affiliations_certification_number
  FROM mimi_ws_1.provdatacatalog.dac_fa
  WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.provdatacatalog.dac_fa)
),

clinician_metrics AS (
  -- Calculate key metrics per clinician
  SELECT 
    npi,
    COUNT(DISTINCT facility_type) as facility_type_count,
    COUNT(DISTINCT facility_affiliations_certification_number) as total_facilities,
    COLLECT_SET(facility_type) as facility_types
  FROM facility_summary
  GROUP BY npi
)

-- Final summary with distribution analysis
SELECT 
  facility_type_count,
  COUNT(DISTINCT npi) as clinician_count,
  ROUND(COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER(), 2) as pct_of_clinicians,
  ROUND(AVG(total_facilities), 2) as avg_facilities_per_clinician
FROM clinician_metrics
GROUP BY facility_type_count
ORDER BY facility_type_count;

/* How the query works:
1. facility_summary CTE gets unique clinician-facility combinations for the most recent data
2. clinician_metrics CTE calculates key metrics per clinician using COLLECT_SET instead of STRING_AGG
3. Final query shows distribution of clinicians by number of facility types they work with

Assumptions and limitations:
- Uses most recent data snapshot only
- Assumes facility certification numbers are consistent and valid
- Does not account for geographical location
- Does not consider facility size or capacity

Possible extensions:
1. Add geographical analysis using facility location data
2. Include temporal analysis to show changes in coverage over time
3. Add specialty-specific analysis to identify coverage gaps by medical specialty
4. Include quality metrics to assess impact of multiple affiliations on care quality
5. Add facility capacity analysis to better understand true coverage */

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:25:05.351232
    - Additional Notes: Query focuses on analyzing the distribution of clinicians across different facility types and calculates the percentage of clinicians who work with multiple facility types. The metrics can help identify patterns in how healthcare providers spread their services across different healthcare settings. Note that the query uses the most recent data snapshot only and doesn't account for temporal changes or geographical distribution.
    
    */