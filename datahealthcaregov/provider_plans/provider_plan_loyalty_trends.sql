-- Provider Plan Coverage Trends Analysis
--
-- Business Purpose:
-- - Track temporal changes in provider-plan relationships to identify network stability
-- - Monitor provider participation patterns across plan years
-- - Support strategic network development and retention initiatives
-- - Identify potential network gaps or churn patterns

WITH yearly_coverage AS (
    -- Get provider coverage by year, filtering to recent data
    SELECT 
        CAST(years[0] as INT) as year,  -- Extract first year from array
        provider_type,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT plan_id) as contracted_plans,
        COUNT(*) as total_relationships
    FROM mimi_ws_1.datahealthcaregov.provider_plans
    WHERE CAST(years[0] as INT) >= 2020  -- Compare integer year value
    GROUP BY CAST(years[0] as INT), provider_type
),

provider_loyalty AS (
    -- Calculate providers with consistent plan participation
    SELECT 
        npi,
        provider_type,
        COUNT(DISTINCT years[0]) as years_active,
        COUNT(DISTINCT plan_id) as total_plans
    FROM mimi_ws_1.datahealthcaregov.provider_plans
    GROUP BY npi, provider_type
    HAVING COUNT(DISTINCT years[0]) >= 2
)

SELECT 
    yc.year,
    yc.provider_type,
    yc.provider_count,
    yc.contracted_plans,
    yc.total_relationships,
    COUNT(DISTINCT pl.npi) as loyal_providers,
    ROUND(COUNT(DISTINCT pl.npi) * 100.0 / yc.provider_count, 2) as loyalty_rate
FROM yearly_coverage yc
LEFT JOIN provider_loyalty pl 
    ON yc.provider_type = pl.provider_type
GROUP BY 
    yc.year,
    yc.provider_type,
    yc.provider_count,
    yc.contracted_plans,
    yc.total_relationships
ORDER BY 
    yc.year DESC,
    yc.provider_count DESC;

-- How this query works:
-- 1. yearly_coverage CTE summarizes provider and plan counts by year
-- 2. provider_loyalty CTE identifies providers maintaining consistent participation
-- 3. Main query combines these metrics to show coverage trends and loyalty rates
--
-- Assumptions:
-- - Years field is an array containing valid year values
-- - First element of years array represents the primary year
-- - NPI and plan_id are reliable identifiers
-- - Provider participation spans are continuous within years listed
--
-- Limitations:
-- - Only considers the first year in the years array
-- - Does not account for mid-year changes
-- - Cannot detect quality of provider-plan relationships
-- - May not reflect complete market coverage
--
-- Possible Extensions:
-- 1. Add geographic dimension for regional trend analysis
-- 2. Include network tier distribution changes over time
-- 3. Add seasonality analysis for enrollment periods
-- 4. Compare against market benchmarks if available
-- 5. Add provider specialty analysis for targeted retention strategies

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:38:53.314303
    - Additional Notes: Query assumes years field is an array and uses first element [0] for year calculations. Consider network composition over time and helps identify provider retention patterns. Best used for year-over-year trend analysis of provider participation and loyalty metrics across different provider types.
    
    */