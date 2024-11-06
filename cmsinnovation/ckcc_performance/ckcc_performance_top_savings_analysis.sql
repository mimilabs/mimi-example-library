-- CKCC/KCF Performance Analysis: Organizational Insights and Savings Potential

/*
Business Purpose:
Analyze Comprehensive Kidney Care Contracting (CKCC) and Kidney Care First (KCF) 
performance metrics to identify top-performing organizations, potential cost savings, 
and strategic opportunities in kidney care management.
*/

WITH EntityPerformanceSummary AS (
    SELECT 
        entity_legal_business_name,
        entity_type,
        agreement_option,
        presence_in_states,
        
        -- Key Performance Metrics
        ROUND(AVG(average_risk_score_ckd_esrd), 2) AS avg_risk_score,
        SUM(beneficiary_count_ckd_esrd) AS total_beneficiaries,
        
        -- Financial Performance Indicators
        ROUND(SUM(gross_shared_savings_losses_ckd_esrd), 2) AS total_gross_savings,
        ROUND(SUM(net_shared_savings_losses_ckd_esrd), 2) AS total_net_savings,
        ROUND(AVG(total_quality_score), 2) AS avg_quality_score,
        
        -- Cost Efficiency Metrics
        ROUND(SUM(performance_year_expenditure_ckd_esrd), 2) AS total_expenditure,
        ROUND(100 * SUM(net_shared_savings_losses_ckd_esrd) / 
              NULLIF(SUM(performance_year_expenditure_ckd_esrd), 0), 2) AS savings_percentage,
        
        -- Performance Date Context
        MAX(performance_date_end) AS latest_performance_period

    FROM 
        mimi_ws_1.cmsinnovation.ckcc_performance
    
    -- Focus on organizations with meaningful data
    WHERE 
        beneficiary_count_ckd_esrd > 0
        AND performance_year_expenditure_ckd_esrd > 0
    
    GROUP BY 
        entity_legal_business_name,
        entity_type,
        agreement_option,
        presence_in_states
)

SELECT 
    entity_legal_business_name,
    entity_type,
    agreement_option,
    total_beneficiaries,
    avg_risk_score,
    total_gross_savings,
    total_net_savings,
    savings_percentage,
    avg_quality_score,
    latest_performance_period

FROM 
    EntityPerformanceSummary

WHERE 
    total_net_savings > 0  -- Focus on organizations with positive net savings
    AND savings_percentage > 5  -- Significant savings threshold

ORDER BY 
    savings_percentage DESC, 
    total_net_savings DESC
LIMIT 25;

/*
Query Mechanics:
- Creates a CTE to aggregate performance metrics by organization
- Calculates key financial and quality indicators
- Filters for meaningful, positive-performing entities
- Ranks organizations by savings potential

Assumptions and Limitations:
- Assumes data represents complete performance periods
- Uses net savings as primary performance indicator
- Limited to top 25 performers

Potential Extensions:
1. Add geographic analysis by presence_in_states
2. Compare performance across different agreement options
3. Create trend analysis by including multiple performance periods
4. Develop risk-adjusted performance scoring
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:04:39.303833
    - Additional Notes: Query focuses on identifying top-performing kidney care organizations with positive net savings. Provides insights into organizational efficiency, quality scores, and financial performance in CMS kidney care models.
    
    */