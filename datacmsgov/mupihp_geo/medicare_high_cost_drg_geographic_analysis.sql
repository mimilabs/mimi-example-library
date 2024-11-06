-- medicare_high_cost_drg_geographic_analysis.sql
-- Business Purpose: 
-- Identify high-cost Medicare Diagnosis Related Groups (DRGs) across different states 
-- to support strategic healthcare resource allocation, cost management, and regional health policy planning.
-- The analysis reveals geographic variations in healthcare spending and utilization for complex medical conditions.

WITH high_cost_drgs AS (
    -- Identify the top 10 most expensive DRGs nationally for the most recent year
    SELECT 
        drg_cd,
        drg_desc,
        ROUND(AVG(avg_tot_pymt_amt), 2) AS national_avg_total_payment
    FROM mimi_ws_1.datacmsgov.mupihp_geo
    WHERE 
        rndrng_prvdr_geo_lvl = 'National'
        AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.mupihp_geo)
    GROUP BY drg_cd, drg_desc
    ORDER BY national_avg_total_payment DESC
    LIMIT 10
),
state_drg_analysis AS (
    -- Analyze state-level performance for these high-cost DRGs
    SELECT 
        g.rndrng_prvdr_geo_desc AS state,
        h.drg_cd,
        h.drg_desc,
        h.national_avg_total_payment,
        ROUND(AVG(g.avg_tot_pymt_amt), 2) AS state_avg_total_payment,
        ROUND(AVG(g.tot_dschrgs), 0) AS total_state_discharges,
        ROUND(
            (AVG(g.avg_tot_pymt_amt) - h.national_avg_total_payment) / h.national_avg_total_payment * 100, 
            2
        ) AS percent_deviation_from_national
    FROM mimi_ws_1.datacmsgov.mupihp_geo g
    JOIN high_cost_drgs h ON g.drg_cd = h.drg_cd
    WHERE 
        g.rndrng_prvdr_geo_lvl = 'State'
        AND g.mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.mupihp_geo)
    GROUP BY 
        g.rndrng_prvdr_geo_desc, 
        h.drg_cd, 
        h.drg_desc, 
        h.national_avg_total_payment
)
-- Final output highlighting states with significant cost variations
SELECT 
    state,
    drg_cd,
    drg_desc,
    national_avg_total_payment,
    state_avg_total_payment,
    total_state_discharges,
    percent_deviation_from_national
FROM state_drg_analysis
WHERE 
    ABS(percent_deviation_from_national) > 15  -- Focus on states with >15% deviation
ORDER BY 
    ABS(percent_deviation_from_national) DESC
LIMIT 50;

-- Query Mechanics:
-- 1. Identifies top 10 most expensive DRGs nationally
-- 2. Compares state-level performance against national averages
-- 3. Highlights states with significant cost variations

-- Assumptions and Limitations:
-- - Uses most recent available year of data
-- - Focuses on states with >15% deviation from national average
-- - Only considers Original Medicare Part A claims
-- - Does not account for regional cost of living differences

-- Possible Extensions:
-- 1. Add trend analysis across multiple years
-- 2. Incorporate population-adjusted metrics
-- 3. Include additional cost efficiency indicators
-- 4. Segment analysis by hospital type or size

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:45:18.332936
    - Additional Notes: Query provides insights into geographic variations of high-cost Medicare Diagnosis Related Groups (DRGs), highlighting state-level cost deviations from national averages. Useful for healthcare policy analysis and resource allocation planning.
    
    */