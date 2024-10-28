
/*******************************************************************
Title: Top 10 Most Common and Costly Medical Procedures Analysis
 
Business Purpose:
- Identify the most frequently performed medical procedures
- Calculate total financial impact of common procedures
- Support healthcare resource planning and cost management
 
Created: 2024
*******************************************************************/

-- Main analysis query
SELECT 
    p.description as procedure_name,
    -- Calculate key metrics
    COUNT(*) as procedure_count,
    ROUND(AVG(p.base_cost), 2) as avg_cost,
    ROUND(SUM(p.base_cost), 2) as total_cost,
    -- Get date range for procedures
    MIN(date) as first_performed,
    MAX(date) as last_performed
FROM mimi_ws_1.synthea.procedures p
WHERE 
    -- Focus on recent procedures with valid costs
    p.date >= '2020-01-01'
    AND p.base_cost > 0
GROUP BY p.description
ORDER BY procedure_count DESC
LIMIT 10;

/*******************************************************************
How It Works:
1. Groups procedures by their description
2. Calculates frequency counts and cost metrics
3. Shows date range to understand timespan
4. Filters for recent procedures only
5. Orders by frequency to show most common first

Assumptions & Limitations:
- Assumes base_cost is consistently recorded and meaningful
- Limited to procedures from 2020 onwards
- Doesn't account for procedure complexity or duration
- Doesn't segment by patient demographics or facility

Possible Extensions:
1. Add patient demographics analysis:
   - Age groups
   - Gender
   - Geographic location

2. Include temporal analysis:
   - Monthly/seasonal trends
   - Year-over-year growth

3. Enhance cost analysis:
   - Cost variance analysis 
   - Cost by facility type
   - Insurance coverage impact

4. Add clinical context:
   - Related diagnoses
   - Procedure success rates
   - Follow-up procedures
*******************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:59:34.474611
    - Additional Notes: Query focuses on procedures from 2020 onwards and requires valid base_cost values. Results are limited to top 10 procedures by frequency. Base costs should be validated for accuracy before using for financial planning.
    
    */