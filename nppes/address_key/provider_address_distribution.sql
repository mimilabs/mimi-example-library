
/*******************************************************************************
Title: Healthcare Provider Address Distribution Analysis

Business Purpose:
This query analyzes the distribution and frequency of provider addresses to:
- Identify the most commonly used business and mailing addresses
- Compare business vs mailing address usage patterns
- Help detect potential address anomalies or concentrations
- Support facilities planning and provider network analysis

Core metrics focus on address frequency and type distribution to understand
where healthcare providers are physically located and receive mail.
*******************************************************************************/

-- Main Analysis Query
WITH address_metrics AS (
  SELECT 
    -- Extract state from address_key (assumes state is 4th pipe-delimited field)
    SPLIT(address_key, '\\|')[3] as state,
    
    -- Calculate address usage metrics
    SUM(npi_b1_cnt) as total_business_usage,
    SUM(npi_m1_cnt) as total_mailing_usage,
    COUNT(*) as unique_addresses,
    
    -- Calculate ratios
    SUM(npi_b1_cnt) / NULLIF(SUM(npi_m1_cnt), 0) as business_to_mailing_ratio
    
  FROM mimi_ws_1.nppes.address_key
  WHERE mimi_dlt_load_date = (SELECT MAX(mimi_dlt_load_date) FROM mimi_ws_1.nppes.address_key)
  GROUP BY state
)

SELECT
  state,
  unique_addresses,
  total_business_usage,
  total_mailing_usage,
  ROUND(business_to_mailing_ratio, 2) as business_to_mailing_ratio,
  
  -- Calculate percentages of total
  ROUND(100.0 * unique_addresses / SUM(unique_addresses) OVER(), 1) as pct_of_total_addresses,
  ROUND(100.0 * total_business_usage / SUM(total_business_usage) OVER(), 1) as pct_of_total_business
  
FROM address_metrics
WHERE state IS NOT NULL
ORDER BY total_business_usage DESC
LIMIT 20;

/*******************************************************************************
How This Query Works:
1. Creates address metrics CTE to calculate key measures by state
2. Extracts state from pipe-delimited address_key field
3. Calculates totals and ratios for business vs mailing addresses
4. Produces final output with percentages and rankings

Key Assumptions:
- Address_key format is consistent with pipe delimiter
- State field is in 4th position of address_key
- Non-null state values represent valid addresses
- Latest load date represents current state

Limitations:
- Does not validate address quality/accuracy
- Cannot identify specific providers or facilities
- May include inactive/historical addresses
- State extraction may fail if address format varies

Possible Extensions:
1. Add temporal analysis to track address changes over time:
   - Compare metrics across different load dates
   - Identify trending areas

2. Enhance geographic analysis:
   - Add city-level aggregation
   - Calculate distance-based metrics
   - Map address concentrations

3. Add data quality metrics:
   - Flag suspicious patterns
   - Identify potential duplicates
   - Validate address components

4. Create provider network analysis:
   - Analyze provider density by region
   - Identify coverage gaps
   - Support network adequacy reporting
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:44:27.109439
    - Additional Notes: Query assumes consistent pipe-delimited address_key format with state in 4th position. For accurate results, verify address_key format consistency and ensure state extraction logic matches actual data pattern. Results are limited to top 20 states by business address usage.
    
    */