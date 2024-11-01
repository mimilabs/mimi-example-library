-- provider_gender_diversity.sql
-- Business Purpose: Analyze gender diversity among healthcare providers to:
-- 1. Identify potential gender representation gaps across specialties
-- 2. Support initiatives for balanced provider workforce
-- 3. Enable patient choice preferences for gender-specific care needs

WITH gender_specialty_summary AS (
    -- Calculate provider counts and percentages by gender and specialty
    SELECT 
        specialty,
        gender,
        COUNT(*) as provider_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY specialty), 1) as gender_pct
    FROM mimi_ws_1.datahealthcaregov.provider_base
    WHERE 
        gender IS NOT NULL 
        AND specialty IS NOT NULL
        -- Use most recent data snapshot
        AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datahealthcaregov.provider_base)
    GROUP BY 
        specialty,
        gender
    HAVING 
        COUNT(*) >= 10 -- Filter for meaningful sample sizes
)

SELECT 
    specialty,
    -- Format gender distribution metrics
    SUM(CASE WHEN gender = 'F' THEN provider_count ELSE 0 END) as female_providers,
    SUM(CASE WHEN gender = 'M' THEN provider_count ELSE 0 END) as male_providers,
    SUM(CASE WHEN gender = 'F' THEN gender_pct ELSE 0 END) as female_pct,
    SUM(CASE WHEN gender = 'M' THEN gender_pct ELSE 0 END) as male_pct,
    -- Calculate gender balance indicator
    ABS(SUM(CASE WHEN gender = 'F' THEN gender_pct ELSE 0 END) - 50) as pct_from_balance
FROM gender_specialty_summary
GROUP BY specialty
-- Focus on specialties with notable gender gaps
HAVING pct_from_balance >= 20
ORDER BY pct_from_balance DESC;

-- How this works:
-- 1. Creates a CTE to calculate provider counts and percentages by gender/specialty
-- 2. Filters for valid gender and specialty values using the latest data
-- 3. Aggregates results to show gender distribution by specialty
-- 4. Identifies specialties with significant gender imbalance (>20% from 50/50)

-- Assumptions & Limitations:
-- 1. Relies on accurate and complete gender data reporting
-- 2. Binary gender categories may not capture full gender diversity
-- 3. Minimum threshold of 10 providers per specialty for statistical relevance
-- 4. Based on latest data snapshot only - no historical trending

-- Possible Extensions:
-- 1. Add geographic dimension to identify regional variations
-- 2. Track changes in gender distribution over time
-- 3. Cross-reference with patient demographics and preferences
-- 4. Include facility type analysis to identify institutional patterns
-- 5. Combine with provider age/experience data for generational insights

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:12:35.900522
    - Additional Notes: Query specifically focuses on healthcare specialties with significant gender imbalances (>20% deviation from equal representation). Useful for DEI initiatives and workforce planning, but requires minimum of 10 providers per specialty for statistical validity. Consider timezone settings when running against latest data snapshot.
    
    */