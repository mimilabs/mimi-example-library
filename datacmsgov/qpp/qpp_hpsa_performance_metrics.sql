-- QPP Health Professional Shortage Analysis
-- Business Purpose: Analyze provider participation and performance in Health Professional 
-- Shortage Areas (HPSAs) to identify opportunities for improving care access and quality
-- in underserved communities through the Quality Payment Program.

WITH provider_hpsa_metrics AS (
  SELECT 
    practice_state_or_us_territory,
    health_professional_shortage_area_status,
    clinician_type,
    clinician_specialty,
    COUNT(DISTINCT provider_key) as provider_count,
    ROUND(AVG(final_score), 2) as avg_final_score,
    ROUND(AVG(payment_adjustment_percentage), 2) as avg_payment_adj,
    ROUND(AVG(CAST(medicare_patients AS FLOAT)), 0) as avg_medicare_patients,
    SUM(CASE WHEN nonreporting = 'Y' THEN 1 ELSE 0 END) as nonreporting_count
  FROM mimi_ws_1.datacmsgov.qpp
  WHERE health_professional_shortage_area_status IS NOT NULL
  GROUP BY 1,2,3,4
)

SELECT 
  practice_state_or_us_territory,
  health_professional_shortage_area_status,
  clinician_type,
  clinician_specialty,
  provider_count,
  avg_final_score,
  avg_payment_adj,
  avg_medicare_patients,
  ROUND(100.0 * nonreporting_count / provider_count, 1) as nonreporting_pct
FROM provider_hpsa_metrics
WHERE provider_count >= 10  -- Filter for statistical significance
ORDER BY 
  practice_state_or_us_territory,
  provider_count DESC

-- How this query works:
-- 1. Creates a CTE to aggregate key metrics by state, HPSA status, and provider type
-- 2. Calculates average performance scores, payment adjustments, and patient volumes
-- 3. Computes non-reporting rates as a percentage
-- 4. Filters for groups with meaningful sample sizes
-- 5. Orders results by state and provider count for easy analysis

-- Assumptions and Limitations:
-- - HPSA status is accurately reported in the source data
-- - Minimum threshold of 10 providers per group for statistical validity
-- - Analysis is at the aggregate level and may mask individual variations
-- - Non-reporting status may have valid exemption reasons not captured

-- Possible Extensions:
-- 1. Add year-over-year trend analysis for HPSA performance
-- 2. Include additional social determinant factors like rural status
-- 3. Analyze specific quality measures relevant to HPSA settings
-- 4. Compare HPSA vs non-HPSA performance within specialties
-- 5. Add cost category analysis for resource utilization patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:03:27.474849
    - Additional Notes: This query focuses specifically on HPSA-related metrics and requires the health_professional_shortage_area_status field to be populated. Consider adjusting the provider_count threshold (currently 10) based on specific analysis needs. The query excludes providers with null HPSA status, which could impact completeness of state-level analysis.
    
    */