-- vg_measure_volume_trends.sql

/* Business Purpose: 
   Analyze patient volume and participation trends across virtual groups and measures
   to identify which measures have the highest engagement and potential impact. This helps:
   - Understand which quality measures are most widely reported
   - Identify measures with significant patient populations
   - Guide measure selection and reporting strategies for virtual groups
*/

WITH measure_stats AS (
  -- Calculate key statistics for each measure
  SELECT 
    measure_cd,
    measure_title,
    COUNT(DISTINCT virtual_group_id) as vg_count,
    SUM(patient_count) as total_patients,
    AVG(patient_count) as avg_patients_per_vg,
    MAX(mimi_src_file_date) as latest_report_date
  FROM mimi_ws_1.provdatacatalog.dac_vg_public_reporting
  WHERE patient_count IS NOT NULL 
  GROUP BY 
    measure_cd,
    measure_title
),
ranked_measures AS (
  -- Rank measures by participation and volume
  SELECT 
    *,
    ROW_NUMBER() OVER (ORDER BY vg_count DESC, total_patients DESC) as popularity_rank
  FROM measure_stats
)
SELECT 
  measure_cd,
  measure_title,
  vg_count as participating_virtual_groups,
  total_patients,
  ROUND(avg_patients_per_vg, 2) as avg_patients_per_group,
  popularity_rank,
  latest_report_date
FROM ranked_measures
WHERE popularity_rank <= 10
ORDER BY popularity_rank;

/* How it works:
   1. First CTE aggregates key volume metrics by measure
   2. Second CTE ranks measures based on participation and volume
   3. Final output shows top 10 most widely reported measures

   Assumptions/Limitations:
   - Assumes patient_count is a reliable indicator of measure impact
   - Does not account for measure complexity or clinical significance
   - Limited to measures with patient count data
   
   Possible Extensions:
   - Add trend analysis across reporting periods
   - Include performance rate analysis for top measures
   - Break down by collection type to see preferred reporting methods
   - Add measure category classification
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:51:14.248672
    - Additional Notes: This query focuses on measure adoption patterns and patient volumes, helping identify the most widely-implemented MIPS measures across virtual groups. The results can be particularly valuable for new virtual groups deciding which measures to report on based on established patterns. Note that the analysis excludes measures without patient count data, which might affect completeness for certain measure types like attestations.
    
    */