
/*******************************************************************************
Title: Key Metrics for Buprenorphine Treatment Access by County

Business Purpose:
This query analyzes county-level access to medication-assisted treatment (MAT) 
for opioid use disorder by examining the distribution of buprenorphine-waivered 
providers and identifying high-need areas with insufficient treatment capacity.

Key metrics calculated:
- Counties with no providers
- High-need counties lacking adequate capacity 
- Average patient capacity rates by state
*******************************************************************************/

WITH county_summary AS (
  -- Calculate key metrics by county
  SELECT 
    state,
    county,
    total_number_of_waivered_providers,
    patient_capacity,
    patient_capacity_rate,
    high_need_for_treatment_services,
    lowtono_patient_capacity
  FROM mimi_ws_1.hhsoig.buprenorphine_countydata
),

state_summary AS (
  -- Aggregate metrics at state level
  SELECT
    state,
    COUNT(*) as total_counties,
    COUNT(CASE WHEN total_number_of_waivered_providers = 0 THEN 1 END) as counties_with_no_providers,
    COUNT(CASE WHEN high_need_for_treatment_services = true 
               AND lowtono_patient_capacity = true THEN 1 END) as high_need_low_capacity_counties,
    ROUND(AVG(patient_capacity_rate),1) as avg_patient_capacity_rate
  FROM county_summary
  GROUP BY state
)

-- Generate final summary report
SELECT
  state,
  total_counties,
  counties_with_no_providers,
  high_need_low_capacity_counties,
  avg_patient_capacity_rate,
  ROUND(100.0 * counties_with_no_providers / total_counties, 1) as pct_counties_no_providers,
  ROUND(100.0 * high_need_low_capacity_counties / total_counties, 1) as pct_high_need_low_capacity
FROM state_summary
ORDER BY high_need_low_capacity_counties DESC, avg_patient_capacity_rate ASC
LIMIT 10;

/*******************************************************************************
How This Query Works:
1. Creates county_summary CTE with key metrics for each county
2. Aggregates data to state level in state_summary CTE
3. Calculates final percentages and formats output showing states with greatest
   treatment access challenges

Assumptions & Limitations:
- Data is from April 2018 snapshot
- Providers may not treat up to their full waiver capacity
- County-level aggregation may mask local variations
- Does not account for cross-county patient travel

Possible Extensions:
1. Add geographic analysis comparing urban vs rural counties
2. Include time-series analysis if historical data available
3. Join with demographic data to analyze population factors
4. Add provider density calculations (providers per square mile)
5. Compare with actual overdose statistics or treatment outcomes
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:33:22.795560
    - Additional Notes: Query highlights states with treatment gaps by identifying those with the highest number of high-need counties lacking adequate buprenorphine treatment capacity. Results are limited to top 10 states but can be adjusted by modifying the LIMIT clause. Patient capacity rates may overestimate actual treatment availability since providers often treat fewer patients than their waiver limits allow.
    
    */