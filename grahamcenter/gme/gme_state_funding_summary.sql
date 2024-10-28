
/*******************************************************************************
Title: Basic GME Payment Analysis for Teaching Hospitals

Business Purpose:
This query analyzes Medicare Graduate Medical Education (GME) payments to teaching 
hospitals, showing total payments and resident counts. It helps stakeholders 
understand the distribution of federal funding for medical training programs
and identify potential gaps or opportunities in GME program funding.

Key metrics examined:
- Total GME payments (Direct + Indirect)
- Number of residents (Primary Care vs Non-Primary Care)
- Per-resident payment amounts
*******************************************************************************/

WITH recent_data AS (
  -- Get the most recent fiscal year of data
  SELECT MAX(fiscal_year) as max_fy
  FROM mimi_ws_1.grahamcenter.gme
)

SELECT 
  st as state,
  COUNT(DISTINCT provider_number) as num_teaching_hospitals,
  
  -- Payment totals (in millions)
  ROUND(SUM(gme)/1000000, 2) as total_gme_payments_millions,
  ROUND(SUM(dme)/1000000, 2) as direct_gme_payments_millions,
  ROUND(SUM(ime)/1000000, 2) as indirect_gme_payments_millions,
  
  -- Resident counts
  SUM(prim_care_fte) as total_primary_care_residents,
  SUM(non_prim_care_fte) as total_non_primary_care_residents,
  
  -- Calculate payments per resident
  ROUND(SUM(gme)/(NULLIF(SUM(prim_care_fte + non_prim_care_fte),0)), 0) 
    as avg_payment_per_resident

FROM mimi_ws_1.grahamcenter.gme g
JOIN recent_data r
WHERE g.fiscal_year = r.max_fy
GROUP BY st
ORDER BY total_gme_payments_millions DESC
LIMIT 20;

/*******************************************************************************
How this query works:
1. Identifies most recent fiscal year of data
2. Aggregates key GME metrics by state
3. Calculates per-resident payment amounts
4. Shows top 20 states by total GME funding

Assumptions & Limitations:
- Uses most recent fiscal year only
- Assumes non-null payment and resident count values
- Limited to top 20 states
- Doesn't account for cost of living differences between states

Possible Extensions:
1. Add year-over-year payment trend analysis
2. Include hospital characteristics (size, urban/rural)
3. Add primary care vs specialist ratio analysis
4. Calculate state-level per-capita GME spending
5. Compare against healthcare workforce shortage areas
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:47:02.669603
    - Additional Notes: Query focuses on state-level GME funding distribution from the most recent fiscal year. Payment amounts are shown in millions for readability. Zero-division is handled in per-resident calculations using NULLIF. Consider local timezone settings when running fiscal year calculations.
    
    */