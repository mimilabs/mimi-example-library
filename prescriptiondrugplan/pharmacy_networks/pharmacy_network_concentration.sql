-- pharmacy_market_concentration.sql
-- Business Purpose: Analyze market concentration of pharmacy networks across Part D plans
-- This query examines plan-level competition and network overlap to identify:
-- 1. Market dominance patterns of certain pharmacy networks
-- 2. Plans with highly unique vs overlapping pharmacy networks
-- 3. Geographic areas with high network concentration

WITH plan_pharmacy_metrics AS (
    -- Calculate pharmacy network metrics for each plan
    SELECT 
        contract_id,
        plan_id,
        segment_id,
        COUNT(DISTINCT pharmacy_number) as total_pharmacies,
        COUNT(DISTINCT CASE WHEN preferred_status_retail = 'Y' THEN pharmacy_number END) as preferred_pharmacies,
        COUNT(DISTINCT pharmacy_zipcode) as unique_zipcodes,
        SUM(CASE WHEN pharmacy_mail = 'Y' THEN 1 ELSE 0 END) as mail_order_count
    FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
    GROUP BY contract_id, plan_id, segment_id
),
network_overlap AS (
    -- Calculate how many plans each pharmacy participates in
    SELECT 
        pharmacy_number,
        COUNT(DISTINCT CONCAT(contract_id, plan_id, segment_id)) as plan_participation_count,
        COUNT(DISTINCT CASE WHEN preferred_status_retail = 'Y' THEN 
            CONCAT(contract_id, plan_id, segment_id) END) as preferred_plan_count
    FROM mimi_ws_1.prescriptiondrugplan.pharmacy_networks
    GROUP BY pharmacy_number
)

SELECT 
    ppm.contract_id,
    ppm.plan_id,
    ppm.total_pharmacies,
    ppm.preferred_pharmacies,
    ppm.unique_zipcodes,
    ppm.mail_order_count,
    -- Calculate network exclusivity metrics
    ROUND(AVG(no.plan_participation_count), 2) as avg_pharmacy_plan_participation,
    ROUND(COUNT(CASE WHEN no.plan_participation_count = 1 THEN 1 END) * 100.0 / 
        COUNT(*), 2) as exclusive_pharmacy_percentage
FROM plan_pharmacy_metrics ppm
JOIN mimi_ws_1.prescriptiondrugplan.pharmacy_networks pn
    ON ppm.contract_id = pn.contract_id 
    AND ppm.plan_id = pn.plan_id 
    AND ppm.segment_id = pn.segment_id
JOIN network_overlap no
    ON pn.pharmacy_number = no.pharmacy_number
GROUP BY 
    ppm.contract_id,
    ppm.plan_id,
    ppm.total_pharmacies,
    ppm.preferred_pharmacies,
    ppm.unique_zipcodes,
    ppm.mail_order_count
ORDER BY total_pharmacies DESC;

-- How this query works:
-- 1. First CTE calculates basic network metrics for each plan
-- 2. Second CTE analyzes how many plans each pharmacy participates in
-- 3. Main query joins these together to create plan-level market concentration metrics
-- 4. Results show both size and exclusivity of pharmacy networks

-- Assumptions and limitations:
-- 1. Assumes current snapshot represents typical network patterns
-- 2. Does not account for pharmacy size/volume
-- 3. Geographic overlap analysis is at ZIP code level only
-- 4. Mail order pharmacies may skew some metrics due to national reach

-- Possible extensions:
-- 1. Add temporal analysis to track network changes over time
-- 2. Include pharmacy type stratification
-- 3. Add geographic market concentration metrics (HHI)
-- 4. Link to plan enrollment data to weight by market impact
-- 5. Add cost/fee analysis to understand pricing power

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:23:28.491333
    - Additional Notes: This query analyzes market competitiveness in Medicare Part D pharmacy networks by measuring network sizes, overlap patterns, and plan-level exclusivity. Results help identify market concentration and potential monopolistic patterns in pharmacy network arrangements. Consider filtering by specific time periods using mimi_src_file_date for more current analysis.
    
    */