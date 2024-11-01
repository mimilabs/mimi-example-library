-- outpatient_service_growth_trends.sql

-- Business Purpose:
-- Analyzes year-over-year growth trends in Medicare outpatient hospital services
-- Identifies rapidly growing or declining service categories
-- Helps healthcare organizations understand changing utilization patterns
-- Supports strategic planning and capacity management decisions

WITH base_metrics AS (
    -- Calculate key metrics by APC and year
    SELECT 
        YEAR(mimi_src_file_date) as service_year,
        apc_cd,
        apc_desc,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        AVG(avg_mdcr_pymt_amt) as avg_medicare_payment,
        COUNT(DISTINCT rndrng_prvdr_ccn) as provider_count
    FROM mimi_ws_1.datacmsgov.mupohp
    WHERE mimi_src_file_date >= '2021-12-31'
    GROUP BY 1, 2, 3
),

year_over_year AS (
    -- Calculate year-over-year changes
    SELECT 
        curr.service_year,
        curr.apc_cd,
        curr.apc_desc,
        curr.total_beneficiaries,
        curr.total_services,
        curr.avg_medicare_payment,
        curr.provider_count,
        ROUND(100.0 * (curr.total_services - prev.total_services) / prev.total_services, 1) as service_growth_pct,
        ROUND(100.0 * (curr.provider_count - prev.provider_count) / prev.provider_count, 1) as provider_growth_pct
    FROM base_metrics curr
    LEFT JOIN base_metrics prev 
        ON curr.apc_cd = prev.apc_cd 
        AND curr.service_year = prev.service_year + 1
)

-- Present top growing services with significant volume
SELECT 
    service_year,
    apc_cd,
    apc_desc,
    total_services,
    provider_count,
    service_growth_pct,
    provider_growth_pct,
    avg_medicare_payment
FROM year_over_year
WHERE total_services >= 1000  -- Focus on services with meaningful volume
    AND service_growth_pct IS NOT NULL  -- Exclude first year where growth can't be calculated
ORDER BY service_growth_pct DESC
LIMIT 20;

-- How this works:
-- 1. First CTE aggregates key metrics by APC code and year
-- 2. Second CTE calculates year-over-year growth rates
-- 3. Final query filters for significant services and ranks by growth rate

-- Assumptions and limitations:
-- - Requires at least 2 years of data for meaningful growth analysis
-- - Growth rates may be affected by changes in coding practices
-- - Does not account for seasonality or regional variations
-- - Minimum volume threshold of 1000 services may need adjustment based on specific analysis needs

-- Possible extensions:
-- 1. Add regional breakdown of growth trends
-- 2. Include payment growth analysis
-- 3. Segment growth analysis by provider characteristics
-- 4. Add statistical significance testing for growth rates
-- 5. Incorporate seasonal adjustments
-- 6. Add decline analysis for contracting services

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:15:57.610141
    - Additional Notes: Query requires minimum of 2 years historical data and filters for services with at least 1,000 annual procedures. Growth calculations may be impacted by changes in APC coding practices or provider reporting patterns between years.
    
    */