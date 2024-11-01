-- Title: Network Rate Trend Analysis by Reporting Entity and Service Type
-- Business Purpose: 
-- - Track negotiated rate trends across reporting entities and service types
-- - Identify potential cost savings opportunities and pricing anomalies
-- - Support strategic contract negotiations with data-driven insights
-- - Enable comparative analysis of pricing strategies across payers

WITH reporting_entity_summary AS (
    -- Get average rates and service counts by reporting entity and billing class
    SELECT 
        reporting_entity_name,
        billing_class,
        COUNT(DISTINCT billing_code) as unique_services,
        AVG(negotiated_rate) as avg_rate,
        PERCENTILE(negotiated_rate, 0.5) as median_rate,
        MIN(negotiated_rate) as min_rate,
        MAX(negotiated_rate) as max_rate
    FROM mimi_ws_1.payermrf.in_network_rates
    WHERE 
        negotiated_rate IS NOT NULL 
        AND negotiated_type = 'negotiated'  -- Focus on directly negotiated rates
        AND billing_class IN ('professional', 'institutional')  -- Exclude 'both' to avoid duplication
    GROUP BY 
        reporting_entity_name,
        billing_class
),

rate_volatility AS (
    -- Calculate rate spread and volatility metrics
    SELECT 
        reporting_entity_name,
        billing_class,
        unique_services,
        avg_rate,
        median_rate,
        (max_rate - min_rate) as rate_spread,
        ((max_rate - min_rate) / NULLIF(median_rate, 0)) * 100 as rate_volatility_pct
    FROM reporting_entity_summary
)

SELECT 
    reporting_entity_name,
    billing_class,
    unique_services,
    ROUND(avg_rate, 2) as avg_negotiated_rate,
    ROUND(median_rate, 2) as median_negotiated_rate,
    ROUND(rate_spread, 2) as rate_spread,
    ROUND(rate_volatility_pct, 1) as rate_volatility_pct,
    -- Add comparative ranking
    RANK() OVER (PARTITION BY billing_class ORDER BY avg_rate DESC) as price_rank
FROM rate_volatility
ORDER BY 
    billing_class,
    avg_negotiated_rate DESC;

-- How the Query Works:
-- 1. First CTE aggregates basic statistics by reporting entity and billing class
-- 2. Second CTE calculates volatility metrics to identify pricing consistency
-- 3. Final query adds rankings and formats output for business analysis
-- 4. Results show pricing patterns across payers with focus on variability

-- Assumptions and Limitations:
-- - Focuses only on negotiated rates (excludes derived, fee schedule, etc.)
-- - Assumes rates are comparable across entities without adjusting for geography
-- - Does not account for service complexity or volume
-- - Limited to professional and institutional billing classes

-- Possible Extensions:
-- 1. Add temporal analysis by incorporating mimi_src_file_date
-- 2. Include service_code analysis for professional services
-- 3. Add geographic segmentation based on provider reference data
-- 4. Incorporate negotiation_arrangement analysis
-- 5. Compare rates against Medicare fee schedules where available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:24:37.433057
    - Additional Notes: Query focuses on rate variability across payers while excluding derived and fee schedule rates. Helps identify pricing inconsistencies and potential negotiation opportunities. Best used with at least 3 months of historical data for meaningful volatility metrics.
    
    */