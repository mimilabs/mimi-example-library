-- Group Practice Revalidation Dashboard Core Metrics
--
-- Business Purpose:
-- Provides essential metrics for monitoring Medicare group practice revalidation compliance
-- and network stability. Key uses include:
-- - Tracking upcoming revalidation deadlines and potential compliance risks
-- - Monitoring practice size and provider distribution
-- - Identifying practices with high reassignment volumes that may need additional support
--
-- Core metrics focused on actionable insights for network management and compliance teams.

WITH practice_metrics AS (
    SELECT 
        group_legal_business_name,
        group_state_code,
        group_due_date,
        COUNT(DISTINCT individual_pac_id) as provider_count,
        COUNT(CASE WHEN group_due_date <= DATE_ADD(CURRENT_DATE(), 90) 
                   AND group_due_date != 'TBD' THEN 1 END) as due_next_90_days,
        AVG(individual_total_employer_associations) as avg_employer_associations,
        COUNT(DISTINCT individual_specialty_description) as specialty_count
    FROM mimi_ws_1.datacmsgov.revalidation
    WHERE record_type = 'Reassignment' 
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.datacmsgov.revalidation)
    GROUP BY 1,2,3
)

SELECT 
    group_legal_business_name,
    group_state_code,
    group_due_date,
    provider_count,
    due_next_90_days,
    avg_employer_associations,
    specialty_count,
    CASE 
        WHEN provider_count >= 50 THEN 'Large'
        WHEN provider_count >= 10 THEN 'Medium'
        ELSE 'Small'
    END as practice_size
FROM practice_metrics
WHERE provider_count > 5  -- Focus on established practices
ORDER BY provider_count DESC, due_next_90_days DESC
LIMIT 100;

-- How it works:
-- 1. CTE creates core practice-level metrics using most recent data snapshot
-- 2. Main query adds practice size classification and filters to meaningful groups
-- 3. Results ordered by practice size and revalidation urgency
--
-- Assumptions and Limitations:
-- - Uses only active reassignments from most recent data
-- - Practice size thresholds are simplified for illustration
-- - Limited to practices with >5 providers for meaningful analysis
-- - TBD due dates excluded from 90-day warning counts
--
-- Possible Extensions:
-- 1. Add specialty mix analysis for network adequacy assessment
-- 2. Include month-over-month provider count trends
-- 3. Add geographic clustering analysis
-- 4. Compare individual vs group revalidation timing patterns
-- 5. Create risk scores based on practice size and due date proximity

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:18:22.786316
    - Additional Notes: Query focuses on established practices (>5 providers) and prioritizes tracking of near-term revalidations. The 90-day warning window and practice size thresholds (50+ for large, 10-49 for medium) are configurable parameters that may need adjustment based on specific organizational needs. Results are limited to top 100 practices but can be modified for full dataset analysis.
    
    */