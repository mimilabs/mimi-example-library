
-- Analyze Residential Density Across Census Tracts and ZIP Codes

/*
This query demonstrates the core business value of the `mimi_ws_1.huduser.tract_to_zip_mto` table, which provides a many-to-one mapping between Census Tracts and ZIP codes based on the maximum residential size per tract.

The main use case for this table is to support spatial analysis and mapping applications that require matching data between these two common geographic units. By providing a simplified mapping, the table can help researchers, policymakers, and urban planners better understand the distribution of residential, business, and other types of addresses across different geographies.

For example, this query will show how the ratio of residential addresses varies across Census Tracts that are mapped to the same ZIP code. This information can be used to identify areas with high or low residential density, which could have implications for housing policy, transportation planning, or community development.
*/

SELECT
  zip,
  usps_zip_pref_city,
  usps_zip_pref_state,
  AVG(res_ratio) AS avg_res_ratio,
  MIN(res_ratio) AS min_res_ratio,
  MAX(res_ratio) AS max_res_ratio,
  STDDEV(res_ratio) AS std_dev_res_ratio
FROM mimi_ws_1.huduser.tract_to_zip_mto
GROUP BY zip, usps_zip_pref_city, usps_zip_pref_state
ORDER BY avg_res_ratio DESC;

/*
This query first groups the data by ZIP code, USPS preferred city, and USPS preferred state. It then calculates the average, minimum, maximum, and standard deviation of the `res_ratio` column, which represents the ratio of residential addresses in each Tract-ZIP pair compared to the total residential addresses in the entire Census Tract.

By looking at these statistics, we can gain insights into the distribution of residential density within each ZIP code area. For example, a ZIP code with a high average `res_ratio` and low standard deviation might indicate a relatively uniform residential density, while a ZIP code with a lower average and higher standard deviation could suggest more variation in residential density across the different Census Tracts that make up the ZIP code.

This information could be useful for a variety of applications, such as:
- Identifying areas with high or low residential density for housing policy and community planning
- Analyzing the relationship between residential density and other demographic or socioeconomic factors
- Informing transportation planning and infrastructure investments based on the distribution of residential and other address types
- Mapping and visualizing the geographic distribution of residential, business, and other address types within and across ZIP code boundaries
*/
/*

    - Author: claude-3-haiku-20240307
    - Created At: 2024-10-28T18:36:42.845234
    - Additional Notes: This query provides insights into the distribution of residential addresses across Census Tracts that are mapped to the same ZIP codes. It can be useful for identifying areas with high or low residential density, which could inform housing policy, transportation planning, and community development initiatives.
    
    */