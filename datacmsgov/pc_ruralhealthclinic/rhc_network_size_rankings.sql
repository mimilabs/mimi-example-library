-- rhc_provider_network_analysis.sql

-- Business Purpose:
-- This query analyzes the network characteristics of Rural Health Clinics (RHCs) 
-- by examining relationships between enrollment IDs, PAC IDs, and CCNs to help:
-- - Identify network structures and potential consolidation patterns
-- - Understand the complexity of RHC provider networks
-- - Support network adequacy and provider access assessments
-- - Guide strategic planning for rural healthcare delivery

WITH network_metrics AS (
    -- Calculate network complexity metrics for each PAC ID
    SELECT 
        associate_id,
        COUNT(DISTINCT enrollment_id) as enrollment_count,
        COUNT(DISTINCT ccn) as facility_count,
        COUNT(DISTINCT organization_name) as org_name_count,
        ARRAY_JOIN(COLLECT_SET(state), ', ') as operating_states
    FROM mimi_ws_1.datacmsgov.pc_ruralhealthclinic
    GROUP BY associate_id
),
ranked_networks AS (
    -- Identify significant networks by size
    SELECT 
        nm.*,
        r.organization_name as primary_org_name,
        RANK() OVER (ORDER BY nm.facility_count DESC) as network_size_rank
    FROM network_metrics nm
    LEFT JOIN mimi_ws_1.datacmsgov.pc_ruralhealthclinic r 
        ON nm.associate_id = r.associate_id
    WHERE nm.facility_count > 1
    QUALIFY ROW_NUMBER() OVER (PARTITION BY nm.associate_id ORDER BY r.mimi_src_file_date DESC) = 1
)

SELECT 
    network_size_rank,
    associate_id as network_id,
    primary_org_name,
    facility_count,
    enrollment_count,
    org_name_count,
    operating_states,
    CASE 
        WHEN facility_count >= 10 THEN 'Large Network'
        WHEN facility_count >= 5 THEN 'Medium Network'
        ELSE 'Small Network'
    END as network_size_category
FROM ranked_networks
WHERE network_size_rank <= 20
ORDER BY network_size_rank;

-- How it works:
-- 1. First CTE aggregates key network metrics for each PAC ID
-- 2. Second CTE ranks networks by size and adds organization names
-- 3. Final query presents top 20 networks with categorization
-- 4. Results show network characteristics like facility count and geographic spread

-- Assumptions and Limitations:
-- - PAC ID (associate_id) represents a meaningful business entity
-- - Current organization names are representative of the network
-- - Networks are stable over time (using latest organization name)
-- - Focus on multi-facility networks only

-- Possible Extensions:
-- 1. Add temporal analysis to track network growth over time
-- 2. Include ownership type analysis from related owner tables
-- 3. Add geographic concentration metrics
-- 4. Compare network characteristics across states
-- 5. Analyze changes in network composition over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:08:40.020893
    - Additional Notes: Query identifies and ranks healthcare networks based on facility count, with primary focus on multi-facility organizations. The COLLECT_SET/ARRAY_JOIN functions are Spark SQL specific alternatives to STRING_AGG. Results are limited to top 20 networks by size, providing a focused view of the largest rural health clinic networks.
    
    */