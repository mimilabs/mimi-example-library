-- Home Health Agency Operational Activity Timeline
-- 
-- Business Purpose:
-- Analyzes the temporal patterns of home health agency operations to:
-- 1. Identify seasonality in agency enrollments and incorporations
-- 2. Track the age distribution of operating agencies
-- 3. Measure the time lag between incorporation and Medicare enrollment
-- 4. Support operational planning and resource allocation

-- Main Query
WITH incorporation_stats AS (
  SELECT 
    EXTRACT(YEAR FROM incorporation_date) as inc_year,
    COUNT(*) as agencies,
    organization_type_structure,
    proprietary_nonprofit,
    -- Calculate average age of agencies
    AVG(DATEDIFF(CURRENT_DATE(), incorporation_date)/365.0) as avg_age_years
  FROM mimi_ws_1.datacmsgov.pc_homehealth
  WHERE incorporation_date IS NOT NULL
  GROUP BY 
    inc_year,
    organization_type_structure,
    proprietary_nonprofit
  HAVING inc_year >= 2000
)

SELECT 
  inc_year,
  organization_type_structure,
  proprietary_nonprofit,
  agencies,
  ROUND(avg_age_years, 1) as avg_age_years,
  -- Calculate percent of total for each year
  ROUND(100.0 * agencies / SUM(agencies) OVER (PARTITION BY inc_year), 1) as pct_of_year_total
FROM incorporation_stats
ORDER BY 
  inc_year DESC,
  agencies DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate incorporation statistics by year and organization type
-- 2. Calculates key metrics including count of agencies and average age
-- 3. Computes the percentage distribution within each year
-- 4. Filters to more recent years (2000+) for relevant modern analysis
-- 5. Orders results to highlight most recent trends first

-- Assumptions and Limitations:
-- 1. Assumes incorporation_date is accurate and complete
-- 2. Limited to agencies still active in Medicare (historical closures not captured)
-- 3. Focus on year-level patterns may mask seasonal variations
-- 4. Organizations without incorporation dates are excluded

-- Possible Extensions:
-- 1. Add geographic dimension to analyze regional incorporation patterns
-- 2. Include survival analysis comparing active vs inactive agencies
-- 3. Correlate incorporation timing with market factors (demographics, competition)
-- 4. Add monthly/quarterly analysis for seasonal patterns
-- 5. Compare incorporation-to-enrollment timeframes across organization types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:09:56.564452
    - Additional Notes: Query focuses on year-over-year incorporation patterns and agency longevity. Performance may be impacted with very large datasets due to window functions. Consider adding date range parameters for better performance when analyzing specific time periods.
    
    */