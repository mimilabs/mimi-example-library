-- Hospital Operating Efficiency and Staff Utilization Analysis

/* Business Purpose:
This analysis examines hospital operational efficiency and staff utilization to help:
- Identify opportunities for operational improvements
- Assess workforce productivity and resource allocation
- Compare staffing models across different hospital types
- Support strategic workforce planning decisions
*/

SELECT
  state,
  -- Group hospitals by operational characteristics
  COUNT(DISTINCT prvdr_num) as hospital_count,
  
  -- Staffing metrics
  AVG(fte_employees_on_payroll) as avg_fte_employees,
  AVG(number_of_interns_and_residents_fte) as avg_resident_ftes,
  AVG(total_salaries_adjusted/NULLIF(fte_employees_on_payroll,0)) as avg_salary_per_fte,
  
  -- Operational efficiency metrics 
  AVG(total_discharges_v_xviii_xix_unknown/NULLIF(fte_employees_on_payroll,0)) as discharges_per_fte,
  AVG(total_days_v_xviii_xix_unknown/NULLIF(fte_employees_on_payroll,0)) as patient_days_per_fte,
  AVG(contract_labor_direct_patient_care/NULLIF(total_salaries_adjusted,0)) as contract_labor_ratio,
  
  -- Volume and utilization 
  AVG(number_of_beds) as avg_beds,
  AVG(total_days_v_xviii_xix_unknown/NULLIF(total_bed_days_available,0)) as bed_utilization_rate

FROM mimi_ws_1.cmsdataresearch.costreport_sas_hos

WHERE 
  -- Focus on most recent complete year
  EXTRACT(YEAR FROM fy_end_dt) = 2022
  AND fte_employees_on_payroll > 0
  AND number_of_beds > 0
  AND total_bed_days_available > 0

GROUP BY state
ORDER BY hospital_count DESC;

/* How this query works:
1. Aggregates key operational and staffing metrics by state
2. Calculates efficiency ratios using FTEs and bed capacity
3. Filters for valid non-zero denominators
4. Groups results by state for comparison

Assumptions and Limitations:
- Uses fiscal year 2022 data for consistency
- Excludes facilities with missing/zero FTE counts
- Contract labor ratio may be incomplete if not all facilities report
- State-level aggregation masks facility-level variation

Possible Extensions:
1. Add provider type dimension to compare across hospital categories
2. Include year-over-year trends to show staffing changes
3. Add financial metrics to correlate with staffing efficiency
4. Create facility-level rankings within each state
5. Segment analysis by rural vs urban status
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:18:39.236465
    - Additional Notes: Query assumes fiscal year 2022 data availability and relies on accurate FTE/bed reporting. The contract labor ratio calculation may need adjustment based on specific reporting practices. Consider hospital size when interpreting state-level averages.
    
    */