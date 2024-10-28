
/*************************************************************************
MEPS Event Data Analysis - Variable Summary by Event Category
**************************************************************************

Business Purpose:
This query analyzes the MEPS event metadata to provide a comprehensive overview 
of available variables across different medical event categories. This helps
researchers and analysts understand what data points are collected for each
type of medical event, supporting better study design and analysis.

Created: 2024
*************************************************************************/

-- Get summary of variables available for each event category
SELECT 
    category,
    COUNT(DISTINCT varname) as total_variables,
    -- Get count of cost-related variables
    COUNT(DISTINCT CASE 
        WHEN LOWER(desc) LIKE '%cost%' 
        OR LOWER(desc) LIKE '%payment%' 
        OR LOWER(desc) LIKE '%expense%'
        THEN varname
    END) as cost_related_vars_count,
    -- Get first cost-related variable as sample
    MIN(CASE 
        WHEN LOWER(desc) LIKE '%cost%' 
        OR LOWER(desc) LIKE '%payment%' 
        OR LOWER(desc) LIKE '%expense%'
        THEN varname
    END) as sample_cost_var,
    COUNT(DISTINCT year) as years_available
FROM mimi_ws_1.ahrq.meps_event_metadata
GROUP BY category
ORDER BY total_variables DESC;

/*************************************************************************
How this query works:
1. Groups metadata by event category (e.g., inpatient, outpatient)
2. Counts distinct variables to show data coverage
3. Identifies and counts cost-related variables using pattern matching
4. Shows a sample cost-related variable using MIN function
5. Shows number of years data is available
6. Orders results by categories with most variables first

Assumptions & Limitations:
- Assumes consistent naming conventions for cost-related variables
- May not capture all financial variables if differently named
- Limited to metadata - doesn't show actual data availability/quality
- Only shows one sample cost variable per category

Possible Extensions:
1. Add filters for specific years to track variable changes over time
2. Include pattern matching for other variable types (diagnoses, procedures)
3. Cross-reference with actual event tables to show data completeness
4. Add variable type distribution analysis
5. Create summary of standardized variables common across all categories
*************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:23:25.084170
    - Additional Notes: The query provides a high-level overview of variable coverage across MEPS event categories with a focus on cost-related variables. It shows total variable counts, cost variable counts, and data availability by year, making it useful for initial data exploration and research planning. Limited to metadata analysis only and relies on consistent naming patterns for cost-related variables.
    
    */