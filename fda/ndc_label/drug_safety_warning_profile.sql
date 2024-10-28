
/*******************************************************************************
Title: Basic Drug Label Analysis - Critical Safety Information and Warnings
 
Business Purpose:
This query analyzes drug label data to identify medications with critical safety 
concerns by examining boxed warnings, contraindications, and serious adverse 
reactions. This information is essential for:
- Healthcare providers making informed prescribing decisions
- Pharmaceutical safety monitoring
- Patient safety and education initiatives
*******************************************************************************/

WITH boxed_warning_drugs AS (
  -- Identify drugs with boxed warnings (most serious safety concerns)
  SELECT 
    product_ndc,
    CASE WHEN boxed_warning IS NOT NULL THEN 1 ELSE 0 END as has_boxed_warning
  FROM mimi_ws_1.fda.ndc_label
  WHERE boxed_warning IS NOT NULL
),

safety_profile AS (
  -- Compile key safety information for each drug
  SELECT
    n.product_ndc,
    n.active_ingredient,
    n.contraindications,
    n.warnings,
    n.adverse_reactions,
    b.has_boxed_warning,
    -- Get the most recent label version
    ROW_NUMBER() OVER (PARTITION BY n.product_ndc ORDER BY n.effective_time DESC) as label_version_rank
  FROM mimi_ws_1.fda.ndc_label n
  LEFT JOIN boxed_warning_drugs b ON n.product_ndc = b.product_ndc
  WHERE n.active_ingredient IS NOT NULL
)

-- Final output combining critical safety information
SELECT 
  product_ndc,
  active_ingredient,
  has_boxed_warning,
  CASE 
    WHEN contraindications IS NOT NULL THEN 1 
    ELSE 0 
  END as has_contraindications,
  CASE 
    WHEN warnings IS NOT NULL THEN 1 
    ELSE 0 
  END as has_warnings,
  CASE 
    WHEN adverse_reactions IS NOT NULL THEN 1 
    ELSE 0 
  END as has_adverse_reactions
FROM safety_profile
WHERE label_version_rank = 1  -- Only use most recent label version
ORDER BY has_boxed_warning DESC, product_ndc;

/*******************************************************************************
How this query works:
1. First CTE identifies drugs with boxed warnings (highest level safety concerns)
2. Second CTE compiles comprehensive safety profile for each drug
3. Final query summarizes presence of key safety information
4. Filters to most recent label version to avoid duplicates

Assumptions and Limitations:
- Assumes most recent label (by effective_time) is most relevant
- Binary indicators only show presence/absence of warnings, not severity
- Text content of warnings not analyzed
- Null values treated as absence of warning

Possible Extensions:
1. Add text analysis of warning content to categorize warning types
2. Compare warning profiles across drug classes or manufacturers
3. Track changes in safety warnings over time
4. Join with adverse event data to validate warning patterns
5. Calculate statistics on warning prevalence by drug category
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T16:08:44.864485
    - Additional Notes: Query focuses on presence/absence of critical safety information in drug labels. Results can be used for drug safety monitoring and risk assessment. Note that the query only indicates if warnings exist, not their severity or specific content. For detailed safety analysis, warning text content should be reviewed manually.
    
    */