-- [facility_affiliation_trends.sql] -- Temporal Analysis of Clinician Facility Affiliations

/*
Business Purpose:
This query analyzes changes in facility affiliations over time to identify:
- Growth/decline in specific facility types
- Seasonal patterns in affiliations
- Stability of clinician-facility relationships
This information helps healthcare organizations with workforce planning and network adequacy.
*/

WITH monthly_counts AS (
    -- Get monthly facility type counts, preserving individual affiliations
    SELECT 
        DATE_TRUNC('month', mimi_src_file_date) as report_month,
        facility_type,
        COUNT(DISTINCT npi) as clinician_count,
        COUNT(DISTINCT facility_affiliations_certification_number) as facility_count,
        COUNT(*) as total_affiliations
    FROM mimi_ws_1.provdatacatalog.dac_fa
    WHERE facility_type IS NOT NULL
    GROUP BY 1, 2
),

growth_calc AS (
    -- Calculate month-over-month changes
    SELECT 
        report_month,
        facility_type,
        clinician_count,
        facility_count,
        total_affiliations,
        LAG(clinician_count) OVER (PARTITION BY facility_type ORDER BY report_month) as prev_clinician_count,
        ROUND(100.0 * (clinician_count - LAG(clinician_count) OVER (PARTITION BY facility_type ORDER BY report_month)) 
            / NULLIF(LAG(clinician_count) OVER (PARTITION BY facility_type ORDER BY report_month), 0), 2) as mom_growth
    FROM monthly_counts
)

SELECT 
    report_month,
    facility_type,
    clinician_count,
    facility_count,
    total_affiliations,
    mom_growth,
    -- Flag significant changes
    CASE 
        WHEN ABS(mom_growth) >= 10 THEN 'Significant Change'
        WHEN ABS(mom_growth) >= 5 THEN 'Moderate Change'
        ELSE 'Stable'
    END as change_category
FROM growth_calc
ORDER BY report_month DESC, facility_type;

/*
How it works:
1. First CTE aggregates data by month and facility type
2. Second CTE calculates month-over-month growth rates
3. Final query adds categorization of changes

Assumptions and Limitations:
- Assumes mimi_src_file_date represents actual affiliation dates
- Doesn't account for data quality issues or reporting delays
- Growth calculations may be affected by missing months

Possible Extensions:
1. Add geographic dimension (state/region) to track local trends
2. Include specialty analysis to identify high-demand areas
3. Create rolling averages to smooth out monthly variations
4. Add forecasting capabilities using historical patterns
5. Compare against market events or regulatory changes
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:52:50.099876
    - Additional Notes: Query tracks month-over-month changes in clinician-facility relationships and flags significant variations. Best used with at least 3 months of historical data for meaningful trend analysis. Growth calculations may show as null for the first month of each facility type due to LAG function behavior.
    
    */