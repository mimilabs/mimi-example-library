-- Title: Provider Network Pricing Strategy Analysis
-- Business Purpose: Analyze negotiated rate patterns by billing class and arrangement type to:
-- - Identify dominant pricing models across provider networks
-- - Compare fee-for-service vs alternative payment arrangements 
-- - Support network optimization and contracting decisions
-- - Enable strategic planning for value-based care transitions

WITH pricing_models AS (
    -- Aggregate pricing arrangements by billing class
    SELECT 
        billing_class,
        negotiation_arrangement,
        negotiated_type,
        COUNT(*) as contract_count,
        AVG(negotiated_rate) as avg_rate,
        COUNT(DISTINCT provider_group_id) as provider_count,
        COUNT(DISTINCT reporting_entity_name) as payer_count
    FROM mimi_ws_1.payermrf.in_network_rates
    WHERE negotiated_rate IS NOT NULL
    AND billing_class IS NOT NULL 
    GROUP BY 1,2,3
),

arrangement_summary AS (
    -- Calculate percentages and rankings
    SELECT 
        billing_class,
        negotiation_arrangement,
        negotiated_type,
        contract_count,
        provider_count,
        payer_count,
        avg_rate,
        ROUND(100.0 * contract_count / SUM(contract_count) OVER 
            (PARTITION BY billing_class), 2) as pct_of_class,
        ROW_NUMBER() OVER (
            PARTITION BY billing_class 
            ORDER BY contract_count DESC
        ) as rank_in_class
    FROM pricing_models
)

SELECT 
    billing_class,
    negotiation_arrangement,
    negotiated_type,
    contract_count,
    provider_count,
    payer_count,
    ROUND(avg_rate, 2) as avg_negotiated_rate,
    pct_of_class as percent_of_billing_class
FROM arrangement_summary
WHERE rank_in_class <= 5
ORDER BY billing_class, contract_count DESC;

-- How it works:
-- 1. First CTE aggregates raw contract data by billing class and arrangement type
-- 2. Second CTE calculates market share percentages and rankings
-- 3. Final query filters to top 5 arrangements per billing class

-- Assumptions & Limitations:
-- - Assumes negotiated_rate values are comparable within billing classes
-- - Limited to arrangements with non-null negotiated rates
-- - May not capture full complexity of bundled/capitated arrangements
-- - Rankings based on contract count may differ from rankings by dollar value

-- Possible Extensions:
-- 1. Add temporal analysis to track shifts in payment models over time
-- 2. Include geographic segmentation to identify regional variation
-- 3. Analyze correlation between arrangement types and provider network size
-- 4. Compare negotiated rates across different arrangement types
-- 5. Add service_code analysis for professional services
-- 6. Create provider-level summaries of preferred payment models

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:18:50.029041
    - Additional Notes: Query provides strategic view of payment model adoption across provider networks, useful for network management and value-based care planning. Results group by billing class (professional/institutional) and show top 5 payment arrangements by volume. Best used for high-level strategic analysis rather than detailed rate comparisons.
    
    */