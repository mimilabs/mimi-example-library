
/* Provider Contact Method Analysis
 
Business Purpose:
This query analyzes the distribution and trends of healthcare provider contact methods
to understand communication preferences and identify opportunities for improving
healthcare coordination and patient access.

Key metrics:
- Distribution of contact method types (phone, fax, email)
- Temporal adoption trends
- Active vs inactive contact points
*/

WITH contact_metrics AS (
  -- Calculate metrics for each contact system type
  SELECT 
    system,
    COUNT(*) as total_contacts,
    COUNT(DISTINCT npi) as unique_providers,
    COUNT(CASE WHEN period_end IS NULL THEN 1 END) as active_contacts,
    MIN(period_start) as earliest_adoption,
    MAX(period_start) as latest_adoption
  FROM mimi_ws_1.nppes.fhir_telecom
  WHERE system IS NOT NULL
  GROUP BY system
)

SELECT
  system,
  total_contacts,
  unique_providers,
  active_contacts,
  -- Calculate percentage of active contacts
  ROUND(100.0 * active_contacts / total_contacts, 1) as active_pct,
  -- Format dates for readability
  DATE_FORMAT(earliest_adoption, 'yyyy-MM-dd') as first_adopted,
  DATE_FORMAT(latest_adoption, 'yyyy-MM-dd') as most_recent
FROM contact_metrics
ORDER BY total_contacts DESC;

/* How this query works:
1. Creates a CTE to aggregate metrics by contact system type
2. Calculates total contacts, unique providers, and active contacts
3. Determines adoption timeline through min/max period_start dates
4. Formats final results with percentages and readable dates

Assumptions & Limitations:
- Assumes NULL period_end indicates currently active contact point
- Limited to records with non-null system values
- Point-in-time snapshot based on latest data load
- Does not account for data quality issues or validation

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Trend analysis over time using period_start/end dates
3. Provider specialty analysis to identify contact preferences by practice type
4. Contact method combinations analysis (providers with multiple types)
5. Data quality assessment (invalid/outdated contact information)
6. Regional variation in adoption patterns
7. Usage patterns for different provider organization types
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:07:20.805116
    - Additional Notes: The query provides a high-level overview of healthcare provider contact methods distribution and trends. While useful for basic analysis, it does not validate contact information quality or account for potential data gaps in period_start/end dates. Consider adding data quality checks for production use.
    
    */