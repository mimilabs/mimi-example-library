
/* 
Healthcare.gov MRF Data Analysis - Issuer Coverage by State
============================================================

Business Purpose:
This query analyzes the geographic distribution and submission patterns of Machine 
Readable Files (MRFs) across states and insurance issuers. This helps understand:
- Market coverage and issuer participation by state
- Data freshness and compliance through submission dates
- Contact availability for technical issues

The insights support decisions around:
- Network adequacy monitoring
- Issuer compliance tracking
- State-level market analysis
*/

-- Main Query
WITH issuer_metrics AS (
  -- Calculate key metrics per state
  SELECT 
    state,
    COUNT(DISTINCT issuer_id) as num_issuers,
    COUNT(DISTINCT url_submitted) as num_mrfs,
    MAX(mimi_src_file_date) as latest_submission,
    MIN(mimi_src_file_date) as earliest_submission,
    COUNT(DISTINCT tech_poc_email) as num_unique_contacts
  FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
  GROUP BY state
)

SELECT
  state,
  num_issuers,
  num_mrfs,
  latest_submission,
  earliest_submission,
  num_unique_contacts,
  -- Calculate days between earliest and latest submissions
  datediff(latest_submission, earliest_submission) as submission_span_days
FROM issuer_metrics
ORDER BY num_issuers DESC, state;

/*
How This Query Works:
--------------------
1. Creates a CTE to aggregate metrics by state
2. Calculates distinct counts of issuers, MRFs, and contacts
3. Identifies submission date ranges
4. Orders results by issuer count to highlight states with most market participation

Assumptions & Limitations:
-------------------------
- Assumes one MRF URL per issuer-state combination
- Does not account for MRF file validity or content
- Tech contacts may serve multiple issuers
- Date comparisons assume consistent timezone handling

Possible Extensions:
-------------------
1. Add time-based analysis:
   - Monthly submission patterns
   - Seasonal trends
   - Compliance with submission deadlines

2. Include issuer-level details:
   - Submission frequency by issuer
   - Contact domain analysis
   - URL pattern analysis

3. Add data quality metrics:
   - Missing contact information
   - Invalid URLs
   - Submission gaps

4. Geographic analysis:
   - Regional patterns
   - Multi-state issuer presence
   - Market concentration measures
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:14:44.318751
    - Additional Notes: Query provides state-level view of healthcare.gov issuer participation and MRF submission patterns. Results ordered by issuer count to highlight states with highest market participation. Date range calculations assume data within same timezone. For multi-region analysis, consider adding timezone handling.
    
    */