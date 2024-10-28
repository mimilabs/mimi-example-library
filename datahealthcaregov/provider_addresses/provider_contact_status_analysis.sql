
/*******************************************************************
Provider Availability and Capacity Analysis
*******************************************************************/

/* Business Purpose:
   This query analyzes the current capacity and availability of healthcare providers
   by examining their contact information completeness and last update status.
   This helps identify providers who may need follow-up to ensure their information
   is current and accessible to patients.
*/

-- Main Query
WITH provider_contact_status AS (
  SELECT 
    provider_type,
    -- Check completeness of contact info
    CASE 
      WHEN phone IS NOT NULL AND LENGTH(TRIM(phone)) > 0 THEN 1 
      ELSE 0 
    END AS has_phone,
    -- Check recency of updates
    CASE
      WHEN last_updated_on >= DATE_SUB(CURRENT_DATE(), 365) THEN 'Current'
      WHEN last_updated_on >= DATE_SUB(CURRENT_DATE(), 730) THEN 'Needs Review' 
      ELSE 'Outdated'
    END AS update_status
  FROM mimi_ws_1.datahealthcaregov.provider_addresses
  WHERE npi IS NOT NULL -- Ensure valid provider records
)

SELECT
  provider_type,
  COUNT(*) as total_providers,
  -- Calculate contact info metrics
  ROUND(AVG(has_phone) * 100, 1) as pct_with_phone,
  -- Calculate update status distribution
  COUNT(CASE WHEN update_status = 'Current' THEN 1 END) as current_count,
  COUNT(CASE WHEN update_status = 'Needs Review' THEN 1 END) as review_count,
  COUNT(CASE WHEN update_status = 'Outdated' THEN 1 END) as outdated_count
FROM provider_contact_status
GROUP BY provider_type
ORDER BY total_providers DESC
LIMIT 20;

/* How it works:
   1. Creates a CTE to evaluate provider contact info completeness and update status
   2. Aggregates metrics by provider type to show availability patterns
   3. Calculates percentages and counts for key indicators
   4. Orders by total providers to focus on highest impact categories

   Assumptions & Limitations:
   - Assumes phone numbers are a key indicator of provider accessibility
   - Uses 1 year threshold for "current" status and 2 years for "needs review"
   - Limited to top 20 provider types by volume
   - Does not validate phone number format

   Possible Extensions:
   1. Add validation for phone number format correctness
   2. Include address completeness metrics
   3. Add trending analysis over time using mimi_src_file_date
   4. Segment analysis by state or region
   5. Add provider response time or availability metrics if available
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:20:40.078355
    - Additional Notes: Query focuses on provider accessibility metrics through contact information completeness and data currency. It identifies providers that may need follow-up to maintain accurate directory information. The one-year and two-year thresholds for data currency can be adjusted based on specific requirements.
    
    */