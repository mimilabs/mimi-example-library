/* PACE Rate Book County Payment Analysis
   Author: Healthcare Data Analytics Team
   Date: 2024-02-15
   Purpose: Analyze Medicare PACE Payment Rates Across Counties and ESRD Status
*/

WITH county_payment_summary AS (
    -- Aggregate and compare payment rates across counties and ESRD status
    SELECT 
        state,
        county_name,
        ROUND(AVG(parts_ab_rate), 2) AS avg_non_esrd_rate,
        ROUND(AVG(parts_ab_esrd_rate), 2) AS avg_esrd_rate,
        ROUND(AVG(parts_ab_esrd_rate) - AVG(parts_ab_rate), 2) AS esrd_rate_premium,
        COUNT(DISTINCT code) AS county_count,
        MAX(mimi_src_file_date) AS latest_rate_update
    FROM mimi_ws_1.cmspayment.pace_ratebook
    GROUP BY state, county_name
),
state_level_analysis AS (
    -- Provide state-level insights into PACE payment dynamics
    SELECT 
        state,
        ROUND(AVG(avg_non_esrd_rate), 2) AS state_avg_non_esrd_rate,
        ROUND(AVG(avg_esrd_rate), 2) AS state_avg_esrd_rate,
        ROUND(AVG(esrd_rate_premium), 2) AS state_avg_esrd_premium,
        SUM(county_count) AS total_counties
    FROM county_payment_summary
    GROUP BY state
)

-- Primary query to demonstrate business insights
SELECT 
    c.state,
    c.county_name,
    c.avg_non_esrd_rate,
    c.avg_esrd_rate,
    c.esrd_rate_premium,
    s.state_avg_non_esrd_rate,
    s.state_avg_esrd_rate,
    s.state_avg_esrd_premium,
    c.latest_rate_update
FROM county_payment_summary c
JOIN state_level_analysis s ON c.state = s.state
WHERE c.esrd_rate_premium > 0
ORDER BY c.esrd_rate_premium DESC
LIMIT 100;

/* Query Insights and Methodology:
   - Calculates payment rate differences between ESRD and non-ESRD beneficiaries
   - Provides county and state-level perspectives on Medicare PACE rates
   - Focuses on counties with ESRD rate premiums

   Key Business Value:
   1. Identifies geographic variations in Medicare PACE payments
   2. Highlights cost differences for ESRD vs. non-ESRD beneficiaries
   3. Supports strategic planning for healthcare resource allocation

   Limitations:
   - Uses aggregated county-level data
   - Snapshot of rates at specific time periods
   - Does not account for individual beneficiary variations

   Potential Extensions:
   - Add year-over-year rate change analysis
   - Incorporate demographic overlay data
   - Create predictive models for rate trends
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:49:56.047643
    - Additional Notes: Query provides insights into Medicare PACE payment rates across counties, comparing ESRD and non-ESRD beneficiary rates. Requires recent data in mimi_ws_1.cmspayment.pace_ratebook table for accurate analysis.
    
    */