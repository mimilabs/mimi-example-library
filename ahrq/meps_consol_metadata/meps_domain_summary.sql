-- meps_variable_domains.sql

-- Business Purpose:
-- Identifies key domains and analytical categories in the MEPS dataset by analyzing variable descriptions
-- Helps researchers and healthcare analysts:
-- - Understand the major measurement domains available in MEPS
-- - Plan analyses by seeing what types of variables are available
-- - Make better use of the rich MEPS metadata for research planning

-- Main Query
WITH variable_domains AS (
  SELECT 
    -- Extract key words from descriptions that indicate measurement domains
    CASE 
      WHEN LOWER(desc) LIKE '%expenditure%' THEN 'Expenditure'
      WHEN LOWER(desc) LIKE '%payment%' THEN 'Payment'
      WHEN LOWER(desc) LIKE '%insurance%' THEN 'Insurance'
      WHEN LOWER(desc) LIKE '%condition%' THEN 'Medical Condition'
      WHEN LOWER(desc) LIKE '%utilization%' THEN 'Healthcare Utilization'
      WHEN LOWER(desc) LIKE '%demographic%' THEN 'Demographics'
      WHEN LOWER(desc) LIKE '%employment%' THEN 'Employment'
      ELSE 'Other'
    END AS domain,
    varname,
    desc,
    year
  FROM mimi_ws_1.ahrq.meps_consol_metadata
),
sample_vars AS (
  SELECT 
    domain,
    varname,
    desc,
    ROW_NUMBER() OVER (PARTITION BY domain ORDER BY varname) as rn
  FROM variable_domains
)

SELECT 
  vd.domain,
  COUNT(DISTINCT vd.varname) as variable_count,
  COUNT(DISTINCT vd.year) as years_available,
  -- Get sample variable names for each domain
  MAX(CASE WHEN sv.rn <= 3 THEN CONCAT_WS(', ', sv.varname) END) as sample_variables,
  -- Get brief descriptions
  MAX(CASE WHEN sv.rn <= 2 THEN CONCAT_WS('; ', sv.desc) END) as sample_descriptions
FROM variable_domains vd
LEFT JOIN sample_vars sv ON vd.domain = sv.domain
GROUP BY vd.domain
ORDER BY variable_count DESC;

-- How it works:
-- 1. Uses CASE statement to categorize variables into domains based on description keywords
-- 2. Creates a CTE with row numbers to limit samples per domain
-- 3. Aggregates to show counts and examples for each domain
-- 4. Provides context through sample variables and descriptions

-- Assumptions and Limitations:
-- - Domain classification is based on simple keyword matching
-- - Some variables may be miscategorized due to complex descriptions
-- - Not all possible domains may be captured
-- - Single domain assignment per variable (no multiple domains)

-- Possible Extensions:
-- 1. Add temporal analysis to show how domains evolved over time
-- 2. Create domain-specific deep dives for detailed variable analysis
-- 3. Build cross-domain relationship analysis
-- 4. Add complexity scores based on variable types and descriptions
-- 5. Create domain-specific variable selection recommendations for common research questions

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:04:24.285114
    - Additional Notes: Query segments MEPS variables into analytical domains and provides summary statistics with examples. Note that domain classification relies on simple keyword matching which may miss nuanced categories. The concatenation of sample variables may truncate if variable names are very long.
    
    */