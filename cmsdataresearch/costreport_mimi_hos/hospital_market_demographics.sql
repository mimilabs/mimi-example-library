-- Hospital Geographic Market Analysis and Demographics
-- Business Purpose: This query analyzes key hospital characteristics by geographic market to understand:
-- - How hospitals are distributed across rural vs urban settings 
-- - Market concentration and competition by region
-- - Local market bed capacity and utilization patterns
-- - Regional patterns in care delivery and hospital types
-- This helps healthcare stakeholders make decisions about:
-- - Market expansion and location planning
-- - Service line development based on local needs
-- - Population health and access strategies
-- - Network adequacy and coverage planning

WITH market_summary AS (
  SELECT 
    state_code,
    rural_versus_urban,
    medicare_cbsa_number,
    COUNT(DISTINCT provider_ccn) as num_hospitals,
    SUM(number_of_beds) as total_market_beds,
    AVG(total_discharges_v_xviii_xix_unknown) as avg_discharges,
    SUM(total_days_v_xviii_xix_unknown) / NULLIF(SUM(total_bed_days_available), 0) as market_occupancy_rate,
    
    -- Categorize market density
    CASE 
      WHEN COUNT(DISTINCT provider_ccn) >= 10 THEN 'High Density'
      WHEN COUNT(DISTINCT provider_ccn) >= 5 THEN 'Medium Density'
      ELSE 'Low Density'
    END as market_density,
    
    -- Calculate key ratios
    COUNT(CASE WHEN provider_type = '1' THEN 1 END) * 100.0 / 
      NULLIF(COUNT(DISTINCT provider_ccn), 0) as pct_general_hospitals,
    COUNT(CASE WHEN type_of_control IN ('1','2') THEN 1 END) * 100.0 / 
      NULLIF(COUNT(DISTINCT provider_ccn), 0) as pct_nonprofit
  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos
  WHERE fiscal_year_end_date >= '2020-01-01'
  GROUP BY state_code, rural_versus_urban, medicare_cbsa_number
)

SELECT
  state_code,
  rural_versus_urban,
  market_density,
  COUNT(*) as num_markets,
  AVG(num_hospitals) as avg_hospitals_per_market,
  AVG(total_market_beds) as avg_beds_per_market,
  AVG(market_occupancy_rate) as avg_occupancy_rate,
  AVG(pct_general_hospitals) as avg_pct_general_hospitals,
  AVG(pct_nonprofit) as avg_pct_nonprofit
FROM market_summary
GROUP BY state_code, rural_versus_urban, market_density
HAVING COUNT(*) >= 3 -- Only include areas with meaningful samples
ORDER BY state_code, rural_versus_urban;

-- How this query works:
-- 1. Creates a CTE that calculates market-level metrics by state/CBSA/rural-urban status
-- 2. Aggregates those metrics to show patterns at the state/rural-urban level
-- 3. Includes calculations for market concentration, hospital mix, and capacity utilization
-- 4. Filters to recent years and markets with sufficient sample size

-- Assumptions and Limitations:
-- - Uses CBSA as proxy for healthcare markets which may not perfectly align with actual patterns
-- - Rural/urban classification is binary and may miss nuanced geographic patterns
-- - Occupancy calculations assume consistent bed availability throughout the year
-- - Market density categories are somewhat arbitrary cutoffs

-- Possible Extensions:
-- 1. Add time series analysis to show market evolution
-- 2. Include additional metrics like case mix index or teaching status
-- 3. Add distance calculations between facilities to better measure competition
-- 4. Incorporate population demographics from Census data
-- 5. Add visualization components for mapping market characteristics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:03:48.510994
    - Additional Notes: Query requires at least 3 hospitals per analyzed market segment to ensure statistical relevance. Rural/urban classifications (1=Urban, 2=Rural) should be validated against current CMS definitions. Market density calculations use fixed thresholds (10+ hospitals for high density, 5+ for medium) which may need adjustment for specific market analyses.
    
    */