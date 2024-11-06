-- physician_ownership_disparity_analysis.sql
-- Business Purpose: Analyze the disparities and potential conflicts of interest between direct physician 
-- vs family member ownership stakes in healthcare companies. This helps identify patterns in how medical
-- professionals structure their financial relationships and informs compliance monitoring.

WITH ownership_summary AS (
  -- Calculate average investment values and total count by ownership type
  SELECT 
    interest_held_by_physician_or_an_immediate_family_member AS owner_type,
    COUNT(*) AS total_investments,
    ROUND(AVG(total_amount_invested_us_dollars), 2) AS avg_investment_amount,
    ROUND(AVG(value_of_interest), 2) AS avg_interest_value,
    -- Calculate what percentage have disputes
    ROUND(100.0 * COUNT(CASE WHEN dispute_status_for_publication = 'Yes' THEN 1 END) / COUNT(*), 2) AS pct_disputed
  FROM mimi_ws_1.openpayments.ownership
  WHERE program_year >= 2020  -- Focus on recent years
    AND total_amount_invested_us_dollars > 0  -- Exclude $0 investments
    -- Clean data by removing null ownership types
    AND interest_held_by_physician_or_an_immediate_family_member IS NOT NULL 
  GROUP BY interest_held_by_physician_or_an_immediate_family_member
)

SELECT
  owner_type,
  total_investments,
  avg_investment_amount,
  avg_interest_value,
  pct_disputed,
  -- Calculate the ratio of value to investment amount
  ROUND(avg_interest_value / NULLIF(avg_investment_amount, 0), 2) AS value_to_investment_ratio
FROM ownership_summary
ORDER BY total_investments DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate key metrics by ownership type (physician vs family)
-- 2. Calculates average investment amounts and current values
-- 3. Computes the percentage of disputed investments
-- 4. Provides a ratio of current value to initial investment
-- 5. Orders results by total number of investments

-- Assumptions & Limitations:
-- - Assumes investments with $0 amount are incomplete/incorrect data
-- - Limited to recent years (2020+) for current relevance
-- - Does not account for multiple investments by same physician/family
-- - Value/investment ratio may be skewed by timing differences

-- Possible Extensions:
-- 1. Add trend analysis over time to see how ownership patterns are changing
-- 2. Include company-level breakdowns to see if certain firms attract more family vs direct investment
-- 3. Cross-reference with specialty data to identify professional correlations
-- 4. Add statistical significance testing between physician vs family member investments
-- 5. Incorporate dispute resolution outcomes analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:54:07.974023
    - Additional Notes: Query compares financial investment patterns between direct physician ownership and family member ownership, focusing on investment amounts, valuations, and dispute rates. Best used for compliance monitoring and identifying potential differences in how direct vs family investments are structured and managed. Note that results may be impacted by data gaps in years prior to 2020.
    
    */