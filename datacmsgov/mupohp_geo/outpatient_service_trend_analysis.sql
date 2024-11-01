-- Title: Outpatient Hospital Service Utilization and Payment Trends

-- Business Purpose:
-- This query analyzes the year-over-year trends in outpatient hospital service 
-- utilization and Medicare payments. It helps healthcare organizations and policymakers:
-- 1. Understand growth patterns in outpatient services
-- 2. Track changes in Medicare payment rates
-- 3. Identify shifts in service delivery patterns
-- 4. Support capacity planning and resource allocation

WITH yearly_metrics AS (
    -- Calculate key metrics by year
    SELECT 
        YEAR(mimi_src_file_date) as service_year,
        SUM(bene_cnt) as total_beneficiaries,
        SUM(capc_srvcs) as total_services,
        AVG(avg_mdcr_pymt_amt) as avg_medicare_payment,
        COUNT(DISTINCT apc_cd) as unique_services,
        SUM(capc_srvcs) / SUM(bene_cnt) as services_per_beneficiary
    FROM mimi_ws_1.datacmsgov.mupohp_geo
    WHERE rndrng_prvdr_geo_lvl = 'National'
    GROUP BY YEAR(mimi_src_file_date)
),

yoy_changes AS (
    -- Calculate year-over-year changes
    SELECT 
        current.service_year,
        current.total_beneficiaries,
        current.total_services,
        current.avg_medicare_payment,
        current.unique_services,
        current.services_per_beneficiary,
        ROUND(((current.total_beneficiaries - prev.total_beneficiaries) / prev.total_beneficiaries * 100), 1) as beneficiary_growth_pct,
        ROUND(((current.total_services - prev.total_services) / prev.total_services * 100), 1) as service_growth_pct,
        ROUND(((current.avg_medicare_payment - prev.avg_medicare_payment) / prev.avg_medicare_payment * 100), 1) as payment_growth_pct
    FROM yearly_metrics current
    LEFT JOIN yearly_metrics prev 
        ON current.service_year = prev.service_year + 1
)

SELECT *
FROM yoy_changes
ORDER BY service_year;

-- How the Query Works:
-- 1. First CTE (yearly_metrics) aggregates national-level metrics by year
-- 2. Second CTE (yoy_changes) calculates year-over-year percentage changes
-- 3. Final output shows both absolute values and growth rates for key metrics

-- Assumptions and Limitations:
-- 1. Assumes data is available for consecutive years for trend analysis
-- 2. Limited to national-level trends only
-- 3. Focuses on volume and payment metrics, not clinical outcomes
-- 4. Does not account for changes in Medicare payment policies or coding practices

-- Possible Extensions:
-- 1. Add state-level trend analysis by modifying the geographic level
-- 2. Include service-specific trends for high-volume APCs
-- 3. Add seasonal analysis by incorporating monthly patterns
-- 4. Include cost efficiency metrics (payment vs. submitted charges)
-- 5. Add demographic analysis if beneficiary characteristics are available

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:22:44.766081
    - Additional Notes: The query provides a consolidated view of national outpatient service trends with year-over-year comparisons. Best utilized with at least 2-3 years of historical data to show meaningful trends. Results can be significantly impacted by changes in Medicare payment policies or coding practices between years.
    
    */