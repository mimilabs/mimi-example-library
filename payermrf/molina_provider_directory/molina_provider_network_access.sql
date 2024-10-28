
/*******************************************************************************
Title: Provider Accessibility and Service Analysis for Molina Healthcare Network

Business Purpose:
This analysis helps identify the distribution and accessibility of healthcare 
providers in the Molina network across different counties. This information is
crucial for:
- Ensuring adequate provider coverage and network adequacy
- Identifying potential gaps in healthcare access
- Supporting provider network planning and expansion

Created: 2024-02-15
*******************************************************************************/

-- Main Analysis Query
WITH provider_metrics AS (
  SELECT 
    service_location_county,
    service_location_state,
    -- Count distinct providers/facilities
    COUNT(DISTINCT npi) as total_providers,
    COUNT(DISTINCT CASE WHEN facility = 'Y' THEN npi END) as facility_count,
    COUNT(DISTINCT CASE WHEN facility = 'N' THEN npi END) as individual_provider_count,
    
    -- Analyze accessibility features
    SUM(CASE WHEN p_parking = 'Y' THEN 1 ELSE 0 END) as accessible_parking_count,
    SUM(CASE WHEN eb_exterior_building = 'Y' THEN 1 ELSE 0 END) as accessible_building_count,
    SUM(CASE WHEN tele_health_attr = 'Y' THEN 1 ELSE 0 END) as telehealth_providers,
    
    -- Analyze service availability
    SUM(CASE WHEN accepting_new_patient_pgm_1 = 'Y' THEN 1 ELSE 0 END) as accepting_new_patients,
    COUNT(DISTINCT primary_specialty) as specialty_count
  FROM mimi_ws_1.payermrf.molina_provider_directory
  WHERE service_location_state IS NOT NULL 
    AND service_location_county IS NOT NULL
  GROUP BY service_location_county, service_location_state
)

SELECT 
  service_location_state,
  service_location_county,
  total_providers,
  facility_count,
  individual_provider_count,
  specialty_count,
  -- Calculate accessibility percentages
  ROUND(100.0 * accessible_parking_count / NULLIF(total_providers, 0), 1) as pct_accessible_parking,
  ROUND(100.0 * accessible_building_count / NULLIF(total_providers, 0), 1) as pct_accessible_building,
  ROUND(100.0 * telehealth_providers / NULLIF(total_providers, 0), 1) as pct_telehealth,
  ROUND(100.0 * accepting_new_patients / NULLIF(total_providers, 0), 1) as pct_accepting_patients
FROM provider_metrics
ORDER BY total_providers DESC;

/*******************************************************************************
How it works:
1. Creates a CTE to aggregate key provider metrics by county
2. Calculates counts for providers, facilities, and accessibility features
3. Computes percentages in the main query for easier comparison
4. Orders results by total providers to highlight areas with most coverage

Assumptions and Limitations:
- Assumes NPI is unique identifier for providers/facilities
- Accessibility status fields are accurately maintained
- Does not account for provider capacity or patient volume
- Geographic analysis limited to county level

Possible Extensions:
1. Add temporal analysis to track network changes over time:
   - Include trending by plan_effective_date
   - Compare network stability across periods

2. Enhance accessibility analysis:
   - Include more detailed accessibility features
   - Cross-reference with population demographics

3. Add specialty coverage analysis:
   - Break down providers by specialty type
   - Identity underserved specialties by region

4. Include quality metrics:
   - Join with quality/outcome data if available
   - Analyze provider ratings or patient satisfaction

5. Network adequacy assessment:
   - Compare against population density
   - Calculate provider-to-population ratios
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:06:54.284396
    - Additional Notes: Query uses NPI as primary identifier for providers. Results should be validated against actual provider counts as some providers may have multiple NPIs or locations. Percentages may exceed 100% if providers have multiple service locations within the same county.
    
    */