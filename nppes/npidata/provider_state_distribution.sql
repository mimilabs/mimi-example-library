
/*******************************************************************************
Title: Healthcare Provider Distribution Analysis by State and Specialty
 
Business Purpose:
This query analyzes the geographical distribution and specialization of active 
healthcare providers across states, providing insights for:
- Healthcare access and provider availability assessment
- Network adequacy planning
- Resource allocation and healthcare policy decisions
*******************************************************************************/

WITH latest_records AS (
  -- Get the most recent record for each provider to avoid duplicates
  SELECT 
    npi,
    MAX(mimi_src_file_date) as latest_date
  FROM mimi_ws_1.nppes.npidata
  WHERE npi_deactivation_date IS NULL  -- Only active providers
  GROUP BY npi
),

provider_data AS (
  -- Join back to get full provider details
  SELECT 
    n.provider_business_practice_location_address_state_name as state,
    n.entity_type_code,
    n.healthcare_provider_taxonomies,
    CASE 
      WHEN n.entity_type_code = '1' THEN 'Individual'
      WHEN n.entity_type_code = '2' THEN 'Organization'
      ELSE 'Unknown'
    END as provider_type
  FROM mimi_ws_1.nppes.npidata n
  INNER JOIN latest_records lr 
    ON n.npi = lr.npi 
    AND n.mimi_src_file_date = lr.latest_date
  WHERE n.provider_business_practice_location_address_state_name IS NOT NULL
)

SELECT
  state,
  provider_type,
  COUNT(*) as provider_count,
  -- Calculate percentage within each state
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY state), 2) as pct_of_state
FROM provider_data
GROUP BY state, provider_type
HAVING provider_count >= 100  -- Filter out small counts
ORDER BY state, provider_count DESC;

/*******************************************************************************
How it works:
1. Creates a CTE to get the latest record for each active provider
2. Joins back to main table to get provider details
3. Aggregates counts by state and provider type
4. Calculates percentage distribution within each state

Assumptions and Limitations:
- Uses business practice location (not mailing address)
- Assumes latest record is most accurate
- Only includes active providers (not deactivated)
- Filters out states with very few providers
- Does not account for providers practicing in multiple states

Possible Extensions:
1. Add temporal analysis to show provider distribution changes over time
2. Include specialty/taxonomy analysis for deeper insights
3. Add geographic analysis at county/zip level
4. Compare provider density against population data
5. Analyze provider demographics (gender, credentials)
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:36:25.508994
    - Additional Notes: Query focuses on active healthcare provider distribution across states but excludes providers with deactivated status. Results are filtered to show only states with 100+ providers to ensure statistical relevance. The provider_type breakdown shows only individual vs organizational providers, which may need expansion depending on analysis needs.
    
    */