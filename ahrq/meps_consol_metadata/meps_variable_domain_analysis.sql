-- meps_metadata_insights.sql
-- Business Purpose: Extract Strategic Insights from MEPS Metadata
-- Objective: Provide a comprehensive overview of variable types and descriptions
-- to support healthcare research and data exploration initiatives

WITH variable_domain_summary AS (
    SELECT 
        year,
        -- Categorize variables into strategic domains
        CASE 
            WHEN lower(desc) LIKE '%cost%' OR lower(desc) LIKE '%expenditure%' THEN 'Financial'
            WHEN lower(desc) LIKE '%age%' OR lower(desc) LIKE '%gender%' OR lower(desc) LIKE '%race%' THEN 'Demographic'
            WHEN lower(desc) LIKE '%insurance%' OR lower(desc) LIKE '%coverage%' THEN 'Insurance'
            WHEN lower(desc) LIKE '%health%' OR lower(desc) LIKE '%condition%' THEN 'Clinical'
            ELSE 'Other'
        END AS variable_domain,
        
        -- Count of variables per domain and year
        COUNT(DISTINCT varname) AS unique_variables,
        
        -- Analyze variable type distribution
        COUNT(DISTINCT CASE WHEN vartype = 'numeric' THEN varname END) AS numeric_vars,
        COUNT(DISTINCT CASE WHEN vartype = 'character' THEN varname END) AS character_vars
    
    FROM mimi_ws_1.ahrq.meps_consol_metadata
    
    GROUP BY 
        year, 
        variable_domain
)

SELECT 
    year,
    variable_domain,
    unique_variables,
    numeric_vars,
    character_vars,
    
    -- Calculate percentage of variables in each domain
    ROUND(unique_variables * 100.0 / SUM(unique_variables) OVER (PARTITION BY year), 2) AS domain_percentage
FROM 
    variable_domain_summary
ORDER BY 
    year, 
    unique_variables DESC;

-- Query Explanation:
-- 1. Categorizes MEPS metadata variables into strategic domains
-- 2. Counts unique variables per domain and data type
-- 3. Calculates domain-level variable distribution

-- Assumptions and Limitations:
-- - Relies on keyword matching for domain classification
-- - May not capture all nuanced variable categories
-- - Dependent on consistency of variable descriptions

-- Potential Extensions:
-- 1. Add more granular domain classification
-- 2. Trend analysis of variable types over multiple years
-- 3. Deeper text analysis of variable descriptions

-- Business Value:
-- - Provides quick insight into MEPS dataset composition
-- - Supports research planning and data exploration
-- - Enables rapid understanding of available variables

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:43:48.628183
    - Additional Notes: Query uses pattern matching to categorize MEPS metadata variables into strategic domains. Recommended for initial exploratory analysis of healthcare dataset structure and composition.
    
    */