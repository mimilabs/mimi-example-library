-- Title: Medicare Opt-Out Provider Year-Over-Year Trend Analysis

-- Business Purpose:
-- This query tracks the yearly changes in Medicare opt-out provider counts,
-- helping stakeholders understand longitudinal trends and potential shifts
-- in provider participation. This information is crucial for:
-- 1. Healthcare policy planning
-- 2. Network adequacy forecasting
-- 3. Understanding provider sentiment towards Medicare participation
-- 4. Resource allocation for provider engagement initiatives

WITH yearly_trends AS (
    -- Calculate yearly totals and running comparisons
    SELECT 
        YEAR(optout_effective_date) as opt_year,
        COUNT(DISTINCT npi) as provider_count,
        COUNT(DISTINCT CASE WHEN eligible_to_order_and_refer = 'Y' THEN npi END) as referring_provider_count,
        COUNT(DISTINCT specialty) as specialty_count,
        ROUND(AVG(DATEDIFF(optout_end_date, optout_effective_date))/365.0, 1) as avg_opt_duration_years
    FROM mimi_ws_1.datacmsgov.optout
    WHERE optout_effective_date IS NOT NULL
    GROUP BY opt_year
),

yoy_comparison AS (
    -- Calculate year-over-year changes
    SELECT 
        t1.opt_year,
        t1.provider_count,
        t1.referring_provider_count,
        t1.specialty_count,
        t1.avg_opt_duration_years,
        ROUND(((t1.provider_count - LAG(t1.provider_count) OVER (ORDER BY t1.opt_year)) * 100.0 / 
            NULLIF(LAG(t1.provider_count) OVER (ORDER BY t1.opt_year), 0)), 1) as yoy_growth_pct
    FROM yearly_trends t1
)

SELECT 
    opt_year as Year,
    provider_count as Total_Providers,
    referring_provider_count as Referring_Providers,
    specialty_count as Unique_Specialties,
    avg_opt_duration_years as Avg_OptOut_Duration_Years,
    COALESCE(yoy_growth_pct, 0) as YoY_Growth_Pct
FROM yoy_comparison
ORDER BY opt_year DESC;

-- How the Query Works:
-- 1. Creates a yearly summary of opt-out providers using optout_effective_date
-- 2. Calculates key metrics including total providers, referring providers, and specialties
-- 3. Computes year-over-year growth percentages
-- 4. Presents results in a clear, chronological format

-- Assumptions and Limitations:
-- 1. Assumes optout_effective_date is the primary indicator of when a provider opted out
-- 2. Does not account for providers who may have opted out multiple times
-- 3. Growth calculations may be affected by data completeness in earlier years
-- 4. Assumes all records in the database are valid and current

-- Possible Extensions:
-- 1. Add geographical segmentation to track regional trends
-- 2. Include specialty-specific trend analysis
-- 3. Add seasonality analysis for opt-out timing
-- 4. Incorporate provider demographic information for deeper insights
-- 5. Add forecasting elements based on historical trends

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:13:23.286988
    - Additional Notes: Query provides year-over-year trend analysis of Medicare opt-out providers. Key limitations include: sensitivity to data completeness in historical records, and potential impact of provider re-enrollments not being separately tracked. Best used for annual strategic planning and policy analysis purposes.
    
    */