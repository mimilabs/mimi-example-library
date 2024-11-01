-- Title: ZIP Code Internet Access and Healthcare Screening Analysis

-- Business Purpose:
--   Analyze relationship between internet connectivity and preventive healthcare screening rates to:
--   1. Identify areas where digital divide may impact healthcare engagement
--   2. Support telehealth and digital health outreach strategy planning
--   3. Guide resource allocation for both digital access and healthcare screening programs

SELECT 
    z.zipcode,
    z.state,
    z.acs_tot_pop_wt_zc as total_population,
    
    -- Internet access metrics
    ROUND(z.acs_pct_hh_broadband_any_zc, 1) as pct_broadband_access,
    ROUND(z.acs_pct_hh_no_internet_zc, 1) as pct_no_internet,
    ROUND(z.acs_pct_hh_smartphone_only_zc, 1) as pct_smartphone_only,
    
    -- Key preventive screening rates
    ROUND(z.cdcp_mammo_scr_f50_74_c_zc, 1) as pct_mammogram_screening,
    ROUND(z.cdcp_cervcan_scr_f21_65_c_zc, 1) as pct_cervical_screening,
    ROUND(z.cdcp_fobt_sig_col_50_75_c_zc, 1) as pct_colorectal_screening,
    
    -- Demographics for context
    ROUND(z.acs_median_hh_inc_zc, 0) as median_household_income,
    ROUND(z.acs_pct_age_above65_zc, 1) as pct_seniors,
    ROUND(z.acs_pct_uninsured_zc, 1) as pct_uninsured

FROM mimi_ws_1.ahrq.sdohdb_zipcode z
WHERE z.year = (SELECT MAX(year) FROM mimi_ws_1.ahrq.sdohdb_zipcode)
  AND z.acs_tot_pop_wt_zc >= 1000  -- Focus on ZIPs with meaningful population
  AND z.territory = 0  -- Exclude territories, focus on US states

-- Order by states and largest gaps in internet access
ORDER BY z.state, z.acs_pct_hh_no_internet_zc DESC;

-- How it works:
--   1. Selects latest year of data for each ZIP code
--   2. Combines internet access metrics with preventive screening rates
--   3. Adds demographic context with population, income, age and insurance status
--   4. Filters for populated areas and US states only
--   5. Orders results to highlight areas with digital access challenges

-- Assumptions & Limitations:
--   - Internet access percentages are household-level
--   - Screening rates are crude prevalence estimates
--   - Data may not capture most recent changes in internet access
--   - Some rural areas may have small sample sizes affecting estimate reliability

-- Possible Extensions:
--   1. Add time trend analysis to track changes in digital divide
--   2. Include distance to nearest healthcare facility
--   3. Create risk scores combining multiple access barriers
--   4. Add broadband speed/quality metrics where available
--   5. Segment analysis by urban/rural classification
--   6. Compare telehealth utilization data where available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:21:22.873313
    - Additional Notes: Query combines household internet access metrics with CDC preventive screening rates. Note that the percentages are at different levels (household vs individual) and time periods may vary between metrics. Best used for identifying broad patterns and relative disparities rather than precise point estimates.
    
    */