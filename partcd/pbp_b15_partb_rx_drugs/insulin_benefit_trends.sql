-- medicare_insuling_coverage_trends.sql
-- Business Purpose:
-- Analyze trends in Medicare Part B insulin coverage across Medicare Advantage plans
-- to identify shifts in benefit design and cost sharing approaches after the 
-- Inflation Reduction Act implementation. This helps understand market response
-- to policy changes and informs strategy around insulin benefit offerings.

WITH insulin_coverage AS (
    -- Get core insulin coverage metrics by plan
    SELECT 
        bid_id,
        pbp_a_plan_type,
        orgtype,
        mrx_b_ira_copay_yn AS has_insulin_copay,
        mrx_b_ira_coins_yn AS has_insulin_coinsurance,
        mrx_b_ira_copay_month_amt AS monthly_insulin_cap,
        mrx_b_ira_deduct_yn AS insulin_counts_to_deductible,
        TO_DATE(mimi_src_file_date) AS data_date
    FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs
    WHERE mimi_src_file_date IS NOT NULL
),

summary_stats AS (
    -- Calculate key metrics by plan type and date
    SELECT 
        data_date,
        pbp_a_plan_type,
        COUNT(DISTINCT bid_id) AS total_plans,
        ROUND(AVG(CASE WHEN has_insulin_copay = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_copay,
        ROUND(AVG(CASE WHEN has_insulin_coinsurance = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_with_coinsurance,
        ROUND(AVG(CASE WHEN monthly_insulin_cap IS NOT NULL THEN monthly_insulin_cap ELSE 0 END), 2) AS avg_monthly_cap,
        ROUND(AVG(CASE WHEN insulin_counts_to_deductible = 'Y' THEN 1 ELSE 0 END) * 100, 1) AS pct_counting_to_deductible
    FROM insulin_coverage
    GROUP BY data_date, pbp_a_plan_type
)

-- Final output showing insulin coverage trends
SELECT 
    data_date,
    pbp_a_plan_type,
    total_plans,
    pct_with_copay,
    pct_with_coinsurance,
    avg_monthly_cap,
    pct_counting_to_deductible
FROM summary_stats
ORDER BY data_date DESC, total_plans DESC;

/* How this query works:
1. First CTE extracts core insulin coverage attributes from the source table
2. Second CTE calculates summary statistics by plan type and date
3. Final output presents the metrics in a time series format

Assumptions and limitations:
- Assumes mimi_src_file_date represents the effective date of the benefit design
- Null values in monthly_insulin_cap are treated as 0 for averaging
- Does not account for mid-year benefit changes
- Limited to basic coverage metrics without detailed cost sharing analysis

Possible extensions:
1. Add geographic analysis by joining with contract service area data
2. Compare insulin coverage patterns between different organization types
3. Include pre/post IRA implementation comparison
4. Add star rating correlation analysis
5. Incorporate enrollment data to weight the analysis by plan size
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:50:25.960160
    - Additional Notes: Query focuses on temporal patterns in Medicare Advantage insulin coverage and may need date range parameters for specific time period analysis. Monthly cap calculations treat nulls as zeros which could impact averages if there's significant missing data.
    
    */