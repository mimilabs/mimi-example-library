-- specialty_pharmacy_access_analysis.sql
-- Business Purpose:
-- Analyze specialty pharmacy utilization and access across health plans to:
-- - Identify plans with strong specialty pharmacy networks
-- - Assess cost-sharing patterns for specialty medications
-- - Evaluate market opportunities for specialty pharmacy services
-- This information helps stakeholders understand specialty drug access and affordability

WITH specialty_pharmacy_metrics AS (
  -- Get core specialty pharmacy metrics by plan
  SELECT 
    plan_id,
    COUNT(DISTINCT pharmacy_type) as specialty_pharmacy_count,
    AVG(CASE WHEN coinsurance_opt = 'Y' THEN coinsurance_rate ELSE NULL END) as avg_specialty_coinsurance,
    AVG(CASE WHEN copay_opt = 'Y' THEN copay_amount ELSE NULL END) as avg_specialty_copay,
    COUNT(CASE WHEN mail_order = 'Y' THEN 1 END) as specialty_mail_order_count
  FROM mimi_ws_1.datahealthcaregov.plan_formulary_base
  WHERE pharmacy_type LIKE '%SPECIALTY%'
  GROUP BY plan_id
),
plan_rankings AS (
  -- Rank plans based on specialty pharmacy access
  SELECT
    plan_id,
    specialty_pharmacy_count,
    avg_specialty_coinsurance,
    avg_specialty_copay,
    specialty_mail_order_count,
    NTILE(4) OVER (ORDER BY specialty_pharmacy_count DESC) as network_size_quartile
  FROM specialty_pharmacy_metrics
)
SELECT
  network_size_quartile,
  COUNT(DISTINCT plan_id) as plan_count,
  ROUND(AVG(specialty_pharmacy_count),1) as avg_specialty_pharmacies,
  ROUND(AVG(avg_specialty_coinsurance),1) as typical_coinsurance_pct,
  ROUND(AVG(avg_specialty_copay),2) as typical_copay_amt,
  ROUND(AVG(specialty_mail_order_count),1) as avg_mail_order_options
FROM plan_rankings
GROUP BY network_size_quartile
ORDER BY network_size_quartile;

-- How this query works:
-- 1. First CTE aggregates specialty pharmacy metrics by plan
-- 2. Second CTE ranks plans into quartiles based on network size
-- 3. Final query summarizes key metrics by quartile grouping

-- Assumptions and Limitations:
-- - Assumes pharmacy_type field reliably identifies specialty pharmacies
-- - Limited to point-in-time snapshot based on last_updated_on
-- - Does not account for geographic distribution of specialty pharmacies
-- - Cost sharing analysis simplified to averages

-- Possible Extensions:
-- 1. Add geographic analysis using plan service area data
-- 2. Incorporate drug-specific specialty pharmacy requirements
-- 3. Trend analysis across multiple time periods
-- 4. Correlation with plan premium and enrollment data
-- 5. Competitive analysis by insurance carrier

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:58:34.869770
    - Additional Notes: Query focuses on specialty pharmacy network breadth and cost-sharing, but could benefit from additional filters on last_updated_on to ensure current data analysis. Consider adding error handling for NULL values in coinsurance_rate and copay_amount calculations.
    
    */