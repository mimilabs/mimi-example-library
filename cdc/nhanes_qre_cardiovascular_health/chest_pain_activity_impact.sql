-- Chest Pain Activity Impact Analysis
-- ---------------------------------------------------------------------------
-- Business Purpose: Analyze how chest pain impacts daily activities and patient 
-- responses to inform care management programs and patient education strategies.
-- This analysis helps healthcare providers understand activity limitations and
-- patient behaviors to develop targeted intervention programs.

WITH chest_pain_responses AS (
    -- Get base population with chest pain and their activity responses
    SELECT 
        seqn,
        cdq001 AS has_chest_pain,
        cdq002 AS pain_when_hurry,
        cdq003 AS pain_normal_walk,
        cdq004 AS response_to_pain,
        cdq005 AS relief_when_standing
    FROM mimi_ws_1.cdc.nhanes_qre_cardiovascular_health
    WHERE cdq001 = 1  -- Only include those who reported chest pain
),

activity_impact AS (
    -- Categorize activity impact levels
    SELECT
        CASE 
            WHEN pain_when_hurry = 1 AND pain_normal_walk = 1 THEN 'Severe Impact'
            WHEN pain_when_hurry = 1 AND pain_normal_walk = 2 THEN 'Moderate Impact'
            ELSE 'Mild Impact'
        END AS impact_level,
        COUNT(*) as patient_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as percentage
    FROM chest_pain_responses
    GROUP BY 
        CASE 
            WHEN pain_when_hurry = 1 AND pain_normal_walk = 1 THEN 'Severe Impact'
            WHEN pain_when_hurry = 1 AND pain_normal_walk = 2 THEN 'Moderate Impact'
            ELSE 'Mild Impact'
        END
)

SELECT 
    impact_level,
    patient_count,
    percentage,
    CONCAT(REPEAT('*', CAST(percentage/5 AS INT))) as distribution_viz
FROM activity_impact
ORDER BY 
    CASE impact_level 
        WHEN 'Severe Impact' THEN 1
        WHEN 'Moderate Impact' THEN 2
        WHEN 'Mild Impact' THEN 3
    END;

-- How this query works:
-- 1. First CTE filters for patients with chest pain and selects relevant activity responses
-- 2. Second CTE categorizes patients into impact levels based on when they experience pain
-- 3. Main query adds visualization and formats results
--
-- Assumptions and Limitations:
-- - Assumes valid responses (no missing/null values)
-- - Impact levels are simplified into three categories
-- - Self-reported data may have inherent biases
--
-- Possible Extensions:
-- 1. Add correlation with relief patterns (cdq005, cdq006)
-- 2. Segment by demographic factors if available
-- 3. Include analysis of behavioral responses (cdq004)
-- 4. Track trends over time using mimi_src_file_date
-- 5. Add risk stratification based on multiple symptoms

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:40:59.549998
    - Additional Notes: The query stratifies chest pain impact into three severity levels based on activity triggers. Note that the visualization column (distribution_viz) assumes a console/text output environment and may need adjustment for different visualization tools. The percentage/5 calculation in the visualization could be adjusted based on desired scale.
    
    */