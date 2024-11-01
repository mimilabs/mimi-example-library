/*
Title: Chronic Condition Duration Analysis for Resource Planning
 
Business Purpose:
- Analyze the average and maximum duration of chronic conditions to support resource planning
- Identify conditions requiring extended care management
- Support staffing and budget allocation decisions for long-term care programs
- Guide care management program development based on condition persistence patterns
*/

WITH condition_durations AS (
    SELECT 
        description,
        -- Calculate duration for each condition instance
        DATEDIFF(
            COALESCE(stop, CURRENT_DATE()), -- Use current date if condition is ongoing
            start
        ) as duration_days,
        -- Flag if condition is ongoing
        CASE WHEN stop IS NULL THEN 1 ELSE 0 END as is_active
    FROM mimi_ws_1.synthea.conditions
    WHERE start IS NOT NULL -- Ensure valid start dates
),

condition_metrics AS (
    SELECT 
        description,
        COUNT(*) as total_cases,
        ROUND(AVG(duration_days), 0) as avg_duration_days,
        MAX(duration_days) as max_duration_days,
        SUM(is_active) as active_cases,
        ROUND(AVG(duration_days) FILTER (WHERE is_active = 1), 0) as avg_duration_active_cases
    FROM condition_durations
    GROUP BY description
    HAVING COUNT(*) >= 100 -- Focus on conditions with significant occurrence
)

SELECT 
    description,
    total_cases,
    active_cases,
    avg_duration_days,
    max_duration_days,
    avg_duration_active_cases,
    -- Calculate percentage of cases that are still active
    ROUND(100.0 * active_cases / total_cases, 1) as active_cases_pct
FROM condition_metrics
WHERE avg_duration_days >= 180 -- Focus on conditions lasting 6+ months on average
ORDER BY avg_duration_days DESC
LIMIT 20;

/*
How the Query Works:
1. First CTE calculates duration for each condition instance
2. Second CTE aggregates metrics by condition
3. Final query filters for chronic conditions and presents key metrics

Assumptions and Limitations:
- Assumes NULL stop dates indicate ongoing conditions
- Minimum threshold of 100 cases may exclude rare but important conditions
- 180-day duration threshold is arbitrary and may need adjustment
- synthetic data may not perfectly reflect real-world condition durations

Possible Extensions:
1. Add age group analysis to understand condition duration patterns by demographics
2. Include cost data to estimate long-term care expenses
3. Analyze seasonal patterns in condition onset
4. Compare duration patterns across different facilities or regions
5. Add trend analysis to see if condition durations are changing over time
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:45:13.922550
    - Additional Notes: Query provides high-level metrics for long-term condition management with focus on cases lasting 6+ months. The 100-case threshold and 180-day duration filter may need adjustment based on specific organizational needs. Results are most useful for long-term care planning and resource allocation.
    
    */