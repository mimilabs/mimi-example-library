-- Title: New York Hospital Inpatient Discharge Analysis - Key Performance Metrics
-- 
-- Business Purpose:
-- This query analyzes hospital inpatient discharges in New York State to provide insights into:
-- 1. Hospital utilization and efficiency metrics
-- 2. Financial performance indicators
-- 3. Clinical case mix and complexity
-- 4. Geographic distribution of services
--
-- The insights support strategic planning, resource allocation, and quality improvement initiatives.

WITH hospital_metrics AS (
    -- Calculate key metrics per hospital
    SELECT 
        facility_name,
        hospital_service_area,
        COUNT(*) as total_discharges,
        ROUND(AVG(length_of_stay), 1) as avg_length_of_stay,
        ROUND(AVG(total_charges), 2) as avg_charges,
        ROUND(SUM(total_charges), 2) as total_charges,
        ROUND(AVG(total_costs), 2) as avg_costs
    FROM mimi_ws_1.stategov.hospital_inpatient_discharges_sparcs
    WHERE discharge_year = 2022  -- Focus on most recent complete year
        AND facility_name IS NOT NULL
    GROUP BY facility_name, hospital_service_area
)

SELECT 
    facility_name,
    hospital_service_area,
    total_discharges,
    avg_length_of_stay,
    avg_charges,
    total_charges,
    avg_costs,
    -- Calculate efficiency metrics
    ROUND(total_charges/NULLIF(total_discharges, 0), 2) as revenue_per_discharge,
    ROUND((avg_charges - avg_costs)/NULLIF(avg_charges, 0) * 100, 1) as gross_margin_percent
FROM hospital_metrics
WHERE total_discharges >= 100  -- Filter out very small facilities
ORDER BY total_discharges DESC
LIMIT 20;

-- How this query works:
-- 1. Creates a CTE to aggregate key metrics by facility
-- 2. Calculates volume, utilization, and financial metrics
-- 3. Derives efficiency indicators like revenue per discharge and gross margin
-- 4. Filters for significant facilities and sorts by volume
--
-- Assumptions and Limitations:
-- 1. Assumes 2022 data is complete and representative
-- 2. Excludes facilities with fewer than 100 discharges
-- 3. Does not account for case mix differences between hospitals
-- 4. Financial metrics are based on charges, not actual reimbursement
--
-- Possible Extensions:
-- 1. Add trending analysis across multiple years
-- 2. Include case mix adjustment using APR-DRG weights
-- 3. Add quality metrics like readmission rates or mortality risk
-- 4. Break down analysis by service lines using APR-MDC
-- 5. Compare metrics across hospital service areas
-- 6. Analyze payer mix using payment typology fields

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:14:07.951049
    - Additional Notes: Query focuses on top 20 hospitals by volume and requires 2022 data to be present in the dataset. Financial metrics should be interpreted with caution as they are based on charges rather than actual collections. Minimum threshold of 100 discharges may need adjustment based on specific analysis needs.
    
    */