
/*******************************************************************************
Title: Medical Supply Usage Analysis - Core Business Metrics
 
Business Purpose:
This query analyzes the fundamental patterns in medical supply usage to help:
- Optimize inventory management and supply chain
- Identify most frequently used supplies for procurement planning
- Understand supply consumption patterns across time
- Support cost analysis and budgeting decisions

Written by: AI Assistant
Created on: 2024-02-13
*******************************************************************************/

-- Main query analyzing supply usage patterns
SELECT 
    -- Extract month and year for temporal analysis
    DATE_TRUNC('month', date) as usage_month,
    
    -- Get supply details
    description as supply_name,
    code as supply_code,
    
    -- Calculate key metrics
    COUNT(DISTINCT patient) as unique_patients,
    COUNT(DISTINCT encounter) as total_encounters,
    SUM(quantity) as total_quantity_used,
    
    -- Calculate average usage per encounter
    ROUND(SUM(quantity)::DECIMAL / COUNT(DISTINCT encounter), 2) as avg_quantity_per_encounter

FROM mimi_ws_1.synthea.supplies

WHERE 
    -- Focus on recent data
    date >= DATE_TRUNC('year', CURRENT_DATE) - INTERVAL '1 year'
    AND quantity > 0  -- Exclude zero quantity records

GROUP BY 
    DATE_TRUNC('month', date),
    description,
    code

-- Order by most used supplies first
ORDER BY 
    total_quantity_used DESC,
    usage_month

LIMIT 100;

/*******************************************************************************
How This Query Works:
1. Aggregates supply usage data monthly
2. Calculates key metrics: unique patients, encounters, total quantity
3. Computes average usage per encounter
4. Focuses on the most frequently used supplies

Assumptions and Limitations:
- Assumes quantity values are recorded consistently
- Limited to last 12 months of data
- Top 100 results only
- Does not account for supply costs
- Does not segment by department/facility

Possible Extensions:
1. Add supply costs and financial analysis:
   - JOIN with a price table
   - Calculate total costs and cost per encounter

2. Add demographic analysis:
   - JOIN with patients table
   - Analyze usage patterns by age, gender, location

3. Add seasonality analysis:
   - Compare usage patterns across different seasons
   - Identify seasonal trends for better inventory planning

4. Add department/specialty breakdown:
   - JOIN with encounters table
   - Analyze usage patterns by medical specialty

5. Add inventory management metrics:
   - Calculate reorder points
   - Predict future demand
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:57:39.125906
    - Additional Notes: Query provides a rolling 12-month view of supply utilization patterns. For optimal performance, ensure indexes exist on date, code, and quantity columns. Results are limited to top 100 supplies by quantity - adjust LIMIT clause if more comprehensive analysis is needed.
    
    */