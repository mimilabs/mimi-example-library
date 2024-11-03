-- Address Consistency Over Time Analysis
-- Business Purpose: Track and analyze changes in provider address usage patterns
-- by examining historical address patterns and identifying stable vs changing locations.
-- This helps understand provider mobility and address data quality trends.

WITH address_metrics AS (
  -- Get address usage metrics aggregated across time periods
  SELECT 
    address_key,
    MAX(npi_b1_cnt + npi_b2_cnt + npi_m1_cnt) as total_usage,
    COUNT(DISTINCT mimi_dlt_load_date) as days_present,
    MIN(mimi_dlt_load_date) as first_seen,
    MAX(mimi_dlt_load_date) as last_seen,
    SUM(npi_b1_cnt) as total_business_usage,
    SUM(npi_m1_cnt) as total_mailing_usage
  FROM mimi_ws_1.nppes.address_key
  GROUP BY address_key
)

SELECT
  -- Calculate key address stability metrics
  CASE 
    WHEN DATEDIFF(day, first_seen, last_seen) >= 365 THEN 'Stable (1yr+)'
    WHEN DATEDIFF(day, first_seen, last_seen) >= 180 THEN 'Medium (6mo-1yr)'
    ELSE 'Transient (<6mo)'
  END as address_stability,
  COUNT(*) as address_count,
  AVG(total_usage) as avg_total_usage,
  AVG(days_present) as avg_days_present,
  AVG(total_business_usage) / AVG(total_mailing_usage) as business_to_mailing_ratio
FROM address_metrics
GROUP BY 
  CASE 
    WHEN DATEDIFF(day, first_seen, last_seen) >= 365 THEN 'Stable (1yr+)'
    WHEN DATEDIFF(day, first_seen, last_seen) >= 180 THEN 'Medium (6mo-1yr)'
    ELSE 'Transient (<6mo)'
  END
ORDER BY address_count DESC;

/* 
How this works:
1. Creates a CTE that aggregates address usage metrics over time
2. Categorizes addresses based on their persistence in the dataset
3. Calculates summary statistics for each stability category
4. Orders results by frequency to show distribution

Assumptions:
- Address changes indicate either provider moves or data corrections
- Longer presence in dataset suggests more reliable address data
- Higher usage counts indicate more important/verified addresses

Limitations:
- Cannot distinguish between actual moves and data corrections
- Temporal analysis limited by available date range
- Does not account for seasonal patterns

Possible Extensions:
1. Add geographic breakdown by parsing state from address_key
2. Compare stability patterns between provider types
3. Create alerts for sudden changes in address patterns
4. Analyze correlation between stability and usage frequency
5. Track month-over-month change rates
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:11:46.653504
    - Additional Notes: The query provides a high-level view of address persistence patterns but requires at least 1 year of historical data in the mimi_dlt_load_date column for meaningful stability categorization. Consider adjusting the time thresholds (365/180 days) based on your specific business needs and data collection frequency.
    
    */