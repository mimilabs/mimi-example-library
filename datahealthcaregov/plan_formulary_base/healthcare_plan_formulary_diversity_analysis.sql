-- plan_formulary_pharmacy_diversity_analysis.sql
-- Business Purpose: Analyze healthcare plan formulary diversity and pharmacy access strategies
-- Provides insights into how health plans structure drug coverage across different pharmacy networks and cost-sharing models

WITH pharmacy_diversity_metrics AS (
    -- Aggregate formulary characteristics by plan, focusing on pharmacy and cost-sharing diversity
    SELECT 
        plan_id,
        plan_id_type,
        COUNT(DISTINCT pharmacy_type) AS unique_pharmacy_types,
        COUNT(DISTINCT drug_tier) AS unique_drug_tiers,
        
        -- Analyze cost-sharing complexity
        SUM(CASE WHEN coinsurance_opt = 'Yes' THEN 1 ELSE 0 END) AS coinsurance_drug_count,
        SUM(CASE WHEN copay_opt = 'Yes' THEN 1 ELSE 0 END) AS copay_drug_count,
        
        -- Mail order availability
        SUM(CASE WHEN mail_order = 'Yes' THEN 1 ELSE 0 END) AS mail_order_drug_count,
        
        -- Average cost-sharing metrics
        AVG(COALESCE(coinsurance_rate, 0)) AS avg_coinsurance_rate,
        AVG(COALESCE(copay_amount, 0)) AS avg_copay_amount,
        
        MAX(last_updated_on) AS formulary_last_updated
    FROM 
        mimi_ws_1.datahealthcaregov.plan_formulary_base
    GROUP BY 
        plan_id, 
        plan_id_type
)

SELECT 
    plan_id_type,
    COUNT(DISTINCT plan_id) AS total_plans,
    
    -- Pharmacy Network Diversity Metrics
    ROUND(AVG(unique_pharmacy_types), 2) AS avg_pharmacy_type_diversity,
    ROUND(AVG(unique_drug_tiers), 2) AS avg_drug_tier_complexity,
    
    -- Cost-Sharing Strategy Insights
    ROUND(AVG(coinsurance_drug_count * 1.0 / (coinsurance_drug_count + copay_drug_count)), 2) AS pct_plans_using_coinsurance,
    ROUND(AVG(mail_order_drug_count * 1.0 / unique_drug_tiers), 2) AS mail_order_coverage_ratio,
    
    -- Financial Metrics
    ROUND(AVG(avg_coinsurance_rate), 2) AS mean_coinsurance_rate,
    ROUND(AVG(avg_copay_amount), 2) AS mean_copay_amount,
    
    MIN(formulary_last_updated) AS earliest_formulary_update,
    MAX(formulary_last_updated) AS latest_formulary_update
FROM 
    pharmacy_diversity_metrics
GROUP BY 
    plan_id_type
ORDER BY 
    total_plans DESC;

/* 
Query Mechanics:
- Uses Common Table Expression (CTE) to first aggregate plan-level formulary characteristics
- Calculates metrics around pharmacy type diversity, drug tier complexity, and cost-sharing strategies
- Provides summary statistics grouped by plan identifier type

Assumptions & Limitations:
- Assumes data represents a complete snapshot of formulary information
- Does not account for temporal changes in formulary design
- Metrics are aggregate and may obscure individual plan variations

Potential Extensions:
1. Incorporate metal tier classification for more granular analysis
2. Add therapeutic area / drug class dimension
3. Compare cost-sharing strategies across different plan types
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:43:35.367317
    - Additional Notes: Provides comprehensive analysis of pharmacy network and cost-sharing strategies across health insurance plans. Aggregates metrics at plan identifier type level, offering insights into formulary design complexity.
    
    */