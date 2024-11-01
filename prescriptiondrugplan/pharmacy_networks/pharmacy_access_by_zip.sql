-- pharmacy_network_access_disparities.sql
-- Business Purpose: Analyze geographic accessibility of preferred pharmacy networks to identify potential access disparities
-- This query examines the distribution of preferred pharmacies by ZIP code and contract to:
-- 1. Identify areas with limited access to preferred pharmacies
-- 2. Compare network adequacy across different contracts
-- 3. Support health equity analysis by linking pharmacy access to demographic data

WITH network_summary AS (
    -- Calculate preferred pharmacy counts and total pharmacies by ZIP and contract
    SELECT 
        contract_id,
        pharmacy_zipcode,
        COUNT(DISTINCT CASE WHEN preferred_status_retail = 'Y' THEN pharmacy_number END) as preferred_pharmacy_count,
        COUNT(DISTINCT pharmacy_number) as total_pharmacy_count,
        COUNT(DISTINCT CASE WHEN pharmacy_retail = 'Y' THEN pharmacy_number END) as retail_pharmacy_count
    FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
    WHERE pharmacy_retail = 'Y'  -- Focus on retail pharmacies
    AND in_area_flag = 1  -- Only include in-service-area pharmacies
    GROUP BY contract_id, pharmacy_zipcode
)

SELECT 
    contract_id,
    pharmacy_zipcode,
    preferred_pharmacy_count,
    total_pharmacy_count,
    retail_pharmacy_count,
    ROUND(preferred_pharmacy_count * 100.0 / NULLIF(retail_pharmacy_count, 0), 2) as preferred_pharmacy_percentage,
    CASE 
        WHEN preferred_pharmacy_count = 0 THEN 'No Access'
        WHEN preferred_pharmacy_count = 1 THEN 'Limited Access'
        WHEN preferred_pharmacy_count >= 2 THEN 'Adequate Access'
    END as access_category
FROM network_summary
WHERE total_pharmacy_count > 0  -- Exclude ZIPs with no pharmacies
ORDER BY 
    preferred_pharmacy_percentage ASC,
    total_pharmacy_count DESC;

-- How this query works:
-- 1. Creates a CTE to summarize pharmacy counts by ZIP code and contract
-- 2. Calculates the percentage of preferred pharmacies
-- 3. Assigns access categories based on preferred pharmacy availability
-- 4. Orders results to highlight areas with potential access issues

-- Assumptions and Limitations:
-- 1. Assumes ZIP codes are valid geographic units for access analysis
-- 2. Does not account for pharmacy capacity or operating hours
-- 3. Does not consider distance between ZIP codes
-- 4. Limited to retail pharmacies only

-- Possible Extensions:
-- 1. Add geographic clustering to identify regional patterns
-- 2. Join with demographic data to analyze social determinants
-- 3. Include temporal analysis to track network changes
-- 4. Add distance calculations between ZIP centroids
-- 5. Compare access patterns between urban and rural areas

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:17:41.789494
    - Additional Notes: Query focuses on geographic accessibility metrics and could be resource-intensive for large datasets. Consider adding WHERE clauses to filter specific regions or contracts if performance is a concern. The preferred_pharmacy_percentage calculation may need adjustment based on business rules for areas with zero retail pharmacies.
    
    */