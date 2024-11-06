-- NADAC Drug Supply Chain Market Share Analysis
--
-- Business Purpose:
-- This query analyzes NADAC drug pricing to understand pharmacy channel market share:
-- 1. Identify distribution of drugs across pharmacy channels (chain vs independent)
-- 2. Evaluate market concentration and competitive dynamics
-- 3. Support supply chain optimization strategies
-- 4. Inform pharmacy network contracting decisions

WITH supply_chain_metrics AS (
  -- Calculate key metrics per pharmacy type and drug classification
  SELECT 
    pharmacy_type_indicator,
    classification_for_rate_setting,
    COUNT(DISTINCT ndc) as unique_drugs,
    COUNT(*) as total_records,
    AVG(nadac_per_unit) as avg_price,
    PERCENTILE(nadac_per_unit, 0.5) as median_price,
    COUNT(DISTINCT mimi_src_file_date) as reporting_periods
  FROM mimi_ws_1.datamedicaidgov.nadac
  WHERE effective_date >= '2022-01-01'
    AND nadac_per_unit > 0
    AND pharmacy_type_indicator IS NOT NULL
  GROUP BY 
    pharmacy_type_indicator,
    classification_for_rate_setting
)

-- Calculate market share metrics and pricing differentials
SELECT
  pharmacy_type_indicator,
  classification_for_rate_setting,
  unique_drugs,
  total_records,
  round(avg_price, 2) as avg_price,
  round(median_price, 2) as median_price,
  round(100.0 * unique_drugs / sum(unique_drugs) over(), 2) as drug_share_pct,
  round(100.0 * total_records / sum(total_records) over(), 2) as volume_share_pct,
  reporting_periods
FROM supply_chain_metrics
ORDER BY 
  pharmacy_type_indicator,
  classification_for_rate_setting;

-- How the Query Works:
-- 1. Creates base metrics by pharmacy type and drug classification
-- 2. Calculates market share percentages using window functions
-- 3. Focuses on recent data (2022+) to reflect current market dynamics
-- 4. Excludes invalid prices and missing pharmacy indicators
--
-- Assumptions and Limitations:
-- - Assumes pharmacy_type_indicator accurately reflects channel
-- - Limited to retail pharmacy channels (excludes specialty/mail order)
-- - Market share based on drug count may not reflect revenue share
-- - Recent timeframe may not capture historical trends
--
-- Possible Extensions:
-- 1. Add temporal analysis to show channel shift over time
-- 2. Include therapeutic class breakdowns by channel
-- 3. Compare pricing variations between channels
-- 4. Add geographic analysis of pharmacy distribution
-- 5. Analyze correlation between channel and pricing stability

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:01:49.952015
    - Additional Notes: Query provides insights into pharmacy market dynamics by analyzing drug distribution and pricing across different pharmacy channels. Useful for stakeholders involved in pharmacy network management and supply chain optimization. Core metrics include channel market share, drug coverage, and pricing differentials between chain and independent pharmacies. Note that the analysis is limited to retail pharmacies and recent data (2022+).
    
    */