-- care_plan_success_patterns.sql
-- Business Purpose: 
-- Analyze patterns of completed vs discontinued care plans to identify
-- successful treatment approaches and potential areas for care plan optimization.
-- This helps improve care plan design and patient outcomes while reducing waste.

WITH care_plan_outcomes AS (
  -- Categorize care plans based on completion status
  SELECT 
    description,
    reasondescription,
    CASE 
      WHEN stop IS NOT NULL AND stop > start THEN 'Completed'
      WHEN stop IS NOT NULL AND stop = start THEN 'Same Day Termination'
      WHEN stop IS NULL AND start < CURRENT_DATE THEN 'Ongoing'
      ELSE 'Other'
    END AS plan_status,
    DATEDIFF(DAY, start, COALESCE(stop, CURRENT_DATE)) as plan_duration_days
  FROM mimi_ws_1.synthea.careplans
  WHERE start IS NOT NULL
),

plan_success_metrics AS (
  -- Calculate success metrics for each care plan type
  SELECT 
    description,
    reasondescription,
    COUNT(*) as total_plans,
    SUM(CASE WHEN plan_status = 'Completed' THEN 1 ELSE 0 END) as completed_plans,
    ROUND(AVG(plan_duration_days), 1) as avg_duration_days,
    ROUND(SUM(CASE WHEN plan_status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as completion_rate
  FROM care_plan_outcomes
  GROUP BY description, reasondescription
)

-- Final output with key success metrics
SELECT 
  description as care_plan_type,
  reasondescription as medical_reason,
  total_plans,
  completed_plans,
  avg_duration_days,
  completion_rate as completion_percentage
FROM plan_success_metrics
WHERE total_plans >= 10  -- Focus on care plans with sufficient data
ORDER BY completion_rate DESC, total_plans DESC
LIMIT 20;

-- How it works:
-- 1. First CTE categorizes each care plan based on its completion status
-- 2. Second CTE calculates aggregate success metrics for each care plan type
-- 3. Final query filters and presents the most relevant insights

-- Assumptions and Limitations:
-- - Assumes care plans without stop dates are still ongoing
-- - Minimum threshold of 10 care plans needed for meaningful analysis
-- - Does not account for complexity of different conditions
-- - Limited to top 20 most successful care plan types

-- Possible Extensions:
-- 1. Add patient demographic analysis to identify population-specific success rates
-- 2. Include cost analysis by linking to claims or billing data
-- 3. Analyze seasonal patterns in care plan success rates
-- 4. Compare success rates across different healthcare providers or facilities
-- 5. Add risk adjustment based on patient comorbidities

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:07:48.852517
    - Additional Notes: Query tracks care plan completion rates and duration patterns which can help identify successful treatment approaches. Note that the 10-plan minimum threshold may need adjustment based on dataset size, and completion rates should be interpreted alongside clinical context.
    
    */