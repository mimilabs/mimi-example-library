
/*******************************************************
Title: Medicare DMEPOS Provider High-Cost Analysis
 
Business Purpose:
- Analyze Medicare Durable Medical Equipment, Prosthetics, Orthotics and Supplies (DMEPOS) providers
- Identify high-cost providers and their specialties
- Compare standardized payments to account for geographic differences
- Examine beneficiary demographics served by top providers
********************************************************/

-- Get top 100 providers by total Medicare standardized payments
WITH top_providers AS (
  SELECT
    -- Provider details
    rfrg_npi,
    rfrg_prvdr_last_name_org as provider_name,
    rfrg_prvdr_city as city,
    rfrg_prvdr_state_abrvtn as state,
    rfrg_prvdr_spclty_desc as specialty,
    
    -- Aggregate payment metrics
    suplr_mdcr_stdzd_pymt_amt as total_std_payment,
    tot_suplr_benes as total_beneficiaries,
    
    -- Calculate per beneficiary metrics
    ROUND(suplr_mdcr_stdzd_pymt_amt / NULLIF(tot_suplr_benes, 0), 2) as payment_per_bene,
    
    -- Beneficiary demographics 
    bene_avg_age as avg_patient_age,
    bene_avg_risk_scre as avg_risk_score,
    
    -- Calculate key percentages
    ROUND(100.0 * bene_feml_cnt / NULLIF(tot_suplr_benes, 0), 1) as pct_female,
    ROUND(100.0 * bene_dual_cnt / NULLIF(tot_suplr_benes, 0), 1) as pct_dual_eligible

  FROM mimi_ws_1.datacmsgov.mupdme_prvdr
  WHERE tot_suplr_benes >= 11  -- Filter out low volume providers
    AND rfrg_prvdr_cntry = 'US' -- US providers only
    AND mimi_src_file_date = '2022-12-31' -- Most recent year
)

SELECT *
FROM top_providers
ORDER BY total_std_payment DESC
LIMIT 100;

/********************************************************
How it works:
1. Filters to most recent year and US providers only
2. Calculates key metrics per provider including standardized payments 
3. Adds beneficiary demographic information
4. Returns top 100 providers by total payments

Assumptions & Limitations:
- Uses standardized payments to account for geographic variations
- Excludes providers with <11 beneficiaries (suppressed data)
- Limited to single year snapshot
- Demographics may be skewed by provider specialty

Possible Extensions:
1. Add year-over-year payment trend analysis
2. Compare costs across specialties and geographies  
3. Analyze relationships between risk scores and payments
4. Break out costs by DME vs prosthetics vs drugs
5. Add quality metrics when available
********************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:52:25.725723
    - Additional Notes: Query focuses on standardized payments which normalize for geographic differences. Results exclude providers with fewer than 11 beneficiaries due to CMS data suppression rules. Current filter is set to 2022 data - update mimi_src_file_date parameter for different years.
    
    */