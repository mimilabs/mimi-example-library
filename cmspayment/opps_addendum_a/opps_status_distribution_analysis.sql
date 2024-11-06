-- Title: OPPS Service Categorization and Status Distribution Analysis
-- Business Purpose: Analyzes the distribution of outpatient services across different status indicators 
-- and payment categories to understand service mix and payment methodologies. This helps healthcare
-- organizations optimize their outpatient service portfolio and understand Medicare payment policies.

WITH latest_data AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY apc ORDER BY mimi_src_file_date DESC) as rn
    FROM mimi_ws_1.cmspayment.opps_addendum_a
    WHERE mimi_src_file_date IS NOT NULL
),

status_summary AS (
    SELECT 
        status_indicator,
        COUNT(DISTINCT apc) as unique_apcs,
        COUNT(*) as total_services,
        AVG(COALESCE(payment_rate, 0)) as avg_payment,
        SUM(CASE WHEN payment_rate > 0 THEN 1 ELSE 0 END) as paid_services
    FROM latest_data
    WHERE rn = 1  -- Most recent data only
    GROUP BY status_indicator
)

SELECT 
    status_indicator,
    unique_apcs,
    total_services,
    ROUND(total_services * 100.0 / SUM(total_services) OVER (), 2) as pct_of_total_services,
    ROUND(avg_payment, 2) as avg_payment_rate,
    ROUND(paid_services * 100.0 / total_services, 2) as pct_paid_services,
    CASE 
        WHEN status_indicator IN ('J1', 'J2') THEN 'Comprehensive APCs'
        WHEN status_indicator IN ('S', 'T', 'V') THEN 'Primary Services'
        WHEN status_indicator IN ('N', 'Q1', 'Q2') THEN 'Packaged Services'
        WHEN status_indicator = 'A' THEN 'Fee Schedule Services'
        ELSE 'Other Categories'
    END as payment_category
FROM status_summary
WHERE total_services > 0
ORDER BY total_services DESC;

-- How it works:
-- 1. Creates a CTE to get the most recent data for each APC
-- 2. Summarizes services by status indicator, counting unique APCs and calculating payment metrics
-- 3. Adds percentage calculations and categorizes services into payment categories
-- 4. Orders results by volume to highlight most common service types

-- Assumptions and Limitations:
-- 1. Assumes the most recent data per APC is the most relevant
-- 2. Zero payment rates are included in averages to reflect non-paid services
-- 3. Payment categories are simplified groupings and may need adjustment
-- 4. Analysis is at the service definition level, not actual utilization

-- Possible Extensions:
-- 1. Add trend analysis by comparing distributions across multiple quarters
-- 2. Include relative weight analysis to understand resource intensity
-- 3. Add specific service line analysis (e.g., imaging, surgery, E&M)
-- 4. Compare packaged vs. separately paid service distributions
-- 5. Analyze copayment patterns within each status indicator

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:07:29.365760
    - Additional Notes: This query provides a strategic overview of OPPS service categorization and payment methods, useful for healthcare administrators and policy analysts. Note that it focuses on service definitions rather than actual utilization data, and the payment category groupings are simplified for basic analysis purposes.
    
    */