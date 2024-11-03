-- Healthcare_Organization_Phone_Coverage_Analysis.sql

-- Business Purpose:
-- - Identify healthcare organizations with missing or potentially invalid phone numbers
-- - Support patient access improvement initiatives by highlighting communication gaps
-- - Enable outreach programs to update contact information database
-- - Improve emergency response coordination capabilities

-- Main Query
WITH phone_status AS (
  SELECT 
    state,
    COUNT(*) as total_orgs,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) as missing_phone,
    SUM(CASE WHEN LENGTH(phone) != 10 AND phone IS NOT NULL THEN 1 ELSE 0 END) as invalid_phone,
    SUM(CASE WHEN LENGTH(phone) = 10 THEN 1 ELSE 0 END) as valid_phone,
    ROUND(AVG(revenue)) as avg_revenue
  FROM mimi_ws_1.synthea.organizations
  GROUP BY state
),
ranked_states AS (
  SELECT 
    state,
    total_orgs,
    missing_phone,
    invalid_phone,
    valid_phone,
    avg_revenue,
    -- Calculate percentage of organizations with contact issues
    ROUND((missing_phone + invalid_phone) * 100.0 / total_orgs, 1) as contact_issue_pct,
    -- Rank states by contact issues percentage
    ROW_NUMBER() OVER (ORDER BY (missing_phone + invalid_phone) * 100.0 / total_orgs DESC) as priority_rank
  FROM phone_status
  WHERE total_orgs >= 5  -- Focus on states with meaningful sample size
)
SELECT 
  state,
  total_orgs,
  missing_phone,
  invalid_phone,
  valid_phone,
  contact_issue_pct,
  priority_rank,
  avg_revenue
FROM ranked_states
ORDER BY priority_rank;

-- How it works:
-- 1. First CTE (phone_status) aggregates basic phone number statistics by state
-- 2. Second CTE (ranked_states) calculates percentages and ranks states
-- 3. Final output provides prioritized view of states needing contact information updates

-- Assumptions and Limitations:
-- - Assumes phone numbers should be 10 digits
-- - Requires minimum 5 organizations per state for meaningful analysis
-- - Does not validate actual phone number format beyond length
-- - Revenue correlation might be impacted by missing data

-- Possible Extensions:
-- 1. Add area code analysis to verify local number validity
-- 2. Include time-based trending of contact information quality
-- 3. Correlate phone issues with utilization rates
-- 4. Add geographic clustering analysis for targeted outreach
-- 5. Include cost estimates for contact information update campaigns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:22:53.293942
    - Additional Notes: Query identifies healthcare organizations with contact information issues, prioritizing states by coverage gaps. Minimum threshold of 5 organizations per state ensures statistical relevance. Contact issue percentage calculation includes both missing and invalid phone numbers.
    
    */