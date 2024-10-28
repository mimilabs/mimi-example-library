
/*******************************************************************************
Title: NHANES Language Usage and Acculturation Analysis
 
Business Purpose:
This query analyzes language preferences and acculturation patterns among survey
respondents to understand:
- Primary languages spoken at home
- Language usage patterns across different contexts
- Level of English vs non-English language usage

This insight helps healthcare providers and policymakers:
- Better serve diverse populations
- Identify potential language barriers to healthcare access
- Develop culturally appropriate services and communications
*******************************************************************************/

-- Main analysis of language usage patterns
WITH language_summary AS (
  SELECT
    -- Analyze home language usage
    acd040,
    COUNT(*) as respondent_count,
    
    -- Calculate percentage within total respondents
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
    
  FROM mimi_ws_1.cdc.nhanes_qre_acculturation
  WHERE acd040 IS NOT NULL -- Filter out missing responses
  GROUP BY acd040
)

SELECT 
  CASE acd040
    WHEN 1 THEN 'Only Spanish'
    WHEN 2 THEN 'More Spanish than English' 
    WHEN 3 THEN 'Both Equally'
    WHEN 4 THEN 'More English than Spanish'
    WHEN 5 THEN 'Only English'
    ELSE 'Other/Unknown'
  END as language_preference,
  respondent_count,
  percentage as pct_of_total,
  
  -- Add visual representation of distribution
  REPEAT('■', CAST(percentage/2 AS INT)) as distribution_viz

FROM language_summary
ORDER BY acd040;

/*******************************************************************************
How this query works:
1. Creates a summary table of language preferences from acd040 field
2. Calculates counts and percentages for each preference level
3. Adds readable labels and visual distribution representation
4. Orders results by the original category codes

Assumptions & Limitations:
- Focuses only on Spanish-English language dynamics
- Assumes acd040 coding follows standard NHANES categories
- Missing or invalid responses are excluded
- Single time point analysis (doesn't show trends over time)

Possible Extensions:
1. Add demographic breakdowns (age, gender, etc.)
2. Compare language preferences across different contexts (home vs friends)
3. Analyze correlation with parents' birth country
4. Track changes over different survey cycles
5. Include analysis of other languages beyond Spanish
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:57:18.410685
    - Additional Notes: Query provides baseline language preference distribution but currently only categorizes Spanish-English dynamics. Results should be interpreted within the context of NHANES survey methodology and coding schemes. Chart visualization using ASCII characters may need adjustment based on client display capabilities.
    
    */