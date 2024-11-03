-- inpatient_provider_utilization_analysis.sql

-- Business Purpose:
-- Analyzes inpatient provider patterns to identify opportunities for network optimization and quality improvement
-- Key metrics include provider volume, average payments, and procedure diversity
-- Helps inform network strategy, contract negotiations, and quality programs

WITH provider_metrics AS (
  SELECT 
    prvdr_num,
    COUNT(DISTINCT clm_id) as total_claims,
    COUNT(DISTINCT desynpuf_id) as unique_patients,
    ROUND(AVG(clm_pmt_amt), 2) as avg_payment,
    COUNT(DISTINCT icd9_prcdr_cd_1) as unique_procedures,
    ROUND(SUM(clm_pmt_amt), 2) as total_payments,
    ROUND(AVG(clm_utlztn_day_cnt), 1) as avg_length_of_stay
  FROM mimi_ws_1.desynpuf.inpatient_claims
  WHERE prvdr_num IS NOT NULL
  GROUP BY prvdr_num
),

provider_rankings AS (
  SELECT 
    *,
    NTILE(4) OVER (ORDER BY total_claims DESC) as volume_quartile,
    NTILE(4) OVER (ORDER BY avg_payment DESC) as cost_quartile
  FROM provider_metrics
)

SELECT
  volume_quartile,
  COUNT(*) as provider_count,
  ROUND(AVG(total_claims), 0) as avg_claims_per_provider,
  ROUND(AVG(unique_patients), 0) as avg_patients_per_provider,
  ROUND(AVG(avg_payment), 2) as mean_payment_per_claim,
  ROUND(AVG(unique_procedures), 1) as avg_unique_procedures,
  ROUND(AVG(avg_length_of_stay), 1) as avg_length_of_stay,
  ROUND(SUM(total_payments)/1000000, 2) as total_payments_millions
FROM provider_rankings
GROUP BY volume_quartile
ORDER BY volume_quartile;

-- How it works:
-- 1. First CTE calculates key metrics for each provider
-- 2. Second CTE segments providers into quartiles based on volume
-- 3. Final query summarizes metrics by volume quartile

-- Assumptions and Limitations:
-- - Assumes prvdr_num is a reliable identifier for facilities
-- - Limited to available time period in the data
-- - Synthetic data may not reflect real provider patterns
-- - Does not account for case mix or severity

-- Possible Extensions:
-- 1. Add geographic analysis if provider location data available
-- 2. Include quality metrics like readmission rates
-- 3. Analyze seasonal patterns in provider utilization
-- 4. Add procedure-specific analysis for key service lines
-- 5. Compare provider patterns across years
-- 6. Include analysis of physician utilization patterns
-- 7. Add cost efficiency metrics
-- 8. Incorporate case mix adjustment
-- 9. Analyze market share patterns
-- 10. Add quality outcome metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:47:42.329400
    - Additional Notes: Query groups healthcare providers into quartiles based on claims volume and calculates key utilization metrics. Best used for initial network assessment and identifying high-volume vs. low-volume provider patterns. Note that missing provider location data limits geographic insights.
    
    */