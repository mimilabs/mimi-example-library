
-- Out-of-Network Pricing Efficiency Analysis
-- Purpose: Identify high-variance medical services with significant pricing disparities 
-- across different provider types and reporting entities

WITH service_pricing_summary AS (
    -- Aggregate pricing data by billing code, provider type, and reporting entity
    SELECT 
        billing_code,
        name,
        billing_code_type,
        tin_type,
        reporting_entity_name,
        
        -- Calculate key pricing metrics
        COUNT(DISTINCT npi) AS unique_provider_count,
        ROUND(AVG(billed_charge), 2) AS avg_billed_charge,
        ROUND(AVG(allowed_amount), 2) AS avg_allowed_amount,
        
        -- Compute pricing variability metrics
        ROUND(STDDEV(allowed_amount), 2) AS allowed_amount_std_dev,
        ROUND(
            (MAX(allowed_amount) - MIN(allowed_amount)) / AVG(allowed_amount) * 100, 
            2
        ) AS price_range_percentage

    FROM mimi_ws_1.payermrf.allowed_amounts
    
    -- Focus on professional billing class for targeted analysis
    WHERE billing_class = 'professional'
    
    -- Group for comprehensive service-level insights
    GROUP BY 
        billing_code, 
        name, 
        billing_code_type, 
        tin_type, 
        reporting_entity_name
)

-- Identify services with highest pricing variability
SELECT 
    billing_code,
    name,
    billing_code_type,
    tin_type,
    reporting_entity_name,
    unique_provider_count,
    avg_billed_charge,
    avg_allowed_amount,
    allowed_amount_std_dev,
    price_range_percentage

FROM service_pricing_summary

-- Prioritize services with high price variability and multiple providers
WHERE 
    unique_provider_count > 20 AND 
    price_range_percentage > 50

-- Rank by most significant pricing disparities
ORDER BY price_range_percentage DESC
LIMIT 50;

/*
Query Mechanics:
- Aggregates out-of-network pricing data by service and provider type
- Calculates pricing variability using standard deviation and percentage range
- Identifies services with significant pricing inconsistencies

Key Business Insights:
- Highlights potential cost optimization opportunities
- Reveals pricing inefficiencies across different provider types
- Supports negotiation strategies for health plans and employers

Assumptions:
- Focuses on professional billing class services
- Requires minimum 20 unique providers to ensure statistical relevance
- Price range percentage > 50% indicates significant variability

Potential Extensions:
1. Add geographic filtering by analyzing service codes or plan market types
2. Compare pricing across different reporting entities
3. Develop predictive models for expected out-of-network pricing
*/


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:52:22.247404
    - Additional Notes: Query provides comprehensive analysis of out-of-network medical service pricing variability, focusing on professional billing class with high provider diversity and price range discrepancies.
    
    */