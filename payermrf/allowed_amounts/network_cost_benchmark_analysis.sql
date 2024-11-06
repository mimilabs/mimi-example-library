-- Network Utilization and Cost Comparison Analysis
-- Purpose: Analyze the relationship between network utilization and cost differentials
-- to identify potential cost management opportunities and network optimization strategies.

WITH provider_cost_metrics AS (
    -- Calculate key cost metrics by provider and service
    SELECT 
        npi,
        billing_code,
        billing_code_type,
        name as service_name,
        COUNT(*) as claim_volume,
        AVG(billed_charge) as avg_billed,
        AVG(allowed_amount) as avg_allowed,
        AVG(billed_charge - allowed_amount) as avg_difference
    FROM mimi_ws_1.payermrf.allowed_amounts
    WHERE billed_charge > 0 
      AND allowed_amount > 0
    GROUP BY 1,2,3,4
    HAVING COUNT(*) >= 20  -- Ensure statistical significance
),

service_benchmarks AS (
    -- Calculate service-level benchmarks
    SELECT 
        billing_code,
        billing_code_type,
        service_name,
        AVG(avg_billed) as benchmark_billed,
        AVG(avg_allowed) as benchmark_allowed,
        SUM(claim_volume) as total_claims
    FROM provider_cost_metrics
    GROUP BY 1,2,3
)

-- Final output combining provider metrics with benchmarks
SELECT 
    p.billing_code,
    p.service_name,
    COUNT(DISTINCT p.npi) as provider_count,
    b.total_claims,
    ROUND(AVG(p.avg_billed), 2) as avg_billed_charge,
    ROUND(b.benchmark_allowed, 2) as benchmark_allowed,
    ROUND(((AVG(p.avg_billed) - b.benchmark_allowed) / b.benchmark_allowed) * 100, 1) as pct_above_benchmark,
    ROUND(AVG(p.avg_difference), 2) as avg_cost_differential
FROM provider_cost_metrics p
JOIN service_benchmarks b 
    ON p.billing_code = b.billing_code 
    AND p.billing_code_type = b.billing_code_type
GROUP BY 1,2,b.total_claims,b.benchmark_allowed
HAVING provider_count >= 5  -- Focus on commonly performed services
ORDER BY total_claims DESC, pct_above_benchmark DESC
LIMIT 50;

/* How this query works:
1. First CTE calculates provider-level metrics for each service
2. Second CTE establishes market benchmarks for each service
3. Final query combines the data to show opportunities for network optimization

Assumptions and limitations:
- Requires minimum volume thresholds for statistical validity
- Assumes billed and allowed amounts are properly recorded
- Limited to services with multiple providers for comparison
- Does not account for geographic variations

Possible extensions:
1. Add geographic segmentation using NPI registry data
2. Include temporal trending to show pricing evolution
3. Add specialty-specific analysis using provider taxonomy
4. Incorporate quality metrics for value-based analysis
5. Expand to include payer-specific benchmarking
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:09:37.651900
    - Additional Notes: Query provides comprehensive cost benchmarking across providers and services with built-in volume thresholds (20+ claims per provider, 5+ providers per service) to ensure statistical reliability. Results are most useful for network management and contract negotiations teams. Recommend running with current quarter's data for most relevant insights.
    
    */