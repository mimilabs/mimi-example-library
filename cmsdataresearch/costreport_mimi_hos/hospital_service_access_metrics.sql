-- Hospital Quality and Care Accessibility Assessment
-- Business Purpose: This query analyzes hospital quality, care accessibility, and community service metrics to assess:
-- - How effectively hospitals serve their local populations through volume and bed utilization 
-- - The mix of payment sources (Medicare/Medicaid/other) indicating population access
-- - Hospital capacity and availability through bed metrics
-- - Key volume indicators showing market reach and community service levels

WITH base_metrics AS (
  SELECT 
    hospital_name,
    state_code,
    city,
    provider_type,
    -- Calculate bed utilization
    CAST(total_days_v_xviii_xix_unknown AS FLOAT) / NULLIF(total_bed_days_available, 0) AS bed_occupancy_rate,
    
    -- Calculate payer mix percentages
    CAST(total_days_title_xviii AS FLOAT) / NULLIF(total_days_v_xviii_xix_unknown, 0) AS medicare_days_pct,
    CAST(total_days_title_xix AS FLOAT) / NULLIF(total_days_v_xviii_xix_unknown, 0) AS medicaid_days_pct,
    
    -- Volume metrics
    number_of_beds,
    total_discharges_v_xviii_xix_unknown AS total_discharges,
    total_days_v_xviii_xix_unknown AS total_patient_days,
    
    -- Calculate average length of stay
    CAST(total_days_v_xviii_xix_unknown AS FLOAT) / 
    NULLIF(total_discharges_v_xviii_xix_unknown, 0) AS avg_length_of_stay

  FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos
  WHERE fiscal_year_end_date >= '2020-01-01'  -- Focus on recent data
    AND number_of_beds > 0  -- Exclude invalid records
    AND total_days_v_xviii_xix_unknown > 0
)

SELECT
  state_code,
  COUNT(DISTINCT hospital_name) AS hospital_count,
  ROUND(AVG(bed_occupancy_rate) * 100, 1) AS avg_bed_occupancy_rate,
  ROUND(AVG(medicare_days_pct) * 100, 1) AS avg_medicare_days_pct,
  ROUND(AVG(medicaid_days_pct) * 100, 1) AS avg_medicaid_days_pct,
  ROUND(AVG(number_of_beds), 0) AS avg_beds,
  ROUND(AVG(total_discharges), 0) AS avg_annual_discharges,
  ROUND(AVG(avg_length_of_stay), 1) AS avg_length_of_stay
FROM base_metrics
GROUP BY state_code
ORDER BY hospital_count DESC;

/* How this query works:
1. Creates base metrics CTE to calculate key hospital performance indicators
2. Focuses on recent fiscal years to ensure relevance
3. Calculates percentages and rates using NULLIF to avoid division by zero
4. Aggregates metrics by state to show geographic patterns
5. Rounds results appropriately for business usage

Assumptions and limitations:
- Assumes fiscal_year_end_date represents the most recent full year of data
- Limited to hospitals with valid bed counts and patient days
- Occupancy calculations assume even distribution of patient days
- Does not account for seasonal variations or special hospital designations
- Medicare/Medicaid percentages may not sum to 100% due to other payers

Possible extensions:
1. Add urban/rural comparisons by incorporating rural_versus_urban field
2. Break down metrics by provider_type to compare different hospital categories  
3. Add year-over-year trend analysis using fiscal_year_end_date
4. Include quality metrics by incorporating readmission or mortality data
5. Add geographic clustering analysis using medicare_cbsa_number
6. Compare metrics across hospital ownership types using type_of_control
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:24:06.000305
    - Additional Notes: Query focuses on accessibility and service delivery metrics like bed utilization and payer mix rather than financial performance. Best used for analyzing healthcare access patterns and capacity utilization across different regions. Requires recent fiscal year data (2020+) and valid bed/patient day counts for meaningful results.
    
    */