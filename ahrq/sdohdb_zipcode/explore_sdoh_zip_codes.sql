-- Title: Exploring Social Determinants of Health in ZIP Codes

/*
  Business Purpose:
    The SDOH database at the ZIP-level provides a comprehensive set of social determinants of health measures, which are crucial for understanding the factors that influence population health and well-being. This query focuses on analyzing the core business value of this dataset by:
    
    1. Identifying the demographic and socioeconomic characteristics of different ZIP Codes.
    2. Examining the housing and transportation patterns that may impact access to healthcare and other essential services.
    3. Exploring the relationships between SDOH factors and potential health outcomes or disparities.
    
    The insights gained from this analysis can inform targeted interventions, resource allocation, and policymaking to address health inequities and improve overall community health.
*/

SELECT
  -- Basic geographic and year information
  year,
  state,
  zipcode,
  zcta,

  -- Demographic characteristics
  acs_pct_white_nonhisp_zc AS pct_white_non_hispanic,
  acs_pct_black_nonhisp_zc AS pct_black_non_hispanic,
  acs_pct_hispanic_zc AS pct_hispanic,
  acs_median_age_zc AS median_age,

  -- Socioeconomic status
  acs_median_hh_inc_zc AS median_household_income,
  acs_pct_inc50_zc AS pct_income_below_50pov,
  acs_pct_hh_inc_10000_zc AS pct_hh_income_lt_10k,
  acs_pct_hh_inc_100000_zc AS pct_hh_income_gt_100k,
  acs_pct_lt_hs_zc AS pct_adults_lt_hs_edu,
  acs_pct_bachelor_dgr_zc AS pct_adults_bachelors,

  -- Housing characteristics
  acs_pct_owner_hu_zc AS pct_owner_occupied_housing,
  acs_pct_renter_hu_zc AS pct_renter_occupied_housing,
  acs_pct_hu_no_veh_zc AS pct_housing_no_vehicle,
  acs_pct_hu_mobile_home_zc AS pct_mobile_homes,

  -- Healthcare access
  pos_dist_ed_zp AS dist_to_nearest_ed_miles,
  pos_dist_clinic_zp AS dist_to_nearest_clinic_miles,
  acs_pct_uninsured_below64_zc AS pct_uninsured_lt_64

FROM
  mimi_ws_1.ahrq.sdohdb_zipcode
WHERE
  year = (SELECT MAX(year) FROM mimi_ws_1.ahrq.sdohdb_zipcode)
ORDER BY
  median_household_income DESC
LIMIT 10;

/*
  How the query works:
    - The query selects key demographic, socioeconomic, housing, and healthcare access variables from the SDOH database at the ZIP Code level.
    - It filters the data to the most recent year and orders the results by median household income in descending order, showing the top 10 ZIP Codes with the highest incomes.
    - This provides a high-level overview of the socioeconomic and health-related characteristics of the wealthiest ZIP Codes, which can be used as a starting point for further analysis.

  Assumptions and limitations:
    - The data is aggregated at the ZIP Code Tabulation Area (ZCTA) level, which may not perfectly align with actual ZIP Code boundaries.
    - Some variables, such as healthcare access measures, are calculated using population-weighted centroids, which may not capture the full geographic distribution within a ZIP Code.
    - The data represents a snapshot in time and may not reflect the most current conditions or changes over time.

  Possible extensions:
    - Compare the characteristics of the highest-income ZIP Codes to the lowest-income ZIP Codes to identify potential health disparities.
    - Analyze how SDOH factors vary across different regions, states, or urban/rural classifications.
    - Investigate the relationships between specific SDOH factors and health outcomes, such as disease prevalence, healthcare utilization, or mortality rates.
    - Explore spatial patterns and clustering of SDOH factors to identify geographical areas with the greatest needs.
    - Incorporate additional data sources, such as community resources or environmental factors, to provide a more comprehensive understanding of the social determinants of health.
*//*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:07:01.498334
    - Additional Notes: This query provides a high-level overview of the socioeconomic and health-related characteristics of the wealthiest ZIP Codes, which can be used as a starting point for further analysis. The data is aggregated at the ZIP Code Tabulation Area (ZCTA) level, which may not perfectly align with actual ZIP Code boundaries. The healthcare access measures are calculated using population-weighted centroids, which may not capture the full geographic distribution within a ZIP Code. The data represents a snapshot in time and may not reflect the most current conditions or changes over time.
    
    */