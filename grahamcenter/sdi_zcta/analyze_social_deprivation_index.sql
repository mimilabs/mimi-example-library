
/*
Analyzing Social Deprivation Index (SDI) at the ZIP-code Level

Business Purpose:
The Social Deprivation Index (SDI) is a valuable tool for understanding the socioeconomic challenges facing communities across the United States. By analyzing the SDI data at the ZIP-code level, we can gain insights into the geographic distribution of social deprivation and identify areas with the greatest need for targeted interventions and resource allocation.

This query demonstrates the core business value of the `mimi_ws_1.grahamcenter.sdi_zcta` table by:
1. Identifying the ZIP-code areas with the highest SDI scores, indicating the most socially deprived regions.
2. Analyzing the component scores (e.g., poverty, single-parent families, education) to understand the specific factors contributing to social deprivation in these areas.
3. Providing a foundation for further analysis, such as exploring the relationship between SDI and health outcomes, or identifying geographic clusters of high social deprivation.
*/

WITH top_sdi_areas AS (
  SELECT
    zcta5_fips,
    zcta5_population,
    sdi_score,
    povertylt100_fpl_score,
    single_parent_fam_score,
    education_lt12years_score,
    hh_no_vehicle_score,
    hh_renter_occupied_score,
    hh_crowding_score,
    nonemployed_score
  FROM mimi_ws_1.grahamcenter.sdi_zcta
  ORDER BY sdi_score DESC
  LIMIT 10
)
SELECT
  zcta5_fips,
  zcta5_population,
  sdi_score,
  povertylt100_fpl_score,
  single_parent_fam_score,
  education_lt12years_score,
  hh_no_vehicle_score,
  hh_renter_occupied_score,
  hh_crowding_score,
  nonemployed_score
FROM top_sdi_areas
ORDER BY sdi_score DESC;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:44:21.095932
    - Additional Notes: The query identifies the ZIP-code areas with the highest Social Deprivation Index (SDI) scores and analyzes the component scores to understand the factors contributing to social deprivation in these areas. However, without the ability to filter by the latest `_input_file_date`, the results may not reflect the most up-to-date data available in the table.
    
    */