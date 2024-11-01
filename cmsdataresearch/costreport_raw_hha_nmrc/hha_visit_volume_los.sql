-- Title: Home Health Agency Annual Visit Volume and Length of Stay Analysis

-- Business Purpose:
-- This query analyzes HHA visit patterns and average length of stay to:
-- - Understand patient care intensity and resource allocation
-- - Compare visit volumes across different service types 
-- - Support capacity planning and staffing decisions
-- - Identify trends in care delivery patterns

WITH visit_metrics AS (
    -- Extract visit counts and length of stay from Worksheet S3 Part I
    SELECT 
        rpt_rec_num,
        YEAR(mimi_src_file_date) as reporting_year,
        -- Total Unduplicated Census Count (Line 2)
        MAX(CASE WHEN wksht_cd = 'S3' AND line_num = 2 AND clmn_num = 4 
            THEN itm_val_num ELSE 0 END) as total_patients,
        -- Total Number of Visits (Line 5)
        MAX(CASE WHEN wksht_cd = 'S3' AND line_num = 5 AND clmn_num = 4 
            THEN itm_val_num ELSE 0 END) as total_visits,
        -- Average Length of Stay (Line 4)
        MAX(CASE WHEN wksht_cd = 'S3' AND line_num = 4 AND clmn_num = 4 
            THEN itm_val_num ELSE 0 END) as avg_length_of_stay
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'S3' 
    AND line_num IN (2,4,5)
    AND clmn_num = 4
    GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
)

SELECT 
    reporting_year,
    COUNT(DISTINCT rpt_rec_num) as num_agencies,
    ROUND(AVG(total_patients),0) as avg_patients_per_agency,
    ROUND(AVG(total_visits),0) as avg_visits_per_agency,
    ROUND(AVG(avg_length_of_stay),1) as avg_length_of_stay_days,
    ROUND(AVG(total_visits/NULLIF(total_patients,0)),1) as avg_visits_per_patient
FROM visit_metrics
WHERE total_patients > 0  -- Exclude invalid records
GROUP BY reporting_year
ORDER BY reporting_year DESC;

-- How the Query Works:
-- 1. Creates CTE to extract key metrics from Worksheet S3
-- 2. Uses CASE statements to pivot specific line items into columns
-- 3. Aggregates data annually with key volume and utilization metrics
-- 4. Calculates per-agency and per-patient averages

-- Assumptions and Limitations:
-- - Assumes data in Worksheet S3 is reported consistently
-- - Does not account for partial year reporting
-- - May include agencies with unusual patient volumes
-- - Limited to basic volume metrics without case mix adjustment

-- Possible Extensions:
-- 1. Add visit breakdowns by service type (nursing, therapy, etc.)
-- 2. Segment by agency size or geographic region
-- 3. Include quality metrics correlation analysis
-- 4. Add year-over-year growth calculations
-- 5. Incorporate case mix index adjustments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:10:12.179260
    - Additional Notes: Query focuses on core visit volume and length of stay metrics from Worksheet S3. Care should be taken when interpreting results for agencies with partial year reporting or those with extreme outlier values. The total_patients > 0 filter is critical to avoid division by zero errors in the visits per patient calculation.
    
    */