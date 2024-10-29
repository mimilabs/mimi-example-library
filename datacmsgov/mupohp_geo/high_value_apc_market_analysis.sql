-- Title: High-Value Outpatient Services Market Opportunity Analysis

-- Business Purpose:
-- This query identifies high-value outpatient service opportunities by analyzing
-- the volume and financial metrics of APC codes across states. It helps identify:
-- 1. Which outpatient services have high utilization and reimbursement
-- 2. Geographic variations in service delivery and payment
-- 3. Potential market opportunities for healthcare organizations

WITH state_metrics AS (
    SELECT 
        apc_cd,
        apc_desc,
        rndrng_prvdr_geo_cd,
        SUM(capc_srvcs) as state_services,
        AVG(avg_mdcr_pymt_amt) as state_avg_payment
    FROM mimi_ws_1.datacmsgov.mupohp_geo
    WHERE 
        mimi_src_file_date = '2022-12-31'
        AND rndrng_prvdr_geo_lvl = 'State'
        AND srvc_lvl = 'APC'
        AND capc_srvcs > 100
    GROUP BY 
        apc_cd,
        apc_desc,
        rndrng_prvdr_geo_cd
)

SELECT 
    apc_cd,
    apc_desc,
    COUNT(DISTINCT rndrng_prvdr_geo_cd) as num_states,
    SUM(state_services) as total_services,
    ROUND(AVG(state_avg_payment), 2) as avg_medicare_payment,
    ROUND(SUM(state_services * state_avg_payment), 2) as estimated_total_revenue,
    -- Calculate market concentration
    ROUND(MAX(state_services) * 100.0 / SUM(state_services), 2) as max_state_share_pct

FROM state_metrics

GROUP BY 
    apc_cd,
    apc_desc

-- Focus on high-value opportunities    
HAVING 
    SUM(state_services) > 1000
    AND AVG(state_avg_payment) > 1000

ORDER BY 
    estimated_total_revenue DESC
LIMIT 20

-- How this works:
-- 1. Creates state-level metrics in CTE for each APC code
-- 2. Aggregates to national level with volume and payment metrics
-- 3. Calculates market concentration using state shares
-- 4. Filters for high-volume, high-payment services
-- 5. Returns top 20 market opportunities sorted by revenue potential

-- Assumptions and Limitations:
-- 1. Uses service counts and average payments as proxy for market size
-- 2. State-level data may mask local market variations
-- 3. Medicare payments may differ from commercial rates
-- 4. Does not account for service complexity or resource requirements

-- Possible Extensions:
-- 1. Add year-over-year growth analysis
-- 2. Include geographic clustering analysis
-- 3. Compare against hospital capacity data
-- 4. Factor in demographic and population health metrics
-- 5. Add specialty-specific service groupings
-- 6. Include outlier payment analysis for complex services

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:33:36.988246
    - Additional Notes: Query identifies valuable market opportunities in Medicare outpatient services by calculating key metrics like total revenue potential and market concentration for each APC code. The two-step aggregation (first by state, then national) ensures accurate calculations of market share percentages and service volumes while maintaining proper statistical relationships.
    
    */