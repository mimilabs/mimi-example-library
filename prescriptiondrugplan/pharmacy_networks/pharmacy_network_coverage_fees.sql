
/*
Title: Analysis of Pharmacy Network Coverage and Dispensing Fees
 
Business Purpose:
This query analyzes pharmacy network characteristics and dispensing fees to:
1. Assess the mix of pharmacy types (retail vs mail order, preferred vs non-preferred)
2. Compare dispensing fees across pharmacy types and supply durations
3. Identify potential access gaps in pharmacy networks

The insights help:
- Evaluate pharmacy network adequacy
- Understand cost structures
- Support network optimization decisions
*/

-- Main Analysis 
WITH pharmacy_metrics AS (
  SELECT 
    contract_id,
    plan_id,
    COUNT(DISTINCT pharmacy_number) as total_pharmacies,
    -- Calculate pharmacy type breakdowns
    SUM(CASE WHEN pharmacy_retail = 'Y' AND preferred_status_retail = 'Y' THEN 1 ELSE 0 END) as preferred_retail_count,
    SUM(CASE WHEN pharmacy_mail = 'Y' AND preferred_status_mail = 'Y' THEN 1 ELSE 0 END) as preferred_mail_count,
    
    -- Calculate average dispensing fees
    AVG(brand_dispensing_fee_30) as avg_brand_fee_30,
    AVG(brand_dispensing_fee_90) as avg_brand_fee_90,
    AVG(generic_dispensing_fee_30) as avg_generic_fee_30,
    AVG(generic_dispensing_fee_90) as avg_generic_fee_90,
    
    -- Calculate in-area coverage
    SUM(CASE WHEN in_area_flag = 1 THEN 1 ELSE 0 END) as in_area_pharmacies,
    COUNT(DISTINCT pharmacy_zipcode) as unique_zipcodes
  FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
  GROUP BY contract_id, plan_id
)

SELECT
  contract_id,
  plan_id,
  total_pharmacies,
  -- Calculate network composition percentages
  ROUND(100.0 * preferred_retail_count / NULLIF(total_pharmacies, 0), 2) as pct_preferred_retail,
  ROUND(100.0 * preferred_mail_count / NULLIF(total_pharmacies, 0), 2) as pct_preferred_mail,
  
  -- Show dispensing fee differentials
  ROUND(avg_brand_fee_90 - avg_brand_fee_30, 2) as brand_fee_90day_savings,
  ROUND(avg_generic_fee_90 - avg_generic_fee_30, 2) as generic_fee_90day_savings,
  
  -- Coverage metrics
  ROUND(100.0 * in_area_pharmacies / NULLIF(total_pharmacies, 0), 2) as pct_in_area,
  unique_zipcodes as geographic_coverage
FROM pharmacy_metrics
WHERE total_pharmacies > 0
ORDER BY total_pharmacies DESC
LIMIT 100;

/*
How It Works:
1. Creates pharmacy_metrics CTE to aggregate key metrics by contract/plan
2. Calculates percentages and differentials in the main query
3. Filters out plans with no pharmacies
4. Limits to top 100 plans by network size

Assumptions & Limitations:
- Assumes Y/N indicators are consistently populated
- Does not account for pharmacy capacity or operating hours
- Geographic coverage analysis is simplified to ZIP code count
- Limited to current snapshot without historical trends

Possible Extensions:
1. Add temporal analysis by incorporating mimi_src_file_date
2. Join with plan_information for additional context
3. Add geographic clustering analysis using pharmacy_zipcode
4. Compare network characteristics across different contract types
5. Analyze correlation between dispensing fees and network size
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:38:22.920578
    - Additional Notes: This query focuses on key performance indicators for pharmacy networks, including network composition, fee structures, and geographic coverage. Note that results are limited to top 100 plans by network size and calculations assume complete data in Y/N indicator fields. Consider increasing the LIMIT if analyzing the full network landscape.
    
    */