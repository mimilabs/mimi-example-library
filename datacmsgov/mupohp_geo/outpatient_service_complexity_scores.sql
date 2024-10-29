-- Title: Outpatient Service Complexity and Resource Intensity Analysis

-- Business Purpose:
-- This query analyzes the complexity and resource intensity of outpatient hospital services
-- by examining the relationship between service volume, outlier cases, and Medicare payments.
-- This helps identify services that require more intensive resources or specialized care,
-- which is valuable for capacity planning and service line strategy.

WITH outlier_metrics AS (
    SELECT 
        apc_cd,
        apc_desc,
        rndrng_prvdr_geo_desc as state,
        SUM(capc_srvcs) as total_services,
        SUM(outlier_srvcs) as total_outlier_services,
        ROUND(SUM(outlier_srvcs) * 100.0 / SUM(capc_srvcs), 2) as outlier_rate,
        ROUND(AVG(avg_mdcr_pymt_amt), 2) as avg_payment,
        ROUND(AVG(avg_mdcr_outlier_amt), 2) as avg_outlier_payment
    FROM mimi_ws_1.datacmsgov.mupohp_geo
    WHERE mimi_src_file_date = '2022-12-31'
        AND rndrng_prvdr_geo_lvl = 'State'
        AND capc_srvcs > 100  -- Focus on services with meaningful volume
    GROUP BY apc_cd, apc_desc, state
),
ranked_services AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY state ORDER BY outlier_rate DESC) as complexity_rank
    FROM outlier_metrics
    WHERE outlier_rate > 0  -- Only include services with outliers
)
SELECT 
    state,
    apc_cd,
    apc_desc,
    total_services,
    total_outlier_services,
    outlier_rate,
    avg_payment,
    avg_outlier_payment
FROM ranked_services
WHERE complexity_rank <= 10  -- Top 10 most complex services per state
ORDER BY state, outlier_rate DESC;

-- How the Query Works:
-- 1. First CTE calculates key metrics for each APC code by state
-- 2. Second CTE ranks services within each state by outlier rate
-- 3. Final output shows top 10 most complex services per state based on outlier rates

-- Assumptions and Limitations:
-- 1. Uses outlier rate as a proxy for service complexity
-- 2. Requires minimum service volume of 100 to exclude low-volume outliers
-- 3. Limited to 2022 data
-- 4. May not capture all aspects of clinical complexity

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of service complexity
-- 2. Include additional complexity indicators like avg charge to payment ratios
-- 3. Incorporate service volume growth rates
-- 4. Add geographic clustering analysis for regional patterns
-- 5. Compare complexity patterns between urban and rural states

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:17:57.426045
    - Additional Notes: The query identifies service complexity patterns using outlier rates as a key indicator. Note that the minimum threshold of 100 services may need adjustment based on specific analysis needs, and the definition of complexity through outlier rates should be validated against clinical expertise.
    
    */