-- pharmacy_network_cost_analysis.sql
-- Business Purpose: Analyze dispensing fee variations and cost structures across pharmacy networks
-- This query examines cost patterns to:
-- 1. Compare dispensing fees between retail and mail order pharmacies
-- 2. Identify cost-effective pharmacy options for health plans
-- 3. Support network optimization and cost management strategies

WITH pharmacy_costs AS (
    -- Calculate average dispensing fees by pharmacy type
    SELECT 
        contract_id,
        pharmacy_retail,
        pharmacy_mail,
        preferred_status_retail,
        preferred_status_mail,
        COUNT(DISTINCT pharmacy_number) as pharmacy_count,
        AVG(brand_dispensing_fee_30) as avg_brand_fee_30,
        AVG(generic_dispensing_fee_30) as avg_generic_fee_30,
        MIN(floor_price) as min_floor_price,
        MAX(floor_price) as max_floor_price
    FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks)
    GROUP BY 
        contract_id,
        pharmacy_retail,
        pharmacy_mail,
        preferred_status_retail,
        preferred_status_mail
)

SELECT 
    contract_id,
    CASE 
        WHEN pharmacy_retail = 'Y' THEN 'Retail'
        WHEN pharmacy_mail = 'Y' THEN 'Mail Order'
        ELSE 'Other'
    END as pharmacy_type,
    CASE 
        WHEN preferred_status_retail = 'Y' OR preferred_status_mail = 'Y' THEN 'Preferred'
        ELSE 'Non-Preferred'
    END as preferred_status,
    pharmacy_count,
    ROUND(avg_brand_fee_30, 2) as avg_brand_fee_30,
    ROUND(avg_generic_fee_30, 2) as avg_generic_fee_30,
    ROUND(min_floor_price, 2) as min_floor_price,
    ROUND(max_floor_price, 2) as max_floor_price,
    ROUND((avg_brand_fee_30 - avg_generic_fee_30), 2) as brand_generic_fee_diff
FROM pharmacy_costs
WHERE pharmacy_count > 10  -- Filter out contracts with limited pharmacy networks
ORDER BY 
    contract_id,
    pharmacy_type,
    preferred_status;

-- How it works:
-- 1. Creates a CTE to aggregate cost metrics by pharmacy type and preferred status
-- 2. Calculates average dispensing fees and floor price ranges
-- 3. Formats results with meaningful labels and rounds numeric values
-- 4. Filters for meaningful network sizes and sorts for readability

-- Assumptions and Limitations:
-- 1. Uses most recent data snapshot only
-- 2. Assumes pharmacy type indicators are mutually exclusive
-- 3. Minimum network size of 10 pharmacies may need adjustment
-- 4. Does not account for regional cost variations

-- Possible Extensions:
-- 1. Add geographic analysis by incorporating ZIP code data
-- 2. Compare costs across different contract types (MA-PD vs PDP)
-- 3. Trend analysis by including historical data
-- 4. Add volume-weighted averages if prescription volume data available
-- 5. Include correlation analysis with plan premiums or star ratings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:11:47.174862
    - Additional Notes: The query focuses on fee structure comparisons between pharmacy types but does not account for seasonal variations in pricing or regional cost-of-living differences. The minimum threshold of 10 pharmacies may need adjustment based on specific market analysis needs. Consider pharmacy_network_size when interpreting results as smaller networks may show extreme values.
    
    */