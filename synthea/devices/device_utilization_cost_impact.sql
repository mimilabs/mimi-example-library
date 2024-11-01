/*
Title: Implant Device Lifecycle Cost Analysis

Business Purpose:
- Identify high-value medical device implant patterns to optimize purchasing
- Track device utilization lifecycle for budget forecasting
- Support contract negotiations with device manufacturers
- Enable value-based purchasing decisions through patient outcome correlation
*/

WITH base_metrics AS (
    -- Calculate base metrics per device type
    SELECT 
        description,
        code,
        COUNT(*) as device_count,
        COUNT(DISTINCT patient) as unique_patients,
        COUNT(DISTINCT encounter) as procedure_count,
        AVG(DATEDIFF(COALESCE(stop, CURRENT_DATE), start)) as avg_days_used
    FROM mimi_ws_1.synthea.devices
    WHERE start IS NOT NULL
    GROUP BY description, code
),

cost_impact_metrics AS (
    -- Calculate derived financial metrics
    SELECT 
        description,
        code,
        device_count,
        unique_patients,
        procedure_count,
        ROUND(avg_days_used, 1) as avg_days_used,
        ROUND(device_count * avg_days_used / 365.0, 2) as annual_device_years,
        ROUND((device_count * avg_days_used * unique_patients) / 
            (SELECT MAX(device_count * avg_days_used * unique_patients) FROM base_metrics) * 100, 2
        ) as relative_cost_impact
    FROM base_metrics
)

SELECT 
    description as device_type,
    device_count as total_devices,
    unique_patients,
    procedure_count,
    avg_days_used,
    annual_device_years,
    relative_cost_impact
FROM cost_impact_metrics
WHERE device_count > 5  -- Focus on frequently used devices
ORDER BY relative_cost_impact DESC
LIMIT 20;

/*
How it works:
1. First CTE calculates basic metrics including average duration per device type
2. Second CTE computes derived financial impact metrics
3. Final query presents top devices by calculated cost impact

Assumptions & Limitations:
- Assumes longer duration = higher cost impact
- Doesn't include actual device costs (not in dataset)
- Missing maintenance/replacement costs
- Doesn't account for device complexity or risk levels

Possible Extensions:
1. Add patient demographic analysis for targeted cost management
2. Include encounter type analysis for procedure cost allocation
3. Add time-based trending for seasonal budget planning
4. Join with outcomes data to calculate device ROI
5. Add geographic analysis for regional cost variations
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:28:35.478726
    - Additional Notes: Query performs device cost impact analysis based on utilization patterns and patient coverage. Cost calculations are relative/normalized since actual device costs are not available. Best used for comparative analysis and strategic planning rather than absolute cost calculations. Performance may be impacted with very large datasets due to window functions in cost impact calculations.
    
    */