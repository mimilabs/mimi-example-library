
/*************************************************************************
Top Outpatient Hospital Services Analysis by Provider and Cost Impact
*************************************************************************/

/*
Business Purpose:
- Analyze the highest-impact outpatient hospital services based on Medicare payments
- Identify providers with significant service volumes and payment patterns
- Provide insights into cost variations across different types of services

This analysis helps:
1. Healthcare administrators understand major cost drivers
2. Policy makers identify high-impact service areas
3. Researchers analyze Medicare spending patterns
*/

-- Main Query
WITH ranked_services AS (
  SELECT 
    apc_cd,
    apc_desc,
    COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count,
    SUM(bene_cnt) as total_beneficiaries,
    SUM(capc_srvcs) as total_services,
    AVG(avg_mdcr_pymt_amt) as avg_medicare_payment,
    SUM(capc_srvcs * avg_mdcr_pymt_amt) as total_medicare_payments,
    -- Rank services by total payments
    ROW_NUMBER() OVER (ORDER BY SUM(capc_srvcs * avg_mdcr_pymt_amt) DESC) as payment_rank
  FROM mimi_ws_1.datacmsgov.mupohp
  WHERE mimi_src_file_date = '2022-12-31' -- Focus on most recent full year
  GROUP BY apc_cd, apc_desc
)

SELECT 
  apc_cd as apc_code,
  apc_desc as service_description,
  provider_count as num_providers,
  total_beneficiaries as total_benes,
  total_services as total_svcs,
  ROUND(avg_medicare_payment, 2) as avg_medicare_pymt,
  ROUND(total_medicare_payments/1000000, 2) as total_medicare_pymt_millions,
  payment_rank
FROM ranked_services
WHERE payment_rank <= 20 -- Focus on top 20 services
ORDER BY payment_rank;

/*
How This Query Works:
1. Aggregates data at the APC (service) level
2. Calculates key metrics including provider counts, service volumes, and payments
3. Ranks services by total payment impact
4. Returns the top 20 highest-impact services

Assumptions & Limitations:
- Uses most recent full year data (2022)
- Focuses on regular Medicare payments (excludes outlier payments)
- Aggregates across all geographic regions
- Does not account for regional cost variations

Possible Extensions:
1. Add geographic analysis:
   - Break down by state/region
   - Compare rural vs urban providers

2. Add temporal analysis:
   - Compare year-over-year changes
   - Identify trending services

3. Add provider analysis:
   - Focus on specific provider types
   - Analyze outlier payment patterns

4. Add service type analysis:
   - Group services into clinical categories
   - Compare emergency vs. planned services

5. Add cost efficiency analysis:
   - Compare submitted charges to allowed amounts
   - Analyze payment variation across providers
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:31:20.866266
    - Additional Notes: Query provides a ranked view of Medicare outpatient services based on total payment impact. Results are limited to top 20 services from 2022 data. Payment amounts are rounded and total payments are shown in millions for readability. Users should verify the mimi_src_file_date value matches their desired analysis period.
    
    */