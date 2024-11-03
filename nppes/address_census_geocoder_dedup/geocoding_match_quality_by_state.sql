/* State-Level Match Quality Analysis for Provider Location Data
   
   Business Purpose:
   This query assesses the quality and reliability of provider address geocoding 
   by state to support data governance, provider directory accuracy, and 
   regulatory compliance initiatives. Poor match quality could indicate data 
   issues affecting provider network adequacy reporting and member communications.
*/

WITH state_match_metrics AS (
  -- Aggregate match statistics by state
  SELECT 
    state_fips,
    COUNT(*) as total_addresses,
    SUM(CASE WHEN match_indicator = 'Matched' THEN 1 ELSE 0 END) as matched_count,
    SUM(CASE WHEN match_type = 'Exact' THEN 1 ELSE 0 END) as exact_matches,
    ROUND(100.0 * SUM(CASE WHEN match_indicator = 'Matched' THEN 1 ELSE 0 END) / COUNT(*), 2) as match_rate,
    ROUND(100.0 * SUM(CASE WHEN match_type = 'Exact' THEN 1 ELSE 0 END) / 
      NULLIF(SUM(CASE WHEN match_indicator = 'Matched' THEN 1 ELSE 0 END), 0), 2) as exact_match_pct
  FROM mimi_ws_1.nppes.address_census_geocoder_dedup
  GROUP BY state_fips
)

-- Generate final report with states ranked by match quality
SELECT 
  state_fips,
  total_addresses,
  matched_count,
  exact_matches,
  match_rate,
  exact_match_pct,
  RANK() OVER (ORDER BY match_rate DESC) as match_rate_rank
FROM state_match_metrics
WHERE total_addresses >= 100  -- Filter out states with too few records
ORDER BY match_rate DESC;

/* How this query works:
   1. First CTE calculates key match quality metrics by state
   2. Main query adds ranking and filters out low-volume states
   3. Results show match rates and exact match percentages to identify data quality issues

   Assumptions and Limitations:
   - Assumes match_indicator values of 'Matched'/'No Match'
   - Assumes match_type contains 'Exact' for highest quality matches
   - States with <100 addresses excluded to avoid misleading statistics
   - Does not account for temporal variations in match quality

   Possible Extensions:
   1. Add trend analysis by comparing current vs historical match rates
   2. Break down match types by provider specialty or organization type
   3. Create alerts for states falling below match rate thresholds
   4. Add county-level analysis for states with poor match rates
   5. Compare match rates against CMS minimum accuracy requirements
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:05:24.958507
    - Additional Notes: Query requires minimum of 100 addresses per state for analysis. Match quality metrics assume standardized values for match_indicator and match_type fields. Consider adjusting the address threshold based on specific state volumes.
    
    */