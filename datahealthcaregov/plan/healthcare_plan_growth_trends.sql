-- Healthcare.gov Plan Longitudinal Growth Analysis
-- =============================================
-- Business Purpose: 
-- Analyze the growth and evolution of health plans over time to identify market expansion
-- patterns and plan sustainability. This helps stakeholders understand market dynamics
-- and plan retention rates on the healthcare.gov marketplace.

-- First, let's do a basic count of plans per year
WITH yearly_stats AS (
    SELECT 
        EXTRACT(YEAR FROM last_updated_on) as year,
        COUNT(DISTINCT plan_id) as total_plans,
        COUNT(DISTINCT network) as network_types,
        COUNT(DISTINCT CASE WHEN marketing_url IS NOT NULL THEN plan_id END) as plans_with_marketing
    FROM mimi_ws_1.datahealthcaregov.plan
    WHERE last_updated_on IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM last_updated_on)
),

-- Calculate year-over-year changes
growth_analysis AS (
    SELECT 
        year,
        total_plans,
        network_types,
        plans_with_marketing,
        ROUND((total_plans - LAG(total_plans) OVER (ORDER BY year)) * 100.0 / 
            NULLIF(LAG(total_plans) OVER (ORDER BY year), 0), 1) as yoy_growth_rate,
        ROUND(plans_with_marketing * 100.0 / NULLIF(total_plans, 0), 1) as digital_presence_rate
    FROM yearly_stats
)

SELECT 
    year,
    total_plans,
    network_types,
    digital_presence_rate || '%' as digital_presence_rate,
    COALESCE(yoy_growth_rate || '%', 'N/A') as yoy_growth_rate,
    plans_with_marketing
FROM growth_analysis
ORDER BY year;

-- How this query works:
-- 1. First CTE aggregates basic yearly statistics including total plans and network types
-- 2. Second CTE calculates year-over-year growth and digital presence metrics
-- 3. Final SELECT formats the results with proper labels and percentages

-- Assumptions and Limitations:
-- - Relies on last_updated_on field for temporal analysis
-- - Growth calculations may be affected by data completeness
-- - Digital presence is measured by presence of marketing_url

-- Possible Extensions:
-- 1. Add network type distribution analysis
-- 2. Include seasonal patterns within years
-- 3. Analyze correlation between digital presence and plan longevity
-- 4. Add geographical analysis using plan_id patterns
-- 5. Compare growth patterns across different plan types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:26:57.878108
    - Additional Notes: The query focuses on year-over-year growth trends and digital presence of healthcare plans. Key metrics include total plans, network diversity, and marketing presence rates. The analysis relies heavily on the last_updated_on field, so results may be affected if this field is not consistently populated across all records.
    
    */