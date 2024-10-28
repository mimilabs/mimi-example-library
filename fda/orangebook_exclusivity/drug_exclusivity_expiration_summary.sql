
/*******************************************************************************
Title: FDA Drug Exclusivity Analysis - Core Business Value Query
 
Business Purpose:
This query analyzes drug exclusivity patterns to help:
- Identify upcoming exclusivity expirations that could impact market dynamics
- Compare exclusivity durations across different application types
- Track trends in exclusivity grants over time
- Support strategic planning for pharmaceutical companies and investors

Key business questions addressed:
1. What drugs have exclusivity periods expiring soon? 
2. How do exclusivity patterns differ between new drugs vs generics?
3. What are the most common types of exclusivity being granted?
*******************************************************************************/

WITH upcoming_expirations AS (
  -- Get drugs with exclusivity expiring in next 12 months
  SELECT 
    appl_type,
    appl_no,
    exclusivity_code,
    exclusivity_date,
    -- Calculate months until expiration
    DATEDIFF(month, CURRENT_DATE(), exclusivity_date) as months_to_expiry
  FROM mimi_ws_1.fda.orangebook_exclusivity
  WHERE exclusivity_date > CURRENT_DATE()
    AND exclusivity_date <= DATEADD(month, 12, CURRENT_DATE())
),

exclusivity_summary AS (
  -- Summarize exclusivity patterns
  SELECT
    appl_type,
    exclusivity_code,
    COUNT(*) as exclusivity_count,
    AVG(months_to_expiry) as avg_months_remaining
  FROM upcoming_expirations
  GROUP BY appl_type, exclusivity_code
)

-- Generate final business-focused report
SELECT
  appl_type as application_type,
  exclusivity_code,
  exclusivity_count as number_of_drugs,
  ROUND(avg_months_remaining, 1) as avg_months_until_expiry,
  -- Calculate percentage within application type
  ROUND(100.0 * exclusivity_count / 
    SUM(exclusivity_count) OVER (PARTITION BY appl_type), 1) as pct_of_app_type
FROM exclusivity_summary
ORDER BY 
  application_type,
  number_of_drugs DESC;

/*******************************************************************************
How this query works:
1. First CTE identifies drugs with exclusivity expiring in next 12 months
2. Second CTE aggregates the data by application and exclusivity types
3. Final query adds percentage calculations and formats for business users

Assumptions & Limitations:
- Focuses only on active exclusivity periods with future expiration dates
- Groups by high-level application types (may miss nuanced sub-categories)
- Uses current_date() for time-based calculations
- Assumes exclusivity_date field is consistently populated

Possible Extensions:
1. Add drug name/details by joining to other Orange Book tables
2. Include historical trending of exclusivity patterns
3. Add therapeutic category analysis
4. Create forecasting of generic entry opportunities
5. Compare exclusivity periods to patent expiration dates
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:57:00.743423
    - Additional Notes: This query focuses on the next 12 months of exclusivity expirations and requires the FDA Orange Book exclusivity table to be up-to-date. The results are most relevant for market analysis and competitive intelligence teams tracking potential generic drug entry opportunities. Consider adjusting the 12-month window in the upcoming_expirations CTE based on specific business planning horizons.
    
    */