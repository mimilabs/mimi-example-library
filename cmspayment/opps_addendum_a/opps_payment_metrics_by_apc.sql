
/*******************************************************************************
Title: OPPS Payment Analysis - Core Payment Metrics by APC Group
 
Business Purpose:
This query analyzes key payment metrics from the OPPS Addendum A table to provide
insights into Medicare outpatient reimbursement rates and beneficiary cost sharing
across different ambulatory payment classification (APC) groups. This information
is valuable for:
- Hospital financial planning and revenue cycle management
- Understanding patient out-of-pocket costs
- Analyzing Medicare payment policies and trends
*******************************************************************************/

-- Main query to analyze payment metrics by APC group
WITH latest_data AS (
    -- Get most recent data snapshot
    SELECT MAX(mimi_src_file_date) as max_date
    FROM mimi_ws_1.cmspayment.opps_addendum_a
)

SELECT 
    -- Key identifiers
    a.apc,
    a.group_title,
    a.status_indicator,
    
    -- Payment metrics
    a.relative_weight,
    ROUND(a.payment_rate, 2) as payment_rate,
    ROUND(a.national_unadjusted_copayment, 2) as copayment,
    
    -- Calculate Medicare portion vs beneficiary responsibility
    ROUND(a.payment_rate - a.national_unadjusted_copayment, 2) as medicare_portion,
    ROUND(100 * a.national_unadjusted_copayment / NULLIF(a.payment_rate, 0), 1) 
        as beneficiary_share_pct,
        
    -- Note any special conditions
    a.note

FROM mimi_ws_1.cmspayment.opps_addendum_a a
INNER JOIN latest_data l 
    ON a.mimi_src_file_date = l.max_date

-- Filter for active payment classifications
WHERE a.status_indicator IN ('S','T','V','J1','J2') 
  AND a.payment_rate > 0

-- Order by payment rate to show highest impact APCs first  
ORDER BY a.payment_rate DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Identifies the most recent data snapshot using mimi_src_file_date
2. Pulls key payment and cost sharing metrics for each APC
3. Calculates Medicare vs beneficiary payment portions
4. Filters for active payment status indicators and positive payment rates
5. Orders results by payment rate to highlight highest-cost services

Assumptions and Limitations:
- Focuses only on active payment status indicators (S,T,V,J1,J2)
- Uses national unadjusted rates (actual payments may vary by geography)
- Limited to top 100 APCs by payment rate
- Does not account for multiple procedure discounting
- Based on snapshot data that may not reflect current rates

Possible Extensions:
1. Add year-over-year payment rate comparisons
2. Include geographic payment adjustments
3. Analyze patterns by clinical service categories
4. Add volume/utilization data if available
5. Expand to include packaged services analysis
6. Compare cost sharing across different types of services
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:07:47.169159
    - Additional Notes: Query extracts most recent OPPS payment data and focuses on active payment classifications (status indicators S,T,V,J1,J2) with positive payment rates. Results are limited to top 100 APCs by payment rate, which may need adjustment based on specific analysis needs. Consider memory usage when removing the LIMIT clause for large datasets.
    
    */