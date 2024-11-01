-- Hospital Cost Report Initial vs Final Submission Analysis for Revenue Cycle Impact
--
-- Business Purpose:
-- This analysis helps revenue cycle and finance leaders understand:
-- - The lifecycle of cost report submissions from initial to final versions
-- - Time gaps between initial and final submissions that may impact reimbursement
-- - Patterns in report revisions that could indicate reporting quality issues
-- - Opportunities to improve first-pass accuracy of submissions

WITH submission_pairs AS (
    -- Get pairs of initial and final submissions for each provider/fiscal year
    SELECT 
        prvdr_num,
        fy_bgn_dt,
        fy_end_dt,
        MAX(CASE WHEN initl_rpt_sw = 'Y' THEN proc_dt END) as initial_submission_date,
        MAX(CASE WHEN last_rpt_sw = 'Y' THEN proc_dt END) as final_submission_date,
        prvdr_ctrl_type_cd
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_rpt
    WHERE rpt_stus_cd = '1' -- Only include accepted reports
    GROUP BY prvdr_num, fy_bgn_dt, fy_end_dt, prvdr_ctrl_type_cd
)

SELECT 
    YEAR(fy_bgn_dt) as report_year,
    prvdr_ctrl_type_cd,
    COUNT(*) as total_providers,
    COUNT(CASE WHEN initial_submission_date IS NOT NULL 
              AND final_submission_date IS NOT NULL THEN 1 END) as complete_cycles,
    AVG(DATEDIFF(final_submission_date, initial_submission_date)) as avg_days_to_final,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 
        DATEDIFF(final_submission_date, initial_submission_date)) as median_days_to_final,
    COUNT(CASE WHEN DATEDIFF(final_submission_date, initial_submission_date) > 365 THEN 1 END) 
        as long_cycle_count
FROM submission_pairs
WHERE initial_submission_date IS NOT NULL 
    AND final_submission_date IS NOT NULL
    AND YEAR(fy_bgn_dt) >= 2015
GROUP BY YEAR(fy_bgn_dt), prvdr_ctrl_type_cd
ORDER BY report_year DESC, prvdr_ctrl_type_cd;

-- How this query works:
-- 1. Creates a CTE that pairs initial and final submissions for each provider/fiscal year
-- 2. Calculates key metrics around submission timing
-- 3. Groups results by fiscal year and provider control type to show trends
-- 4. Filters for complete submission cycles only (has both initial and final)

-- Assumptions and limitations:
-- - Assumes rpt_stus_cd = '1' indicates accepted reports
-- - Only includes providers with both initial and final submissions
-- - Limited to fiscal years 2015 and later for relevance
-- - Does not account for amended submissions between initial and final

-- Possible extensions:
-- 1. Add geographic analysis by joining to provider location data
-- 2. Include analysis of intermediate submissions between initial and final
-- 3. Compare submission timing patterns to provider size/revenue
-- 4. Add trend analysis of submission cycle duration over time
-- 5. Correlate submission patterns with reimbursement outcomes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:08:42.296304
    - Additional Notes: Query requires proc_dt and fy_bgn_dt columns to contain valid dates. Performance may be impacted with large date ranges due to the window functions used for percentile calculations. The prvdr_ctrl_type_cd values should be validated against reference data for accurate grouping.
    
    */