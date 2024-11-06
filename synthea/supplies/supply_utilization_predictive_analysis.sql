-- Title: Supply Utilization Predictive Cost Analysis

-- Business Purpose:
-- Develop a strategic view of medical supply consumption that enables:
-- 1. Predictive budgeting for hospital supply procurement
-- 2. Identifying high-cost supply categories
-- 3. Understanding supply utilization patterns across patient demographics

WITH supply_cost_summary AS (
    SELECT 
        code,
        description,
        COUNT(DISTINCT encounter) AS total_encounters,
        COUNT(DISTINCT patient) AS unique_patients,
        SUM(quantity) AS total_quantity,
        ROUND(AVG(quantity), 2) AS avg_quantity_per_encounter
    FROM 
        mimi_ws_1.synthea.supplies
    GROUP BY 
        code, description
),
supply_cost_ranking AS (
    SELECT 
        *,
        RANK() OVER (ORDER BY total_quantity DESC) AS supply_volume_rank,
        RANK() OVER (ORDER BY unique_patients DESC) AS patient_impact_rank
    FROM 
        supply_cost_summary
)

SELECT 
    code,
    description,
    total_encounters,
    unique_patients,
    total_quantity,
    avg_quantity_per_encounter,
    supply_volume_rank,
    patient_impact_rank
FROM 
    supply_cost_ranking
WHERE 
    supply_volume_rank <= 25 OR patient_impact_rank <= 25
ORDER BY 
    total_quantity DESC, unique_patients DESC
LIMIT 100;

-- Query Mechanics:
-- 1. Aggregates supply usage at the code/description level
-- 2. Calculates encounter and patient-level metrics
-- 3. Ranks supplies by total volume and patient impact
-- 4. Returns top 25 supplies by volume or patient reach

-- Assumptions & Limitations:
-- - Uses synthetic data which may not reflect real-world variations
-- - Assumes consistent supply coding across encounters
-- - Does not account for supply cost, only quantity/frequency

-- Potential Extensions:
-- 1. Join with encounter type to segment by care setting
-- 2. Incorporate actual supply pricing for cost analysis
-- 3. Add temporal trend analysis by adding date-based windowing
-- 4. Integrate patient demographic information for deeper segmentation

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:15:28.747867
    - Additional Notes: Provides a comprehensive view of medical supply consumption using synthetic healthcare data, focusing on volume and patient impact rankings. Designed for high-level supply strategy insights, but requires careful interpretation due to synthetic data limitations.
    
    */