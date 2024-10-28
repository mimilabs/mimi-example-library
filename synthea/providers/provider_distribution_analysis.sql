
/*******************************************************************************
Title: Healthcare Provider Distribution Analysis
 
Business Purpose:
- Analyze the distribution of healthcare providers across specialties and organizations
- Identify potential gaps in medical coverage
- Support strategic workforce planning in healthcare
*******************************************************************************/

-- Main query to analyze provider distribution and specialization coverage
WITH provider_metrics AS (
  SELECT 
    speciality,
    organization,
    gender,
    COUNT(*) as provider_count,
    AVG(utilization) as avg_utilization,
    COUNT(DISTINCT city) as cities_served
  FROM mimi_ws_1.synthea.providers
  WHERE speciality IS NOT NULL
  GROUP BY speciality, organization, gender
)

SELECT
  speciality,
  organization,
  gender,
  provider_count,
  ROUND(avg_utilization, 2) as avg_utilization,
  cities_served,
  -- Calculate percentage of total providers within each specialty
  ROUND(100.0 * provider_count / SUM(provider_count) OVER (PARTITION BY speciality), 1) as pct_of_specialty
FROM provider_metrics
ORDER BY 
  provider_count DESC,
  speciality,
  organization;

/*******************************************************************************
How this query works:
1. Creates a CTE to aggregate provider metrics by specialty, organization and gender
2. Calculates key metrics including provider counts, utilization and geographic spread
3. Computes the percentage distribution within each specialty
4. Orders results to highlight areas with highest provider concentration

Assumptions & Limitations:
- Assumes speciality field is standardized and meaningful
- Does not account for part-time vs full-time status
- Geographic analysis is limited to city count, not population coverage
- Utilization metric may need validation for consistency

Possible Extensions:
1. Add geographic analysis by state/region
2. Include trend analysis using historical data
3. Compare provider distribution to population needs
4. Add filters for specific specialties or organizations of interest
5. Calculate gender diversity metrics by specialty
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:09:00.245133
    - Additional Notes: Query provides high-level metrics for healthcare workforce planning. Note that the utilization metric should be validated for consistency across different organizations, and geographic coverage analysis could be enhanced by incorporating population density data. Consider adding filters for specific time periods if analyzing workforce trends.
    
    */