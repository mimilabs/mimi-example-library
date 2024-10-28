
/*******************************************************************************
Title: Hospital Operating Cost Analysis Query
 
Business Purpose:
This query analyzes key hospital operating cost metrics from CMS cost reports to:
- Calculate total operating costs for hospitals
- Compare costs across hospitals 
- Track how costs change over time
- Identify major cost drivers and trends

The results help stakeholders understand hospital financial performance and 
cost management opportunities.
*******************************************************************************/

-- Get total operating costs by hospital and fiscal year
WITH operating_costs AS (
  SELECT 
    rpt_rec_num,
    -- Extract year from file date for trending
    YEAR(mimi_src_file_date) as report_year,
    -- Sum costs from Worksheet A (Hospital Operating Costs)
    SUM(CASE 
      WHEN wksht_cd = 'A' 
      AND line_num = 200 -- Total operating costs line
      AND clmn_num = 1   -- Amount column
      THEN itm_val_num
      ELSE 0
    END) as total_operating_cost
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
  GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
)

SELECT
  report_year,
  COUNT(DISTINCT rpt_rec_num) as num_hospitals,
  ROUND(AVG(total_operating_cost),2) as avg_operating_cost,
  ROUND(MIN(total_operating_cost),2) as min_operating_cost, 
  ROUND(MAX(total_operating_cost),2) as max_operating_cost,
  ROUND(STDDEV(total_operating_cost),2) as stddev_operating_cost
FROM operating_costs
WHERE total_operating_cost > 0 -- Filter out invalid/missing data
GROUP BY report_year
ORDER BY report_year;

/*******************************************************************************
How this query works:
1. CTE extracts operating costs from Worksheet A line 200 for each hospital
2. Main query calculates summary statistics by year
3. Results show cost trends and variation across hospitals

Assumptions & Limitations:
- Assumes Worksheet A line 200 represents total operating costs
- Only includes records with positive costs
- Limited to basic cost metrics - doesn't break down by department/category
- Does not account for hospital size, type, location etc.

Possible Extensions:
1. Add hospital characteristics (size, teaching status, etc) for segmentation
2. Calculate cost per bed or other unit metrics
3. Break down costs by department using different worksheet lines
4. Add geographic analysis by state/region
5. Create year-over-year growth calculations
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:34:55.797460
    - Additional Notes: Query focuses on operating costs from Worksheet A line 200, which may not capture all cost components. Results should be validated against other financial metrics and worksheets for a complete financial analysis. The report_year is derived from mimi_src_file_date which may not align with actual hospital fiscal years.
    
    */