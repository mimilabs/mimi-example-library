-- Title: Housing Strain and Healthcare Analysis by ZIP Code

-- Business Purpose:
--   Analyze housing cost burden and stability metrics alongside health factors to:
--   1. Identify ZIP codes where housing challenges may impact health outcomes
--   2. Support housing assistance program planning and healthcare resource allocation
--   3. Guide community health interventions targeting housing-stressed areas
--   4. Help payers adjust risk models for housing-impacted populations

SELECT 
    z.zipcode,
    z.state,
    z.acs_tot_pop_wt_zc as total_population,
    
    -- Housing stress indicators
    z.acs_pct_owner_hu_cost_30pct_zc as pct_owners_cost_burdened,
    z.acs_pct_renter_hu_cost_30pct_zc as pct_renters_cost_burdened,
    z.acs_pct_vacant_hu_zc as pct_vacant_housing,
    z.acs_pct_1up_pers_1room_zc as pct_overcrowded,
    
    -- Housing quality metrics
    z.acs_pct_hu_plumbing_zc as pct_no_plumbing,
    z.acs_pct_hu_kitchen_zc as pct_no_kitchen,
    z.acs_median_year_built_zc as median_year_built,
    
    -- Related health metrics
    z.cdcp_asthma_adult_c_zc as pct_asthma,
    z.cdcp_kidney_disease_adult_c_zc as pct_kidney_disease,
    
    -- Economic context
    z.acs_median_hh_inc_zc as median_household_income,
    z.acs_pct_person_inc_below99_zc as pct_below_poverty

FROM mimi_ws_1.ahrq.sdohdb_zipcode z
WHERE z.year = (SELECT MAX(year) FROM mimi_ws_1.ahrq.sdohdb_zipcode)
  AND z.territory = 0  -- US states only
  AND z.acs_tot_pop_wt_zc >= 100  -- Filter out very small populations
  
-- Order by combined housing burden score
ORDER BY (COALESCE(z.acs_pct_owner_hu_cost_30pct_zc, 0) + 
          COALESCE(z.acs_pct_renter_hu_cost_30pct_zc, 0)) DESC;

-- Query Operation:
--   1. Selects latest year data for US states only
--   2. Combines key housing stress metrics with health indicators
--   3. Provides population and economic context
--   4. Ranks ZIP codes by severity of housing cost burden

-- Assumptions and Limitations:
--   - Uses most recent year data only
--   - Excludes territories and very small populations
--   - Missing values treated as 0 for ranking
--   - Housing metrics may have different collection periods
--   - Health metrics are self-reported

-- Possible Extensions:
--   1. Add year-over-year housing stability trends
--   2. Include nearby healthcare facility access metrics
--   3. Segment by urban/rural classification
--   4. Add climate/disaster risk overlays
--   5. Calculate composite vulnerability scores
--   6. Include Medicare/Medicaid utilization patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:40:46.858625
    - Additional Notes: Script calculates combined housing burden metrics alongside health indicators at ZIP level. Data quality depends heavily on ACS response rates and CDCP survey coverage. Cost burden calculations treat null values as 0 which may underestimate total burden in areas with incomplete data. Best used for comparative analysis rather than absolute measurements.
    
    */