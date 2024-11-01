-- medicare_inpatient_procedures.sql
-- 
-- Business Purpose:
-- Analyzes top inpatient procedures to understand surgical patterns across hospitals.
-- This analysis helps:
-- 1. Identify high-volume surgical procedures for resource planning
-- 2. Track variations in surgical patterns across providers
-- 3. Support clinical quality improvement initiatives
-- 4. Guide strategic planning for surgical service lines

WITH procedure_counts AS (
    -- Get top procedures removing nulls and grouping similar codes
    SELECT 
        icd_prcdr_cd1 as procedure_code,
        prvdr_num,
        COUNT(*) as procedure_count,
        COUNT(DISTINCT bene_id) as unique_patients,
        AVG(clm_pmt_amt) as avg_payment,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY clm_pmt_amt) as median_payment,
        AVG(DATEDIFF(clm_thru_dt, clm_from_dt)) as avg_los
    FROM mimi_ws_1.synmedpuf.inpatient
    WHERE icd_prcdr_cd1 IS NOT NULL 
    GROUP BY icd_prcdr_cd1, prvdr_num
),

provider_ranks AS (
    -- Rank providers by procedure volume
    SELECT 
        procedure_code,
        prvdr_num,
        procedure_count,
        unique_patients,
        avg_payment,
        median_payment,
        avg_los,
        ROW_NUMBER() OVER (PARTITION BY procedure_code ORDER BY procedure_count DESC) as volume_rank
    FROM procedure_counts
)

SELECT 
    procedure_code,
    COUNT(DISTINCT prvdr_num) as total_providers,
    SUM(procedure_count) as total_procedures,
    SUM(unique_patients) as total_patients,
    ROUND(AVG(avg_payment), 2) as mean_payment,
    ROUND(AVG(median_payment), 2) as overall_median_payment,
    ROUND(AVG(avg_los), 1) as average_length_of_stay,
    -- Calculate concentration metrics
    ROUND(SUM(CASE WHEN volume_rank <= 5 THEN procedure_count ELSE 0 END) * 100.0 / 
          SUM(procedure_count), 1) as top5_provider_share
FROM provider_ranks
GROUP BY procedure_code
HAVING total_procedures >= 100
ORDER BY total_procedures DESC
LIMIT 20;

-- Query Operation:
-- 1. Creates a CTE to aggregate procedure counts and metrics by provider
-- 2. Adds provider volume rankings for each procedure
-- 3. Summarizes key metrics across all providers for each procedure
-- 4. Filters to procedures with meaningful volume and sorts by total count

-- Assumptions & Limitations:
-- 1. Only considers primary procedures (icd_prcdr_cd1)
-- 2. Requires minimum volume threshold of 100 procedures
-- 3. Limited to top 20 procedures by volume
-- 4. Synthetic data may not reflect real procedure patterns

-- Possible Extensions:
-- 1. Add procedure descriptions and clinical categories
-- 2. Include complication rates and readmissions
-- 3. Compare costs across geographic regions
-- 4. Analyze seasonal patterns in procedure volume
-- 5. Link to specific diagnosis codes
-- 6. Segment by patient demographics
-- 7. Track trends over time
-- 8. Add quality metrics like mortality rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:11:16.127957
    - Additional Notes: Query focuses on procedure volumes and payments, using primary procedures only. May need index optimization if running on large datasets due to multiple window functions and aggregations. Consider partitioning by date range if analyzing multiple years of data.
    
    */