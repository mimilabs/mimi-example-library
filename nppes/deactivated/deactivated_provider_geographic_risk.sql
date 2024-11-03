-- Title: Geographic Concentration Analysis of Deactivated Providers

-- Business Purpose:
-- - Identify geographic hotspots of provider deactivations to support targeted compliance reviews
-- - Enable regional risk assessment and resource allocation for compliance teams
-- - Support strategic decisions for provider network management
-- - Aid in detecting potential regional patterns of healthcare fraud

WITH yearly_deactivations AS (
    -- Get the first two digits of NPI which represent geographic region
    SELECT 
        LEFT(npi, 2) as npi_region,
        YEAR(deactivation_date) as deactivation_year,
        COUNT(*) as deactivation_count
    FROM mimi_ws_1.nppes.deactivated
    WHERE deactivation_date >= '2019-01-01'  -- Focus on recent 5 years
    GROUP BY 1, 2
),

region_metrics AS (
    -- Calculate metrics for each region
    SELECT 
        npi_region,
        SUM(deactivation_count) as total_deactivations,
        AVG(deactivation_count) as avg_yearly_deactivations,
        MAX(deactivation_count) as max_yearly_deactivations,
        MIN(deactivation_count) as min_yearly_deactivations
    FROM yearly_deactivations
    GROUP BY 1
)

-- Final output with risk categorization
SELECT 
    npi_region,
    total_deactivations,
    ROUND(avg_yearly_deactivations, 2) as avg_yearly_deactivations,
    max_yearly_deactivations,
    min_yearly_deactivations,
    CASE 
        WHEN avg_yearly_deactivations > (SELECT AVG(avg_yearly_deactivations) * 1.5 FROM region_metrics)
        THEN 'High Risk'
        WHEN avg_yearly_deactivations > (SELECT AVG(avg_yearly_deactivations) FROM region_metrics)
        THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as risk_category
FROM region_metrics
ORDER BY total_deactivations DESC
LIMIT 20;

-- How it works:
-- 1. First CTE extracts geographic region from NPI and aggregates yearly deactivations
-- 2. Second CTE calculates key metrics for each region
-- 3. Final query adds risk categorization based on deviation from average
--
-- Assumptions and Limitations:
-- - NPI first two digits reliably indicate geographic region
-- - Recent 5 years of data provides meaningful patterns
-- - Simple threshold-based risk categorization may need refinement
-- - Does not account for total provider population in each region
--
-- Possible Extensions:
-- 1. Add provider density normalization using total active providers
-- 2. Include month-over-month change analysis
-- 3. Correlate with demographic or economic indicators
-- 4. Add specialty-specific analysis within regions
-- 5. Create time-based risk trending by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:58:47.375346
    - Additional Notes: Query relies on the first two digits of NPI numbers for geographic classification. For accurate regional assessment, consider validating NPI geographic assignments against a reference table or documentation. Performance may be impacted with very large datasets due to window functions in risk calculations.
    
    */