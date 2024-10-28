
/*******************************************************************************
Title: Top Payment Patterns Analysis in Healthcare Industry
 
Business Purpose:
This query analyzes the core payment patterns between healthcare manufacturers/GPOs
and recipients (physicians, teaching hospitals) to understand:
- Total payment amounts and frequencies by payment type
- Top payment recipients and payers
- Geographic distribution of payments
This provides insights into financial relationships in healthcare industry.
*******************************************************************************/

WITH payment_summary AS (
  -- Aggregate payments by nature and form
  SELECT 
    nature_of_payment_or_transfer_of_value,
    form_of_payment_or_transfer_of_value,
    covered_recipient_type,
    recipient_state,
    COUNT(*) as payment_count,
    SUM(total_amount_of_payment_us_dollars) as total_payment_amount,
    AVG(total_amount_of_payment_us_dollars) as avg_payment_amount
  FROM mimi_ws_1.openpayments.general
  WHERE program_year >= 2020 -- Focus on recent years
  GROUP BY 1,2,3,4
),

top_recipients AS (
  -- Identify top payment recipients
  SELECT
    CASE 
      WHEN covered_recipient_type = 'Covered Recipient Teaching Hospital' 
        THEN teaching_hospital_name
      ELSE CONCAT(covered_recipient_first_name, ' ', covered_recipient_last_name)
    END as recipient_name,
    covered_recipient_type,
    recipient_state,
    COUNT(*) as payment_count,
    SUM(total_amount_of_payment_us_dollars) as total_received
  FROM mimi_ws_1.openpayments.general 
  WHERE program_year >= 2020
  GROUP BY 1,2,3
  HAVING total_received > 100000 -- Focus on significant payments
)

-- Main summary output
SELECT
  ps.nature_of_payment_or_transfer_of_value,
  ps.form_of_payment_or_transfer_of_value,
  ps.covered_recipient_type,
  ps.recipient_state,
  ps.payment_count,
  ROUND(ps.total_payment_amount,2) as total_payment_amount,
  ROUND(ps.avg_payment_amount,2) as avg_payment_amount,
  COUNT(tr.recipient_name) as high_value_recipients
FROM payment_summary ps
LEFT JOIN top_recipients tr
  ON ps.covered_recipient_type = tr.covered_recipient_type
  AND ps.recipient_state = tr.recipient_state
GROUP BY 1,2,3,4,5,6,7
HAVING total_payment_amount > 10000
ORDER BY total_payment_amount DESC
LIMIT 100;

/*******************************************************************************
How this query works:
1. Creates a payment_summary CTE that aggregates payments by nature, form, 
   recipient type and state
2. Creates a top_recipients CTE that identifies recipients receiving >$100k
3. Joins these to produce a comprehensive payment pattern analysis

Assumptions & Limitations:
- Focuses on payments from 2020 onwards for recent trends
- Only includes payments >$10k in final output for significance
- Recipient names may have inconsistencies in source data
- Does not account for disputed payments or delayed publications

Possible Extensions:
1. Add time-based trending analysis by program_year
2. Include product-specific payment analysis using associated product fields
3. Add geographic clustering analysis using recipient location data
4. Compare payment patterns between different manufacturer types
5. Analyze correlation between payment amounts and specialty/recipient type
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:02:05.770285
    - Additional Notes: Query focuses on significant payments (>$10k total, >$100k for top recipients) from 2020 onwards. Results show payment patterns by type, form, and geography. Memory usage may be high for large datasets due to multiple aggregations and joins. Consider adding WHERE clauses for specific states or payment types if analyzing targeted segments.
    
    */