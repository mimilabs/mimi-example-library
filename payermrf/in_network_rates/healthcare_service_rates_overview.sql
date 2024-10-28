
/*******************************************************************************
Title: Healthcare Service Price Analysis - Basic Rates Overview
 
Business Purpose:
This query analyzes negotiated healthcare service rates to provide insights into:
- Most common services and their average negotiated rates
- Price variations across different billing types
- Payment arrangement distributions

This helps stakeholders understand pricing patterns and cost structures across
healthcare services.
*******************************************************************************/

-- Main analysis query
WITH service_stats AS (
  -- Get core metrics for each service
  SELECT 
    billing_code,
    name,
    billing_code_type,
    billing_class,
    negotiation_arrangement,
    COUNT(*) as rate_count,
    AVG(negotiated_rate) as avg_rate,
    MIN(negotiated_rate) as min_rate,
    MAX(negotiated_rate) as max_rate
  FROM mimi_ws_1.payermrf.in_network_rates
  WHERE negotiated_rate IS NOT NULL
    AND billing_code IS NOT NULL
  GROUP BY 1,2,3,4,5
)

SELECT 
  -- Basic service identification
  billing_code,
  name,
  billing_code_type,
  billing_class,
  negotiation_arrangement,
  
  -- Price metrics
  ROUND(avg_rate,2) as average_rate,
  ROUND(min_rate,2) as minimum_rate,
  ROUND(max_rate,2) as maximum_rate,
  rate_count as number_of_rates,
  
  -- Calculate price spread
  ROUND((max_rate - min_rate),2) as price_spread,
  ROUND((max_rate - min_rate)/NULLIF(avg_rate,0) * 100,1) as spread_pct_of_avg

FROM service_stats
WHERE rate_count >= 5  -- Focus on services with meaningful sample sizes
ORDER BY rate_count DESC, avg_rate DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Creates a CTE to aggregate key metrics per service
2. Calculates price spreads and variation metrics
3. Filters for services with sufficient data points
4. Returns top 100 services by frequency and cost

Assumptions & Limitations:
- Assumes negotiated_rate values are comparable across arrangements
- Limited to services with 5+ rate entries for statistical relevance
- Does not account for geographic variations
- Top 100 limit may exclude relevant services

Possible Extensions:
1. Add geographic analysis by joining with provider reference data
2. Include temporal analysis using expiration_date
3. Compare rates across different reporting entities
4. Add service code grouping analysis
5. Incorporate billing code modifiers impact analysis

Additional filters could be added for:
- Specific billing_code_types
- Date ranges
- Reporting entities
- Negotiation arrangements
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:41:07.120599
    - Additional Notes: Query focuses on high-volume services with multiple price points (5+ rates) to ensure statistical relevance. Results are limited to top 100 services by volume and cost. Monetary values are rounded to 2 decimal places for readability. Price spread percentage calculation includes null handling to prevent division by zero errors.
    
    */