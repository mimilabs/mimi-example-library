
/*******************************************************************************
Title: Medicare Inpatient Hospital Provider Analysis - Key Utilization and Payment Metrics

Business Purpose:
This query analyzes key Medicare inpatient hospital metrics at the provider level to:
1. Identify high-volume providers and their financial characteristics 
2. Understand utilization patterns and payment distributions
3. Provide baseline metrics for provider performance comparison

The results help identify facilities handling significant Medicare volume and assess
their operational and financial efficiency.
*******************************************************************************/

-- Main query to analyze provider-level metrics for 2022
SELECT
    -- Provider identification
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    
    -- Volume metrics
    tot_dschrgs as total_discharges,
    tot_benes as total_beneficiaries,
    tot_cvrd_days as total_covered_days,
    
    -- Payment metrics 
    tot_pymt_amt as total_payment,
    tot_mdcr_pymt_amt as medicare_payment,
    (tot_pymt_amt - tot_mdcr_pymt_amt) as non_medicare_payment,
    
    -- Derived metrics
    ROUND(tot_pymt_amt / NULLIF(tot_dschrgs, 0), 2) as payment_per_discharge,
    ROUND(tot_cvrd_days / NULLIF(tot_dschrgs, 0), 2) as avg_length_of_stay,
    
    -- Patient demographics
    bene_avg_age as avg_patient_age,
    bene_avg_risk_scre as avg_risk_score,
    ROUND(bene_dual_cnt * 100.0 / NULLIF(tot_benes, 0), 1) as dual_eligible_pct

FROM mimi_ws_1.datacmsgov.mupihp_prvdr
WHERE mimi_src_file_date = '2022-12-31'  -- Filter for 2022 data
  AND tot_dschrgs > 0  -- Only include providers with discharges
  
ORDER BY tot_dschrgs DESC  -- Sort by volume
LIMIT 100;  -- Focus on top 100 providers by discharge volume

/*******************************************************************************
How this query works:
1. Selects key operational and financial metrics for Medicare inpatient providers
2. Calculates derived metrics like payment per discharge and length of stay
3. Includes patient demographic indicators
4. Filters for most recent full year and active providers
5. Ranks providers by discharge volume

Assumptions and Limitations:
- Uses 2022 data - adjust date filter for other years
- Focuses on high-volume providers (top 100)
- Excludes providers with zero discharges
- Some metrics may be affected by case mix and regional factors
- Payment amounts include all components (DRG, teaching, DSH, etc.)

Possible Extensions:
1. Add year-over-year comparison:
   - Include prior year metrics
   - Calculate growth rates

2. Enhance demographic analysis:
   - Add age group distributions
   - Include racial/ethnic composition
   - Analyze dual eligible impact

3. Add quality metrics:
   - Length of stay analysis
   - Readmission rates
   - Mortality rates

4. Geographic analysis:
   - Regional comparisons
   - Urban vs rural patterns
   - State-level aggregation

5. Case mix analysis:
   - Chronic condition distributions
   - Risk score stratification
   - Specialty service lines
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:27:39.969670
    - Additional Notes: This query focuses on top 100 providers by discharge volume and requires data for year 2022. Users should adjust the mimi_src_file_date filter for analysis of different years. Payment metrics include both Medicare and non-Medicare components. Zero-discharge providers are excluded to avoid division by zero errors in derived metrics.
    
    */