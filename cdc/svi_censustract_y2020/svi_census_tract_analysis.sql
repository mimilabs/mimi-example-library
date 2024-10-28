
WITH svi_data AS (
  SELECT
    fips,                   -- Census tract FIPS code
    ep_pov150 AS pov_rate,  -- Percentage of persons below 150% poverty
    ep_unemp AS unemp_rate, -- Unemployment rate
    ep_uninsur AS uninsur_rate, -- Percentage uninsured
    rpl_themes AS svi_score -- Overall SVI percentile ranking
  FROM mimi_ws_1.cdc.svi_censustract_y2020
)

SELECT
  fips,
  pov_rate,
  unemp_rate,
  uninsur_rate,
  svi_score
FROM svi_data
ORDER BY svi_score DESC
LIMIT 10;
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T16:45:49.077555
    - Additional Notes: This query extracts key social vulnerability metrics from the CDC's SVI dataset at the Census tract level, allowing identification of the most vulnerable areas that may require additional resources or support during disasters or emergencies. Limitations include the use of 2014-2018 ACS data that may not reflect current conditions, and the relative nature of the SVI metric which can make cross-region comparisons challenging.
    
    */