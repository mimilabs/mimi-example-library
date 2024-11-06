-- File: drug_recall_product_risk_profile.sql
-- Title: Drug Recall Product Risk and Distribution Analysis

/* 
Business Purpose:
- Develop a comprehensive risk profile for drug products based on recall characteristics
- Identify high-risk product categories and distribution patterns
- Support strategic decision-making for pharmaceutical quality management
- Provide insights for regulatory compliance and risk mitigation strategies

Key Analytical Objectives:
1. Characterize recall risks by product type and distribution
2. Assess severity and frequency of drug quality issues
3. Enable proactive quality control measures
*/

WITH RecallRiskProfile AS (
    SELECT 
        product_description,
        classification,
        -- Aggregate key risk metrics
        COUNT(*) AS total_recalls,
        COUNT(DISTINCT recalling_firm) AS unique_firms_involved,
        
        -- Distribution risk assessment
        CASE 
            WHEN distribution_pattern LIKE '%nationwide%' THEN 'High'
            WHEN distribution_pattern LIKE '%states%' THEN 'Medium'
            ELSE 'Low'
        END AS distribution_risk,
        
        -- Recall severity scoring
        SUM(CASE WHEN classification = 'I' THEN 1 ELSE 0 END) AS class_i_recalls,
        SUM(CASE WHEN classification = 'II' THEN 1 ELSE 0 END) AS class_ii_recalls,
        SUM(CASE WHEN classification = 'III' THEN 1 ELSE 0 END) AS class_iii_recalls,
        
        -- Voluntary vs Mandated Risk
        SUM(CASE WHEN voluntary_mandated = 'Voluntary' THEN 1 ELSE 0 END) AS voluntary_recalls,
        SUM(CASE WHEN voluntary_mandated = 'Mandated' THEN 1 ELSE 0 END) AS mandated_recalls,
        
        -- Temporal risk indicators
        MIN(report_date) AS earliest_recall,
        MAX(report_date) AS latest_recall,
        AVG(product_quantity) AS avg_recall_quantity
    
    FROM mimi_ws_1.fda.enforcement
    
    -- Focus on active drug recalls
    WHERE product_type = 'Drugs' 
      AND status = 'Ongoing'
    
    GROUP BY 
        product_description, 
        classification,
        CASE 
            WHEN distribution_pattern LIKE '%nationwide%' THEN 'High'
            WHEN distribution_pattern LIKE '%states%' THEN 'Medium'
            ELSE 'Low'
        END
)

SELECT 
    product_description,
    classification,
    distribution_risk,
    total_recalls,
    unique_firms_involved,
    class_i_recalls,
    class_ii_recalls,
    class_iii_recalls,
    voluntary_recalls,
    mandated_recalls,
    earliest_recall,
    latest_recall,
    avg_recall_quantity,
    
    -- Risk scoring mechanism
    CASE 
        WHEN (class_i_recalls > 0 OR class_ii_recalls > 2) THEN 'High Risk'
        WHEN class_ii_recalls > 0 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS overall_risk_level

FROM RecallRiskProfile
ORDER BY 
    overall_risk_level, 
    total_recalls DESC
LIMIT 100;

/*
Query Mechanics:
- Aggregates drug recall data with multi-dimensional risk analysis
- Creates risk profile by product description
- Generates risk scoring based on recall classification and frequency

Assumptions and Limitations:
- Relies on ongoing recalls only
- Uses current snapshot of FDA enforcement data
- Risk scoring is a simplified heuristic approach

Potential Extensions:
1. Add time-series trend analysis
2. Incorporate geographical risk dimensions
3. Develop predictive risk models
4. Integrate with manufacturer compliance metrics
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T20:56:14.273815
    - Additional Notes: Provides a comprehensive risk assessment of drug recalls by analyzing classification, distribution patterns, and recall characteristics. Focuses on ongoing drug recalls and generates a multi-dimensional risk scoring mechanism.
    
    */