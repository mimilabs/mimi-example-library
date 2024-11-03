-- Title: Supply Efficiency Analysis by Patient Encounter Type

-- Business Purpose:
-- This query evaluates supply utilization efficiency across different encounter types to:
-- - Identify opportunities for standardizing supply usage protocols
-- - Support evidence-based supply allocation decisions
-- - Enable targeted cost reduction initiatives by encounter type
-- - Provide insights for clinical practice standardization

WITH encounter_supplies AS (
    -- Aggregate supply usage by encounter and description
    SELECT 
        s.encounter,
        s.description,
        SUM(s.quantity) as total_quantity,
        COUNT(DISTINCT s.date) as usage_days
    FROM mimi_ws_1.synthea.supplies s
    GROUP BY 
        s.encounter,
        s.description
),
encounter_metrics AS (
    -- Calculate average daily usage per encounter
    SELECT 
        es.description,
        AVG(es.total_quantity / NULLIF(es.usage_days, 0)) as avg_daily_usage,
        COUNT(DISTINCT es.encounter) as encounter_count,
        SUM(es.total_quantity) as total_quantity
    FROM encounter_supplies es
    GROUP BY 
        es.description
)

SELECT 
    description,
    ROUND(avg_daily_usage, 2) as avg_daily_usage,
    encounter_count,
    total_quantity,
    -- Calculate efficiency metrics
    ROUND(total_quantity / NULLIF(encounter_count, 0), 2) as supplies_per_encounter,
    ROUND((total_quantity * 100.0) / SUM(total_quantity) OVER (), 2) as usage_percentage
FROM encounter_metrics
WHERE encounter_count > 10  -- Focus on frequently used supplies
ORDER BY total_quantity DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates supply usage at the encounter level
-- 2. Second CTE calculates average daily usage metrics
-- 3. Final query adds efficiency metrics and filters for relevance
-- 4. Results show top 20 supplies by volume with efficiency indicators

-- Assumptions and Limitations:
-- - Assumes supply quantities are recorded consistently
-- - Limited to supplies used in more than 10 encounters for statistical relevance
-- - Does not account for supply costs (only quantities)
-- - Averages may mask significant variation in individual cases

-- Possible Extensions:
-- 1. Add cost analysis by incorporating supply unit prices
-- 2. Segment analysis by department or specialty
-- 3. Compare supply usage patterns between different facilities
-- 4. Add year-over-year comparison for supply utilization trends
-- 5. Incorporate clinical outcomes to assess supply usage impact

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:20:57.113093
    - Additional Notes: Query focuses on supply utilization patterns per encounter, with thresholds set to exclude low-volume items (>10 encounters). May need adjustment of thresholds based on specific facility size and usage patterns. Consider adding facility/location dimensions for multi-site deployments.
    
    */