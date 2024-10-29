-- OTP Provider Service Duration Analysis
-- 
-- Business Purpose:
-- - Identify long-standing vs newly enrolled OTP providers to assess program stability
-- - Support provider retention strategies by understanding tenure patterns
-- - Enable targeted outreach to providers based on their experience level
-- - Inform quality metrics by correlating service duration with other factors

WITH provider_tenure AS (
    -- Calculate tenure metrics for each provider
    SELECT 
        provider_name,
        state,
        medicare_id_effective_date,
        _input_file_date,
        -- Calculate months of service
        DATEDIFF(month, medicare_id_effective_date, _input_file_date) as months_enrolled,
        -- Categorize providers by experience
        CASE 
            WHEN DATEDIFF(month, medicare_id_effective_date, _input_file_date) < 12 THEN 'New Provider'
            WHEN DATEDIFF(month, medicare_id_effective_date, _input_file_date) < 36 THEN 'Established Provider'
            ELSE 'Veteran Provider'
        END as provider_experience_level
    FROM mimi_ws_1.datacmsgov.otpp
)

SELECT 
    provider_experience_level,
    COUNT(*) as provider_count,
    AVG(months_enrolled) as avg_months_enrolled,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as percentage_of_total,
    -- Get most common states for each experience level
    CONCAT_WS(', ', COLLECT_SET(state)) as common_states
FROM provider_tenure
GROUP BY provider_experience_level
ORDER BY avg_months_enrolled DESC;

-- How this query works:
-- 1. Creates a CTE to calculate tenure metrics for each provider
-- 2. Categorizes providers into experience levels based on months enrolled
-- 3. Aggregates providers by experience level with key metrics
-- 4. Shows distribution and geographic patterns of provider experience

-- Assumptions and Limitations:
-- - Assumes _input_file_date represents current active status
-- - Does not account for any gaps in service
-- - Categories are arbitrarily defined (could be adjusted based on business needs)
-- - Does not consider provider size or patient volume

-- Possible Extensions:
-- 1. Add correlation with provider size/capacity metrics
-- 2. Include provider retention rate analysis
-- 3. Add geographic clustering of experienced providers
-- 4. Compare with industry benchmarks or targets
-- 5. Include month-over-month change tracking

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:15:12.130905
    - Additional Notes: Query provides insights into provider longevity and experience distribution, but state listing in common_states field may be truncated for providers with presence in many states due to string length limitations. Consider additional filtering or aggregation if state-level analysis is critical.
    
    */