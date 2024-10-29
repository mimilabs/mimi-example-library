/* Hospital Ownership Concentration Analysis
   
   Business Purpose:
   This query analyzes hospital ownership patterns to identify:
   - Concentration of ownership by organization type
   - Market share of different ownership structures
   - Potential M&A and consolidation trends
   
   Strategic Value:
   - Identify market consolidation opportunities
   - Assess competitive landscape
   - Support investment decisions in healthcare markets
*/

WITH ownership_summary AS (
    -- Calculate key ownership metrics
    SELECT 
        type_owner,
        COUNT(DISTINCT enrollment_id) as hospital_count,
        COUNT(DISTINCT associate_id_owner) as unique_owners,
        AVG(CAST(percentage_ownership AS FLOAT)) as avg_ownership_pct,
        SUM(CASE WHEN corporation_owner = 'Y' THEN 1 ELSE 0 END) as corporate_owners,
        SUM(CASE WHEN investment_firm_owner = 'Y' THEN 1 ELSE 0 END) as investment_firm_owners,
        SUM(CASE WHEN for_profit_owner = 'Y' THEN 1 ELSE 0 END) as for_profit_owners,
        SUM(CASE WHEN non_profit_owner = 'Y' THEN 1 ELSE 0 END) as non_profit_owners
    FROM mimi_ws_1.datacmsgov.pc_hospital_owner
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.datacmsgov.pc_hospital_owner)
    GROUP BY type_owner
)

SELECT 
    type_owner as owner_type,
    hospital_count,
    unique_owners,
    ROUND(hospital_count::FLOAT / unique_owners, 2) as hospitals_per_owner,
    ROUND(avg_ownership_pct, 2) as avg_ownership_percentage,
    corporate_owners,
    investment_firm_owners,
    for_profit_owners,
    non_profit_owners
FROM ownership_summary
ORDER BY hospital_count DESC;

/* How this query works:
   1. Creates a CTE to aggregate ownership metrics
   2. Uses the most recent data snapshot
   3. Calculates key ratios and counts by owner type
   4. Presents results in business-friendly format

   Assumptions & Limitations:
   - Uses latest snapshot only - doesn't show trends over time
   - Assumes ownership percentages are accurately reported
   - May not capture complex ownership structures
   - Does not account for geographic distribution

   Possible Extensions:
   1. Add time series analysis to show ownership trends
   2. Include geographic analysis by state/region
   3. Add filters for specific owner types or ownership thresholds
   4. Calculate market concentration metrics (HHI)
   5. Join with quality metrics to analyze impact of ownership type
   6. Analyze ownership changes and M&A activity
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:45:00.534743
    - Additional Notes: Query shows current snapshot of hospital ownership patterns, focusing on ownership type distribution and concentration metrics. Best used with recent data snapshots. Consider adding WHERE clauses to filter specific time periods or geographic regions for more targeted analysis.
    
    */