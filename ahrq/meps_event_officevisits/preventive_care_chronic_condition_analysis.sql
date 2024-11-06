
-- MEPS Office Visits: Preventive Care and Chronic Condition Management Analysis
-- 
-- Business Purpose:
-- Provide insights into preventive care services and chronic condition management
-- across different medical provider types, helping healthcare organizations:
-- 1. Identify gaps in preventive care delivery
-- 2. Understand variation in service utilization
-- 3. Support strategic healthcare resource allocation

WITH preventive_care_summary AS (
    -- Analyze preventive care services across different provider types
    SELECT 
        -- Categorize provider types for meaningful insights
        CASE 
            WHEN medptype = 1 THEN 'Physician'
            WHEN medptype = 2 THEN 'Nurse Practitioner'
            WHEN medptype = 3 THEN 'Physician Assistant'
            ELSE 'Other Provider'
        END AS provider_type,
        
        -- Aggregate preventive care indicators
        SUM(CASE WHEN rcvvac = 1 THEN 1 ELSE 0 END) AS vaccination_count,
        SUM(CASE WHEN labtest = 1 THEN 1 ELSE 0 END) AS lab_test_count,
        SUM(CASE WHEN mammog = 1 THEN 1 ELSE 0 END) AS mammogram_count,
        
        -- Calculate visit volume and preventive care rate
        COUNT(*) AS total_visits,
        ROUND(
            100.0 * (
                SUM(CASE WHEN rcvvac = 1 OR labtest = 1 OR mammog = 1 THEN 1 ELSE 0 END)
            ) / COUNT(*), 
            2
        ) AS preventive_care_rate,
        
        -- Analytical weighting for population-level estimates
        SUM(perwt_yy_f) AS weighted_population

    FROM mimi_ws_1.ahrq.meps_event_officevisits
    
    -- Focus on recent data and exclude incomplete records
    WHERE obdateyr BETWEEN 2019 AND 2022
      AND mpcelig = 1
      AND mpcdata = 1
    
    GROUP BY provider_type
),

chronic_condition_analysis AS (
    -- Analyze visits related to chronic conditions
    SELECT 
        -- Categorize visits by condition relationship
        CASE 
            WHEN vstrelcn = 1 THEN 'Chronic Condition Related'
            ELSE 'Non-Chronic Condition'
        END AS condition_type,
        
        -- Aggregate medication and diagnostic insights
        SUM(CASE WHEN medpresc = 1 THEN 1 ELSE 0 END) AS prescriptions_issued,
        SUM(CASE WHEN surgproc = 1 THEN 1 ELSE 0 END) AS surgical_procedures,
        
        COUNT(*) AS total_visits,
        ROUND(AVG(obxp_yy_x), 2) AS avg_visit_expenditure

    FROM mimi_ws_1.ahrq.meps_event_officevisits
    
    WHERE obdateyr BETWEEN 2019 AND 2022
      AND mpcelig = 1
      AND mpcdata = 1
    
    GROUP BY condition_type
)

-- Final aggregated insights combining preventive care and chronic condition analysis
SELECT 
    pcs.provider_type,
    pcs.total_visits,
    pcs.preventive_care_rate,
    pcs.vaccination_count,
    pcs.lab_test_count,
    pcs.mammogram_count,
    
    cca.condition_type,
    cca.prescriptions_issued,
    cca.surgical_procedures,
    cca.avg_visit_expenditure

FROM preventive_care_summary pcs
CROSS JOIN chronic_condition_analysis cca

ORDER BY pcs.total_visits DESC, pcs.preventive_care_rate DESC;

-- Query Mechanics:
-- 1. Creates two Common Table Expressions (CTEs) to analyze different aspects of office visits
-- 2. Uses conditional aggregations to extract meaningful metrics
-- 3. Applies population weighting for accurate representation
-- 4. Focuses on recent data (2019-2022) with complete records

-- Assumptions and Limitations:
-- - Uses self-reported survey data, which may have recall bias
-- - Relies on specific MEPS coding for provider types and visit characteristics
-- - Does not capture all healthcare interactions outside of surveyed visits

-- Potential Extensions:
-- 1. Add age group stratification
-- 2. Incorporate geographic region analysis
-- 3. Develop predictive models for preventive care utilization
-- 4. Compare trends across different insurance types


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:16:12.993742
    - Additional Notes: Requires careful interpretation due to survey sampling methodology. Uses population weights and focuses on 2019-2022 data. Designed for strategic healthcare resource planning insights.
    
    */