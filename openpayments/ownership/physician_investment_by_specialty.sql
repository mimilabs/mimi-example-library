
/*******************************************************************************
Title: Physician Investment Analysis by Specialty and Value
 
Business Purpose:
This query analyzes the distribution of physician ownership and investments across
different medical specialties to understand financial relationships between
healthcare providers and manufacturers/GPOs. It helps identify:
- Which specialties have the highest investment values
- The average investment amounts by specialty
- The concentration of physician investors in different fields

This information is valuable for:
- Healthcare policy makers monitoring industry relationships
- Compliance officers tracking financial ties
- Researchers studying potential conflicts of interest
*******************************************************************************/

WITH specialty_metrics AS (
  -- Calculate key metrics by specialty
  SELECT 
    physician_specialty,
    COUNT(DISTINCT physician_profile_id) as num_physicians,
    ROUND(AVG(total_amount_invested_us_dollars), 2) as avg_investment,
    ROUND(AVG(value_of_interest), 2) as avg_value,
    ROUND(SUM(total_amount_invested_us_dollars), 2) as total_investment,
    ROUND(SUM(value_of_interest), 2) as total_value
  FROM mimi_ws_1.openpayments.ownership
  WHERE program_year >= 2020  -- Focus on recent years
    AND physician_specialty IS NOT NULL
  GROUP BY physician_specialty
)

SELECT
  physician_specialty,
  num_physicians,
  avg_investment,
  avg_value,
  total_investment,
  total_value,
  -- Calculate percentage of total investments
  ROUND(100.0 * total_investment / SUM(total_investment) OVER (), 2) as pct_of_total_investment,
  -- Calculate percentage of total value
  ROUND(100.0 * total_value / SUM(total_value) OVER (), 2) as pct_of_total_value
FROM specialty_metrics
WHERE num_physicians >= 5  -- Filter for specialties with meaningful sample size
ORDER BY total_value DESC
LIMIT 20  -- Focus on top specialties by value

/*******************************************************************************
How it works:
1. Creates a CTE to aggregate metrics by physician specialty
2. Calculates average and total investments/values per specialty
3. Adds percentage calculations in main query
4. Filters for specialties with sufficient data points
5. Returns top 20 specialties by total value

Assumptions & Limitations:
- Focuses on data from 2020 onwards for current relevance
- Excludes specialties with fewer than 5 physicians for statistical significance
- Does not account for changes over time or geographic variations
- Assumes reported values are accurate and complete

Possible Extensions:
1. Add time trend analysis by comparing across program years
2. Include geographic breakdown by state/region
3. Add manufacturer/GPO analysis to see concentration of investments
4. Compare physician vs family member investments
5. Analyze correlation between investment size and dispute status
6. Include detailed terms of interest analysis
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:48:03.060508
    - Additional Notes: Query filters out specialties with fewer than 5 physicians and focuses on post-2020 data for statistical relevance. Investment metrics are rounded to 2 decimal places. Results are limited to top 20 specialties by total value to highlight the most significant financial relationships.
    
    */