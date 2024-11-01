-- dmepos_drug_nutritional_spend.sql

-- Business Purpose:
-- - Analyze providers prescribing Medicare drug and nutritional products/services through DMEPOS
-- - Understand utilization patterns and costs across specialties
-- - Identify top prescribing specialties and geographic concentration
-- - Support drug/nutritional spend management and cost containment initiatives

WITH provider_drug AS (
  SELECT
    rfrg_prvdr_spclty_desc,
    rfrg_prvdr_state_abrvtn,
    COUNT(DISTINCT rfrg_npi) as provider_count,
    SUM(drug_tot_suplr_srvcs) as total_services,
    SUM(drug_suplr_mdcr_stdzd_pymt_amt) as total_std_payment,
    AVG(drug_suplr_mdcr_stdzd_pymt_amt) as avg_std_payment_per_provider,
    AVG(CAST(drug_tot_suplr_benes as FLOAT)) as avg_benes_per_provider
  FROM mimi_ws_1.datacmsgov.mupdme_prvdr
  WHERE mimi_src_file_date = '2022-12-31'  -- Most recent year
    AND drug_sprsn_ind IS NULL  -- Exclude suppressed records
    AND drug_tot_suplr_srvcs > 0 -- Only include providers with drug services
  GROUP BY 
    rfrg_prvdr_spclty_desc,
    rfrg_prvdr_state_abrvtn
)

SELECT
  rfrg_prvdr_spclty_desc as specialty,
  rfrg_prvdr_state_abrvtn as state,
  provider_count,
  total_services,
  total_std_payment,
  ROUND(avg_std_payment_per_provider, 2) as avg_payment_per_provider,
  ROUND(avg_benes_per_provider, 1) as avg_beneficiaries_per_provider,
  ROUND(total_std_payment / NULLIF(total_services, 0), 2) as payment_per_service
FROM provider_drug
WHERE total_std_payment > 0
ORDER BY total_std_payment DESC
LIMIT 100;

-- How it works:
-- 1. Filters to most recent year and valid drug/nutritional records
-- 2. Aggregates key metrics by provider specialty and state
-- 3. Calculates per-provider and per-service payment metrics
-- 4. Returns top 100 specialty-state combinations by total standardized payments

-- Assumptions & Limitations:
-- - Uses standardized payments to account for geographic variations
-- - Excludes suppressed records which may impact completeness
-- - Limited to drug/nutritional products, not full DMEPOS spend
-- - Provider specialty from claims or NPPES may have inconsistencies

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include beneficiary demographic and risk score analysis
-- 3. Compare drug spend patterns between urban vs rural areas
-- 4. Analyze correlation with specific chronic conditions
-- 5. Add supplier concentration metrics by specialty-state

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:04:52.029473
    - Additional Notes: Query focuses on provider-level drug and nutritional product spend patterns, using standardized Medicare payments to enable geographic comparisons. Key metrics include per-provider payments, beneficiary counts, and service volumes. Note that suppressed records are excluded which may impact total spend calculations for specialties with many small-volume providers.
    
    */