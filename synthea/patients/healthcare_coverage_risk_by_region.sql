-- Healthcare Utilization and Financial Risk Analysis
-- =========================================================
--
-- Business Purpose:
-- This analysis identifies patients with high healthcare expenses but limited coverage,
-- helping healthcare organizations prioritize outreach for financial counseling and
-- assistance programs. It also highlights geographic areas that may need additional
-- support services or insurance coverage options.
--
-- Created: 2024-03-01
-- Modified: 2024-03-01

WITH RiskMetrics AS (
    -- Calculate coverage ratio and risk indicators
    SELECT 
        state,
        county,
        id,
        healthcare_expenses,
        healthcare_coverage,
        CASE 
            WHEN healthcare_expenses > 0 
            THEN ROUND(healthcare_coverage / healthcare_expenses, 2)
            ELSE NULL
        END as coverage_ratio,
        CASE 
            WHEN healthcare_expenses > healthcare_coverage 
            THEN 'Under-covered'
            ELSE 'Adequately-covered'
        END as coverage_status
    FROM mimi_ws_1.synthea.patients
    WHERE healthcare_expenses > 0
)

SELECT 
    state,
    county,
    -- Calculate key metrics per region
    COUNT(DISTINCT id) as patient_count,
    ROUND(AVG(healthcare_expenses), 2) as avg_expenses,
    ROUND(AVG(coverage_ratio), 2) as avg_coverage_ratio,
    SUM(CASE WHEN coverage_status = 'Under-covered' THEN 1 ELSE 0 END) as undercovered_patients,
    ROUND(SUM(CASE WHEN coverage_status = 'Under-covered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as pct_undercovered
FROM RiskMetrics
GROUP BY state, county
HAVING COUNT(DISTINCT id) >= 10  -- Filter for meaningful sample sizes
ORDER BY pct_undercovered DESC

--
-- How it works:
-- 1. Creates a CTE to calculate coverage ratios and risk status for each patient
-- 2. Aggregates metrics by geographic region
-- 3. Filters for regions with sufficient sample size
-- 4. Orders results by percentage of under-covered patients
--
-- Assumptions and limitations:
-- - Assumes healthcare_expenses > 0 represents valid data
-- - Does not account for time-based variations in coverage
-- - Geographic analysis limited to available state/county data
-- - Minimum threshold of 10 patients per region may need adjustment
--
-- Possible extensions:
-- 1. Add demographic segmentation (age groups, race, gender)
-- 2. Include temporal analysis to identify trends
-- 3. Incorporate zip code level analysis for more granular insights
-- 4. Add risk scoring based on multiple factors
-- 5. Calculate potential revenue impact of improving coverage
--
-- Expected Impact:
-- This analysis enables healthcare organizations to:
-- - Target financial assistance programs more effectively
-- - Identify geographic areas needing additional insurance options
-- - Support community health planning initiatives
-- - Optimize resource allocation for patient financial services

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:09:26.441752
    - Additional Notes: Query requires minimum of 10 patients per region for statistical significance. Coverage ratio calculations exclude patients with zero healthcare expenses. Results are most useful for organizations with comprehensive geographic and financial data across multiple regions.
    
    */