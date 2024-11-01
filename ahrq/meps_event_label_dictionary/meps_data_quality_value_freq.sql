-- Title: MEPS Variable Value Frequency Analysis for Data Quality Assessment
-- Business Purpose: 
-- This query analyzes the frequency and consistency of variable values across years
-- to identify potential data quality issues and support data validation efforts.
-- Understanding value distributions helps ensure reliable analytics and research.

WITH value_year_counts AS (
    -- Count occurrences of each value-description pair by year
    SELECT 
        varname,
        value,
        value_desc,
        year,
        COUNT(*) as yearly_count
    FROM mimi_ws_1.ahrq.meps_event_label_dictionary
    GROUP BY varname, value, value_desc, year
),

value_consistency AS (
    -- Analyze consistency of value-description mappings across years
    SELECT 
        varname,
        value,
        value_desc,
        COUNT(DISTINCT year) as years_present,
        MIN(year) as first_year,
        MAX(year) as last_year,
        SUM(yearly_count) as total_occurrences
    FROM value_year_counts
    GROUP BY varname, value, value_desc
)

SELECT 
    varname,
    COUNT(DISTINCT value) as unique_values,
    COUNT(DISTINCT value_desc) as unique_descriptions,
    AVG(years_present) as avg_years_present,
    SUM(CASE WHEN last_year - first_year + 1 != years_present THEN 1 ELSE 0 END) as discontinuous_values,
    MAX(total_occurrences) as max_occurrences
FROM value_consistency
GROUP BY varname
ORDER BY unique_values DESC, avg_years_present DESC
LIMIT 20;

-- How this query works:
-- 1. First CTE counts occurrences of each value-description combination by year
-- 2. Second CTE analyzes the temporal consistency of these mappings
-- 3. Final query summarizes variable-level statistics for data quality assessment

-- Assumptions and Limitations:
-- - Assumes value-description mappings should be consistent across years
-- - Does not account for intentional changes in coding schemes
-- - Limited to top 20 variables by complexity (unique values)

-- Possible Extensions:
-- 1. Add detailed analysis of value-description inconsistencies within variables
-- 2. Include category-specific analysis to identify variations by event type
-- 3. Compare value distributions across different files (filename column)
-- 4. Add temporal trend analysis for specific important variables
-- 5. Create data quality score based on consistency metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:29:38.361183
    - Additional Notes: Query focuses on identifying data dictionary consistency and quality issues across survey years. Best used for data validation and metadata analysis workflows. Consider memory usage when running across large year ranges.
    
    */