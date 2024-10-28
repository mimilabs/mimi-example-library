
/*
Title: Core Hospital Financial and Operational Metrics Analysis

Business Purpose:
This query analyzes key financial and operational metrics for hospitals using CMS cost report data.
It provides insights into:
- Hospital size and utilization (beds, discharges, occupancy)
- Financial performance (revenue, costs, margins) 
- Operational efficiency (cost-to-charge ratios)
- Uncompensated care metrics

The results can be used to:
- Benchmark hospital performance
- Identify trends and patterns
- Support healthcare policy analysis
- Inform strategic planning
*/

SELECT
    -- Hospital identification
    hospital_name,
    provider_type,
    state_code,
    rural_versus_urban,
    
    -- Size metrics
    number_of_beds,
    fte_employees_on_payroll,
    
    -- Utilization metrics
    total_discharges_v_xviii_xix_unknown as total_discharges,
    ROUND(total_days_v_xviii_xix_unknown / NULLIF(total_bed_days_available, 0) * 100, 1) 
        as occupancy_rate,
    
    -- Financial metrics (in millions)
    ROUND(total_patient_revenue / 1000000, 1) as total_patient_revenue_mm,
    ROUND(net_patient_revenue / 1000000, 1) as net_patient_revenue_mm,
    ROUND(total_costs / 1000000, 1) as total_costs_mm,
    ROUND(net_income / 1000000, 1) as net_income_mm,
    ROUND((net_income / NULLIF(net_patient_revenue, 0)) * 100, 1) as operating_margin_pct,
    
    -- Efficiency metrics
    ROUND(cost_to_charge_ratio, 3) as cost_to_charge_ratio,
    
    -- Uncompensated care metrics (in millions) 
    ROUND(cost_of_uncompensated_care / 1000000, 1) as uncompensated_care_mm,
    ROUND((cost_of_uncompensated_care / NULLIF(total_costs, 0)) * 100, 1) 
        as uncompensated_care_pct_of_cost

FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos

-- Filter for most recent complete year
WHERE YEAR(fiscal_year_end_date) = 2022

-- Remove invalid/incomplete records
AND total_costs > 0
AND net_patient_revenue > 0
AND number_of_beds > 0

ORDER BY total_costs DESC;

/*
How it works:
1. Selects core metrics across key operational dimensions
2. Calculates derived metrics like occupancy rate and margins
3. Converts large dollar amounts to millions for readability
4. Filters for most recent complete year and valid records
5. Orders by hospital size (total costs) to highlight largest facilities

Assumptions & Limitations:
- Assumes 2022 data is complete and representative
- Excludes records with zero/null values for key metrics
- Does not account for hospital system relationships
- Limited to Medicare-participating hospitals filing cost reports

Possible Extensions:
1. Add year-over-year trend analysis
2. Include geographic grouping/analysis
3. Add peer group comparisons by hospital type
4. Incorporate quality metrics correlation
5. Add statistical distributions and outlier analysis
6. Expand uncompensated care analysis
7. Add wage index and market factors
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:03:05.849331
    - Additional Notes: Query assumes availability of 2022 cost report data. Results may be skewed if a significant portion of hospitals have zero values in key metrics like total_costs, net_patient_revenue, or number_of_beds. Consider setting different thresholds for filtering based on specific analysis needs.
    
    */