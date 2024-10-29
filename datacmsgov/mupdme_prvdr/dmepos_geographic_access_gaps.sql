/* DMEPOS Geographic Access Analysis for Underserved Areas

Business Purpose:
- Analyze geographic distribution of Medicare DMEPOS referring providers
- Identify potential access gaps in rural and underserved areas
- Support strategic planning for improving DMEPOS access
- Help payers and providers optimize DMEPOS service coverage

Key metrics analyzed:
- Provider density by geographic area
- Rural vs urban service patterns
- Beneficiary demographics in underserved areas
- DMEPOS utilization and payment patterns
*/

WITH provider_metrics AS (
  SELECT 
    rfrg_prvdr_state_abrvtn as state,
    rfrg_prvdr_ruca_desc as rural_urban_type,
    COUNT(DISTINCT rfrg_npi) as provider_count,
    SUM(tot_suplr_benes) as total_beneficiaries,
    AVG(bene_avg_age) as avg_beneficiary_age,
    AVG(bene_cc_ph_diabetes_v2_pct) as diabetes_pct,
    AVG(bene_cc_ph_copd_v2_pct) as copd_pct,
    SUM(suplr_mdcr_pymt_amt) as total_medicare_payments,
    SUM(suplr_mdcr_pymt_amt)/NULLIF(SUM(tot_suplr_benes),0) as payment_per_beneficiary
  FROM mimi_ws_1.datacmsgov.mupdme_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent year
  AND tot_suplr_benes >= 11 -- Exclude suppressed beneficiary counts
  GROUP BY 1, 2
),

state_summary AS (
  SELECT
    state,
    SUM(CASE WHEN rural_urban_type LIKE '%Rural%' THEN provider_count ELSE 0 END) as rural_providers,
    SUM(CASE WHEN rural_urban_type LIKE '%Urban%' THEN provider_count ELSE 0 END) as urban_providers,
    SUM(total_beneficiaries) as state_total_beneficiaries,
    AVG(payment_per_beneficiary) as avg_payment_per_beneficiary
  FROM provider_metrics
  GROUP BY 1
)

SELECT 
  pm.state,
  pm.rural_urban_type,
  pm.provider_count,
  pm.total_beneficiaries,
  ROUND(pm.avg_beneficiary_age,1) as avg_beneficiary_age,
  ROUND(pm.diabetes_pct,1) as diabetes_pct,
  ROUND(pm.copd_pct,1) as copd_pct,
  ROUND(pm.payment_per_beneficiary,2) as payment_per_beneficiary,
  ss.rural_providers,
  ss.urban_providers,
  ROUND(pm.provider_count * 1000.0 / NULLIF(pm.total_beneficiaries,0), 2) as providers_per_1000_beneficiaries
FROM provider_metrics pm
JOIN state_summary ss ON pm.state = ss.state
ORDER BY 
  pm.state,
  pm.rural_urban_type

/*
How the query works:
1. Creates provider_metrics CTE to calculate key metrics by state and rural/urban classification
2. Creates state_summary CTE to aggregate rural vs urban provider counts
3. Joins these together to produce final analysis with geographic access metrics

Assumptions and limitations:
- Uses most recent year of data (2022)
- Excludes records with suppressed beneficiary counts (<11)
- Rural/urban classification based on RUCA codes
- Does not account for cross-border service provision
- Provider counts may include inactive providers

Possible extensions:
1. Add trend analysis across multiple years
2. Include specialty-specific access analysis
3. Add geographic distance/drive time analysis
4. Incorporate social vulnerability index data
5. Add provider per capita benchmarking vs national averages
6. Include analysis of specific DMEPOS categories (DME, POS, Drug)
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:04:04.963343
    - Additional Notes: This query focuses on geographic access analysis of DMEPOS providers with a special emphasis on rural vs urban disparities. Note that the results will exclude areas with fewer than 11 beneficiaries due to CMS data suppression rules. The providers_per_1000_beneficiaries metric may need adjustment based on specific service area definitions.
    
    */