/*
Hospital Staffing and Labor Cost Analysis

Business Purpose:
This query analyzes hospital staffing levels, labor costs, and productivity metrics to understand:
- Workforce composition and staffing intensity relative to hospital size
- Labor cost structure and efficiency
- Teaching program scale and resident staffing
- Geographic and ownership type variations in staffing models

The insights help:
- Benchmark staffing models and labor costs across hospitals
- Assess teaching program scale and resident staffing patterns
- Identify variations in workforce strategies by hospital characteristics
- Support workforce planning and labor cost management
*/

WITH base_metrics AS (
  SELECT
    hospital_name,
    city,
    state_code,
    provider_type,
    type_of_control,
    rural_versus_urban,
    number_of_beds,
    
    -- Staff metrics
    fte_employees_on_payroll AS total_fte,
    number_of_interns_and_residents_fte AS resident_fte,
    
    -- Labor costs
    total_salaries_adjusted AS adjusted_salaries,
    contract_labor_direct_patient_care AS contract_labor,
    wage_related_costs_core AS core_benefits,
    
    -- Volume metrics 
    total_discharges_v_xviii_xix_unknown AS total_discharges,
    total_days_v_xviii_xix_unknown AS total_patient_days

  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos
  WHERE fiscal_year_end_date >= '2020-01-01'
    AND number_of_beds > 0
    AND fte_employees_on_payroll > 0
)

SELECT
  state_code,
  type_of_control,
  COUNT(*) AS hospital_count,
  
  -- Staffing intensity metrics
  ROUND(AVG(total_fte/number_of_beds),2) AS avg_fte_per_bed,
  ROUND(AVG(resident_fte),1) AS avg_resident_fte,
  
  -- Labor cost metrics 
  ROUND(AVG(adjusted_salaries/total_fte),0) AS avg_salary_per_fte,
  ROUND(AVG(contract_labor/total_fte),0) AS avg_contract_labor_per_fte,
  
  -- Productivity metrics
  ROUND(AVG(total_patient_days/total_fte),1) AS avg_patient_days_per_fte,
  ROUND(AVG(total_discharges/total_fte),1) AS avg_discharges_per_fte

FROM base_metrics
GROUP BY state_code, type_of_control
HAVING hospital_count >= 3
ORDER BY state_code, type_of_control

/*
How this works:
1. Base CTE filters to recent data and valid staffing/bed counts
2. Main query calculates key staffing and productivity ratios
3. Results grouped by state and ownership type with minimum hospital count
4. Metrics normalized by FTEs and beds for comparability

Assumptions & Limitations:
- Relies on accurate FTE and cost reporting
- Contract labor may be inconsistently reported
- Teaching program metrics limited to resident counts
- Does not account for case mix or service line differences

Possible Extensions:
1. Add wage index adjustments for geographic comparisons
2. Break out staffing by department or cost center
3. Analyze staffing seasonality using fiscal year data
4. Compare teaching vs non-teaching staffing models
5. Correlate staffing levels with quality metrics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:39:43.060016
    - Additional Notes: Query requires hospitals to have valid bed counts and FTE data. Minimum of 3 hospitals per state/ownership group required for reporting. Results focus on core workforce metrics without adjusting for case mix or specialty service differences.
    
    */