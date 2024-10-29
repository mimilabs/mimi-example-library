/*
Medicare Part D Opioid Prescription Risk Analysis

This query analyzes opioid prescribing patterns with a focus on identifying potential high-risk providers 
based on prescription volume, beneficiary demographics, and geographic distribution.

Business Purpose:
- Identify providers with high opioid prescription rates relative to their total prescriptions
- Analyze correlation between patient risk scores and opioid prescribing patterns 
- Examine geographical distribution of opioid prescribing to identify potential hotspots
- Support opioid prescription monitoring and risk management initiatives
*/

WITH provider_metrics AS (
  -- Calculate key provider-level metrics
  SELECT 
    prscrbr_npi,
    prscrbr_last_org_name,
    prscrbr_type,
    prscrbr_state_abrvtn,
    prscrbr_city,
    tot_clms,
    opioid_tot_clms,
    opioid_prscrbr_rate,
    opioid_la_tot_clms,
    bene_avg_risk_scre,
    bene_avg_age,
    tot_benes
  FROM mimi_ws_1.datacmsgov.mupdpr_prvdr
  WHERE mimi_src_file_date = '2022-12-31'
    AND tot_clms >= 100  -- Focus on providers with meaningful prescription volume
    AND opioid_tot_clms > 0  -- Only include providers prescribing opioids
)

SELECT 
  p.prscrbr_state_abrvtn,
  p.prscrbr_city,
  p.prscrbr_type,
  COUNT(DISTINCT p.prscrbr_npi) as provider_count,
  
  -- Calculate opioid prescribing metrics
  AVG(p.opioid_prscrbr_rate) as avg_opioid_rate,
  AVG(p.opioid_la_tot_clms * 100.0 / NULLIF(p.opioid_tot_clms, 0)) as avg_longacting_pct,
  
  -- Patient risk metrics
  AVG(p.bene_avg_risk_scre) as avg_patient_risk_score,
  AVG(p.bene_avg_age) as avg_patient_age,
  
  -- Volume metrics
  SUM(p.opioid_tot_clms) as total_opioid_claims,
  SUM(p.tot_benes) as total_patients

FROM provider_metrics p

GROUP BY 
  p.prscrbr_state_abrvtn,
  p.prscrbr_city,
  p.prscrbr_type

HAVING COUNT(DISTINCT p.prscrbr_npi) >= 5  -- Only include locations with multiple providers

ORDER BY 
  avg_opioid_rate DESC,
  total_opioid_claims DESC

/*
How this query works:
1. Creates a CTE with provider-level metrics, filtering for recent data and meaningful prescription volume
2. Aggregates data by geography and provider type to identify trends and patterns
3. Calculates key risk indicators including opioid prescription rates and patient characteristics
4. Orders results to highlight areas with highest opioid prescribing rates

Assumptions and Limitations:
- Uses 2022 data (adjust mimi_src_file_date as needed)
- Excludes providers with <100 total claims to focus on active prescribers
- Requires minimum of 5 providers per geographic area to protect privacy
- Does not account for legitimate differences in prescribing needs across specialties
- Long-acting opioid percentage calculation may include null values

Possible Extensions:
1. Add year-over-year trend analysis to track changes in prescribing patterns
2. Include additional risk factors like % of elderly patients or dual-eligible beneficiaries
3. Create provider-level risk score combining multiple metrics
4. Add benchmarking against specialty-specific averages
5. Include spatial analysis to identify regional clusters
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:04:55.484643
    - Additional Notes: This query requires minimum volume thresholds (100+ claims per provider, 5+ providers per area) which may exclude some rural areas or low-volume prescribers. Risk metrics are sensitive to provider specialty mix and patient demographics. Consider adjusting thresholds based on specific monitoring needs.
    
    */