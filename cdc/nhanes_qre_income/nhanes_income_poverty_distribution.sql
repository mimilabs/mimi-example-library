
/*******************************************************************
Title: NHANES Family Income Sources and Poverty Level Analysis
********************************************************************

Business Purpose:
This query analyzes the relationship between different income sources 
and family poverty levels based on CDC NHANES survey data. It helps
understand the financial wellbeing of families and identify income
patterns across poverty level categories.

Created: 2024-02
*******************************************************************/

-- Main analysis query
WITH income_sources AS (
  SELECT 
    indfmmpc as poverty_level_category,
    -- Calculate percentage receiving each type of income
    ROUND(AVG(CASE WHEN inq020 = 1 THEN 100 ELSE 0 END),1) as pct_wages,
    ROUND(AVG(CASE WHEN inq012 = 1 THEN 100 ELSE 0 END),1) as pct_self_employment,
    ROUND(AVG(CASE WHEN inq030 = 1 THEN 100 ELSE 0 END),1) as pct_social_security,
    ROUND(AVG(CASE WHEN inq090 = 1 THEN 100 ELSE 0 END),1) as pct_ssi,
    ROUND(AVG(CASE WHEN inq132 = 1 THEN 100 ELSE 0 END),1) as pct_welfare,
    COUNT(*) as total_respondents
  FROM mimi_ws_1.cdc.nhanes_qre_income
  WHERE indfmmpc IS NOT NULL
  GROUP BY indfmmpc
)

SELECT
  poverty_level_category,
  total_respondents,
  pct_wages as pct_receiving_wages,
  pct_self_employment as pct_self_employment_income,
  pct_social_security as pct_social_security_income,
  pct_ssi as pct_ssi_income,
  pct_welfare as pct_welfare_income
FROM income_sources
ORDER BY poverty_level_category;

/*******************************************************************
How it works:
1. Creates a CTE to calculate percentages of respondents receiving 
   different types of income within each poverty level category
2. Uses CASE statements to convert Yes/No (1/2) responses to 100/0 
   for percentage calculations
3. Aggregates results by poverty level category 
4. Formats final output with meaningful column names

Assumptions & Limitations:
- Assumes inq* columns use 1=Yes, 2=No coding
- Excludes records with NULL poverty level categories
- Percentages are rounded to 1 decimal place
- Does not account for survey weights or complex sample design

Possible Extensions:
1. Add trend analysis by including mimi_src_file_date
2. Break down by savings levels (inq300/ind310)
3. Include additional income sources like pensions or investments
4. Add statistical testing for differences between groups
5. Create visualization-ready output for poverty level distributions
*******************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:40:39.947879
    - Additional Notes: Query provides percentage breakdowns of income sources across poverty levels, with rounding to 1 decimal place. Does not incorporate survey weights which may be necessary for accurate population-level estimates.
    
    */