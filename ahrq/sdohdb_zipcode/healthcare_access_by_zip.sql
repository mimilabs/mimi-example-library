-- Title: Healthcare Facilities Access and Demographic Analysis by ZIP Code

-- Business Purpose: 
--   Analyze healthcare facility access patterns alongside key demographic factors to:
--   1. Identify areas with limited healthcare access and high social needs
--   2. Support healthcare facility expansion planning
--   3. Understand population characteristics in relation to healthcare infrastructure
--   4. Guide community health resource allocation

-- Main Query
SELECT 
    z.zipcode,
    z.state,
    -- Population metrics
    z.acs_tot_pop_wt_zc as total_population,
    z.acs_median_age_zc as median_age,
    
    -- Healthcare facility access metrics
    z.pos_dist_ed_zp as distance_to_er,
    z.pos_dist_clinic_zp as distance_to_clinic,
    z.hifld_dist_uc_zp as distance_to_urgent_care,
    
    -- Healthcare coverage indicators
    z.acs_pct_uninsured_zc as pct_uninsured,
    z.acs_pct_medicaid_any_zc as pct_medicaid,
    
    -- Social vulnerability indicators
    z.acs_pct_person_inc_below99_zc as pct_poverty,
    z.acs_pct_disable_zc as pct_disabled,
    
    -- Healthcare facility counts
    z.ccbp_tot_phys_zp as physician_offices,
    z.ccbp_tot_home_zp as home_health_services,

    -- Additional health risk indicators
    z.cdcp_no_phy_actv_adult_c_zc as pct_no_physical_activity,
    z.cdcp_choles_adult_c_zc as pct_high_cholesterol

FROM mimi_ws_1.ahrq.sdohdb_zipcode z

-- Focus on most recent year
WHERE z.year = (SELECT MAX(year) FROM mimi_ws_1.ahrq.sdohdb_zipcode)
  AND z.territory = 0  -- Exclude territories, focus on states

-- Order by states and ZIP codes for easier analysis
ORDER BY z.state, z.zipcode;

-- How this query works:
--   1. Selects key healthcare access and demographic metrics at ZIP code level
--   2. Focuses on most recent year of data
--   3. Excludes territories to focus on US states
--   4. Combines facility distance metrics with population characteristics
--   5. Includes CDC health risk indicators for comprehensive analysis

-- Assumptions and Limitations:
--   1. Distance calculations are based on population-weighted ZIP centroids
--   2. Current year's data is most relevant for analysis
--   3. Healthcare facility counts may not reflect current operational status
--   4. ZIP code boundaries may not perfectly align with healthcare service areas
--   5. CDC health indicators are based on sample surveys and modeling

-- Possible Extensions:
--   1. Add trending analysis across multiple years
--   2. Include facility quality metrics
--   3. Add risk scoring based on multiple factors
--   4. Create geographic clusters of high-need areas
--   5. Compare urban vs rural access patterns
--   6. Analyze correlation between distance and health outcomes
--   7. Segment analysis by age groups or income levels

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:51:20.256869
    - Additional Notes: Query provides a comprehensive view of healthcare facility access and social determinants of health at ZIP code level. The distance metrics are particularly useful for identifying healthcare deserts. Note that territory=0 filter excludes US territories, so analysis is limited to 50 states and DC. CDC health indicators (pct_no_physical_activity, pct_high_cholesterol) are modeled estimates and should be interpreted with appropriate caution.
    
    */