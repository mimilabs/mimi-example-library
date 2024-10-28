
/*************************************************************************
RESEARCH PAYMENTS ANALYSIS - TOP RECIPIENTS AND PAYMENT TRENDS
-------------------------------------------------------------------------
This query analyzes the key patterns in research payments between medical 
manufacturers/GPOs and healthcare providers/institutions to understand:
- Who are the top payment recipients
- Total payment values and trends
- Most common research contexts

Business value:
- Identify major research funding relationships
- Track research investment patterns
- Enable compliance monitoring
*************************************************************************/

WITH payment_recipients AS (
  -- Consolidate recipient details and payment amounts
  SELECT
    COALESCE(teaching_hospital_name, 
             noncovered_recipient_entity_name,
             CONCAT(covered_recipient_first_name, ' ', covered_recipient_last_name)) AS recipient_name,
    covered_recipient_type,
    recipient_state,
    name_of_study,
    context_of_research,
    total_amount_of_payment_us_dollars,
    program_year,
    date_of_payment,
    submitting_applicable_manufacturer_or_applicable_gpo_name AS manufacturer_name
  FROM mimi_ws_1.openpayments.research
  WHERE total_amount_of_payment_us_dollars > 0
)

SELECT
  -- Key dimensions of the payment 
  recipient_name,
  covered_recipient_type,
  recipient_state,
  
  -- Payment statistics
  COUNT(*) as payment_count,
  SUM(total_amount_of_payment_us_dollars) as total_payment_amount,
  AVG(total_amount_of_payment_us_dollars) as avg_payment_amount,
  
  -- Research context
  CONCAT_WS('; ', COLLECT_SET(context_of_research)) as research_contexts,
  COUNT(DISTINCT manufacturer_name) as unique_manufacturers
  
FROM payment_recipients
WHERE program_year >= 2020  -- Focus on recent years
GROUP BY 1,2,3

-- Focus on significant research relationships
HAVING COUNT(*) >= 5
AND SUM(total_amount_of_payment_us_dollars) >= 100000

ORDER BY total_payment_amount DESC
LIMIT 100;

/*************************************************************************
HOW THIS QUERY WORKS:
-------------------------------------------------------------------------
1. CTE consolidates recipient information from different recipient types 
   (hospitals, entities, individuals)
2. Main query aggregates payments by recipient with key metrics
3. Filters ensure focus on significant research relationships
4. Results show top recipients by total payment amount

ASSUMPTIONS & LIMITATIONS:
-------------------------------------------------------------------------
- Assumes payment amounts are normalized to USD
- Limited to recipients with 5+ payments and $100k+ total
- Manufacturer names may have variations affecting unique count
- Only shows top 100 recipients
- Research contexts concatenated with semicolon separator

POSSIBLE EXTENSIONS:
-------------------------------------------------------------------------
1. Add time-based trending analysis
2. Include product/therapeutic area breakdown
3. Add geographic analysis by state/region
4. Compare payment patterns across different manufacturer types
5. Analyze research context categories and patterns
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:11:41.917794
    - Additional Notes: Query aggregates research payments from CMS Open Payments data to identify top recipients by total payment amount. Filters for significant relationships (>=$100k total, >=5 payments) since 2020. Concatenates research contexts using CONCAT_WS and COLLECT_SET for deduplication. Output limited to top 100 recipients by payment amount.
    
    */