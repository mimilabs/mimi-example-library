-- pharmacy_network_efficiency.sql

-- Business Purpose: Analyze pharmacy network distribution efficiency indicators
-- This query examines key operational efficiency metrics including:
-- 1. Ratio of preferred to non-preferred pharmacies per contract
-- 2. Balance between retail and mail order options
-- 3. Cost structure variations through dispensing fees
-- These insights help identify optimization opportunities and benchmark performance

WITH network_metrics AS (
    -- Calculate base metrics per contract
    SELECT 
        contract_id,
        COUNT(DISTINCT pharmacy_number) as total_pharmacies,
        SUM(CASE WHEN preferred_status_retail = 'Y' THEN 1 ELSE 0 END) as preferred_retail_count,
        SUM(CASE WHEN pharmacy_retail = 'Y' THEN 1 ELSE 0 END) as total_retail_count,
        SUM(CASE WHEN pharmacy_mail = 'Y' THEN 1 ELSE 0 END) as mail_order_count,
        AVG(brand_dispensing_fee_30) as avg_brand_fee_30,
        AVG(generic_dispensing_fee_30) as avg_generic_fee_30
    FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks)
    GROUP BY contract_id
)

SELECT 
    contract_id,
    total_pharmacies,
    -- Calculate efficiency indicators
    ROUND(preferred_retail_count * 100.0 / NULLIF(total_retail_count, 0), 2) as preferred_pharmacy_pct,
    ROUND(mail_order_count * 100.0 / total_pharmacies, 2) as mail_order_pct,
    avg_brand_fee_30,
    avg_generic_fee_30,
    -- Categorize network efficiency
    CASE 
        WHEN preferred_retail_count * 100.0 / NULLIF(total_retail_count, 0) >= 70 THEN 'High Preferred'
        WHEN preferred_retail_count * 100.0 / NULLIF(total_retail_count, 0) >= 40 THEN 'Moderate Preferred'
        ELSE 'Low Preferred'
    END as network_efficiency_category
FROM network_metrics
WHERE total_pharmacies > 0
ORDER BY total_pharmacies DESC
LIMIT 100;

-- How it works:
-- 1. Creates a CTE to aggregate key metrics per contract
-- 2. Calculates percentage-based efficiency indicators
-- 3. Categorizes networks based on preferred pharmacy ratio
-- 4. Filters out contracts with zero pharmacies
-- 5. Returns top 100 contracts by network size

-- Assumptions and Limitations:
-- 1. Uses most recent data snapshot only
-- 2. Assumes preferred pharmacy percentage is a valid efficiency indicator
-- 3. Does not account for geographic distribution
-- 4. Limited to contracts with active pharmacies
-- 5. Arbitrary thresholds for efficiency categories

-- Possible Extensions:
-- 1. Add temporal analysis to track efficiency trends
-- 2. Include regional stratification
-- 3. Incorporate cost efficiency metrics
-- 4. Compare efficiency across different plan types
-- 5. Add correlation analysis with beneficiary outcomes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:08:41.921583
    - Additional Notes: The query calculates efficiency ratios and categorizes pharmacy networks based on preferred pharmacy percentages. Key metrics include preferred-to-total ratios and mail order penetration rates. Performance may be impacted with very large datasets due to multiple aggregations. Consider adding partitioning by mimi_src_file_date for better performance on historical analysis.
    
    */