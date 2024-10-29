-- geographic_concentration_dmepos_suppliers.sql

-- Business Purpose:
-- Analyzes geographic concentration of DMEPOS suppliers to identify potential access gaps
-- and market opportunities by examining supplier density, total Medicare payments,
-- and beneficiary demographics across urban vs rural areas.
-- This helps identify underserved markets and inform network adequacy decisions.

WITH supplier_metrics AS (
  SELECT 
    -- Group by urban/rural status
    suplr_prvdr_ruca_desc,
    suplr_prvdr_state_abrvtn,
    
    -- Calculate supplier concentration
    COUNT(DISTINCT suplr_npi) as supplier_count,
    
    -- Sum key volume and payment metrics
    SUM(tot_suplr_benes) as total_beneficiaries,
    SUM(suplr_mdcr_pymt_amt) as total_medicare_payments,
    
    -- Calculate average beneficiary risk and age metrics
    AVG(bene_avg_risk_scre) as avg_risk_score,
    AVG(bene_avg_age) as avg_beneficiary_age,
    
    -- Get latest year of data
    MAX(mimi_src_file_date) as data_year
  FROM mimi_ws_1.datacmsgov.mupdme_sup
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent year
  GROUP BY 1,2
)

SELECT
  suplr_prvdr_ruca_desc as urban_rural_status,
  suplr_prvdr_state_abrvtn as state,
  supplier_count,
  total_beneficiaries,
  ROUND(total_medicare_payments/1000000,2) as total_medicare_payments_millions,
  ROUND(total_medicare_payments/supplier_count,0) as avg_payment_per_supplier,
  ROUND(total_beneficiaries/supplier_count,0) as avg_beneficiaries_per_supplier,
  ROUND(avg_risk_score,2) as avg_risk_score,
  ROUND(avg_beneficiary_age,1) as avg_beneficiary_age
FROM supplier_metrics
WHERE supplier_count >= 10  -- Filter small cells for meaningful comparison
ORDER BY 
  suplr_prvdr_ruca_desc,
  total_medicare_payments DESC

-- How it works:
-- 1. Creates supplier_metrics CTE to aggregate key metrics by urban/rural status and state
-- 2. Calculates concentration metrics like suppliers per area and payments per supplier
-- 3. Returns final results with formatted outputs and meaningful filters

-- Assumptions and Limitations:
-- - Uses most recent year of data (2022)
-- - Excludes areas with <10 suppliers to avoid small number issues
-- - Rural/Urban classification based on RUCA codes
-- - Does not account for cross-border service areas

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of supplier concentration
-- 2. Include specialty mix analysis by geography
-- 3. Add demographic factors like age distribution
-- 4. Create market opportunity score based on population/supplier ratios
-- 5. Compare with healthcare facility locations for network adequacy analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:31:42.110182
    - Additional Notes: Query provides geographic access analysis for Medicare DMEPOS suppliers by comparing urban vs rural coverage and market concentration. Key metrics include supplier density, payment distributions, and beneficiary characteristics. Useful for network adequacy planning and identifying underserved markets. Note that supplier counts under 10 are filtered out to ensure statistical reliability.
    
    */