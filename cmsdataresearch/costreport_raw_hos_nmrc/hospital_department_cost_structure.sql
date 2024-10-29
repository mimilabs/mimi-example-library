-- Hospital Department Cost Structure Analysis
-- Business Purpose: Analyze the cost allocation across different hospital departments
-- to help healthcare organizations and consultants:
-- - Identify highest cost departments and potential optimization areas
-- - Compare departmental cost structures across facilities
-- - Support strategic planning and resource allocation decisions

WITH department_costs AS (
    -- Filter for relevant worksheets containing departmental cost data
    -- Worksheet B Part I contains departmental cost data
    SELECT 
        rpt_rec_num,
        line_num,
        itm_val_num as cost_value,
        mimi_src_file_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_nmrc
    WHERE wksht_cd = 'B1'
        AND clmn_num = 26  -- Total costs after cost allocation
        AND line_num BETWEEN 30 AND 100  -- Range covering major hospital departments
        AND itm_val_num > 0
),

-- Calculate summary metrics by department
dept_summary AS (
    SELECT 
        line_num as dept_code,
        COUNT(DISTINCT rpt_rec_num) as hospital_count,
        AVG(cost_value) as avg_dept_cost,
        STDDEV(cost_value) as cost_std_dev,
        SUM(cost_value) as total_dept_cost
    FROM department_costs
    GROUP BY line_num
)

-- Final output with department cost metrics
SELECT 
    dept_code,
    hospital_count,
    ROUND(avg_dept_cost, 2) as avg_department_cost,
    ROUND(cost_std_dev, 2) as cost_standard_deviation,
    ROUND(total_dept_cost, 2) as total_department_cost,
    ROUND((avg_dept_cost / SUM(avg_dept_cost) OVER()) * 100, 2) as pct_of_total_cost
FROM dept_summary
WHERE hospital_count >= 100  -- Focus on departments with significant representation
ORDER BY avg_department_cost DESC
LIMIT 20;

/* How this query works:
1. Extracts departmental cost data from Worksheet B Part I
2. Focuses on final allocated costs in column 26
3. Calculates key statistical measures for each department
4. Presents results for departments with significant hospital representation

Assumptions and Limitations:
- Assumes worksheet B1 structure is consistent across reports
- Limited to departments with costs reported by at least 100 hospitals
- Does not account for hospital size or case mix differences
- Cost allocation methodologies may vary between hospitals

Possible Extensions:
1. Add geographical analysis by joining with provider location data
2. Compare teaching vs non-teaching hospital department costs
3. Analyze trends over time using mimi_src_file_date
4. Include volume metrics to calculate cost per unit of service
5. Add peer group comparisons based on hospital characteristics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:36:02.788528
    - Additional Notes: Query focuses on hospital departmental cost structure using Worksheet B Part I data. Results show top 20 departments by average cost, excluding departments reported by fewer than 100 hospitals. Line numbers 30-100 should be verified against the latest CMS form specifications to ensure all relevant departments are captured.
    
    */