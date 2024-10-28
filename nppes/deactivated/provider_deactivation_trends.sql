
/*******************************************************************************
Title: Provider Deactivation Analysis - Basic Metrics and Trends
 
Business Purpose:
- Monitor healthcare provider deactivation patterns to identify potential risks
- Track the volume and timing of NPI deactivations for compliance monitoring
- Provide foundation for deeper investigation of provider exits from healthcare system
*******************************************************************************/

-- Calculate key metrics around NPI deactivations
WITH deactivation_metrics AS (
  SELECT 
    -- Get year and month of deactivation for trend analysis
    DATE_TRUNC('month', deactivation_date) AS deactivation_month,
    
    -- Count deactivations
    COUNT(DISTINCT npi) AS deactivated_npis,
    
    -- Calculate days since deactivation 
    AVG(DATEDIFF(CURRENT_DATE(), deactivation_date)) AS avg_days_since_deactivation
    
  FROM mimi_ws_1.nppes.deactivated
  WHERE deactivation_date IS NOT NULL
  GROUP BY DATE_TRUNC('month', deactivation_date)
)

SELECT
  deactivation_month,
  deactivated_npis,
  avg_days_since_deactivation,
  
  -- Calculate month-over-month change
  LAG(deactivated_npis) OVER (ORDER BY deactivation_month) AS prev_month_deactivations,
  
  -- Calculate percentage change
  ROUND(
    ((deactivated_npis - LAG(deactivated_npis) OVER (ORDER BY deactivation_month)) * 100.0 / 
    NULLIF(LAG(deactivated_npis) OVER (ORDER BY deactivation_month), 0)), 1
  ) AS pct_change_from_prev_month

FROM deactivation_metrics
ORDER BY deactivation_month DESC;

/*******************************************************************************
How This Query Works:
1. Groups deactivations by month to show temporal patterns
2. Calculates key metrics: count of deactivations and average time since deactivation
3. Adds month-over-month comparison to identify unusual spikes
4. Orders results by most recent first for easy monitoring

Assumptions & Limitations:
- Assumes deactivation_date is the primary indicator of when providers exit
- Does not account for potential data lag in reporting deactivations
- Month-over-month comparisons may be affected by seasonal patterns
- Does not include reason for deactivation (requires OIG data link)

Possible Extensions:
1. Add geographic analysis by joining with provider location data
2. Include provider specialty/type analysis
3. Add year-over-year comparisons
4. Link to OIG exclusions to analyze deactivation reasons
5. Create moving averages to smooth seasonal variations
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:47:22.398349
    - Additional Notes: Query focuses on month-over-month trends in provider deactivations. Results are most meaningful when analyzing at least 12 months of data to account for seasonal patterns. The percentage change calculation may return null values for months with zero prior deactivations.
    
    */