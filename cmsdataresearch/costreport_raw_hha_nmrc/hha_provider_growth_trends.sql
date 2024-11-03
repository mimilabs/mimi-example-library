-- Title: Home Health Agency Provider Growth and Market Entry Analysis

-- Business Purpose:
-- This query analyzes HHA market entry patterns and provider growth trends to:
-- - Track the expansion/contraction of HHA providers over time
-- - Identify geographic areas with new market entrants
-- - Support market opportunity assessment and competitive intelligence
-- - Guide strategic planning for market expansion

WITH provider_timeline AS (
    -- Get unique providers and their first/last reporting periods
    SELECT 
        SUBSTRING(mimi_src_file_name, 1, 6) as provider_id,
        MIN(mimi_src_file_date) as first_report_date,
        MAX(mimi_src_file_date) as last_report_date,
        COUNT(DISTINCT mimi_src_file_date) as total_reports
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_nmrc
    WHERE wksht_cd = 'S1' -- Summary worksheet
    AND line_num = 1 -- Provider identification line
    GROUP BY provider_id
),

annual_provider_counts AS (
    -- Calculate provider counts and growth by year
    SELECT 
        YEAR(first_report_date) as entry_year,
        COUNT(*) as new_providers,
        SUM(COUNT(*)) OVER (ORDER BY YEAR(first_report_date)) as cumulative_providers
    FROM provider_timeline
    GROUP BY YEAR(first_report_date)
)

SELECT 
    entry_year,
    new_providers,
    cumulative_providers,
    ROUND(100.0 * new_providers / cumulative_providers, 2) as pct_market_growth
FROM annual_provider_counts
WHERE entry_year >= 2010 -- Focus on recent history
ORDER BY entry_year;

-- How the Query Works:
-- 1. Creates provider_timeline CTE to identify unique providers and their reporting periods
-- 2. Calculates annual_provider_counts to track new market entrants and cumulative growth
-- 3. Computes final metrics including percentage market growth
-- 4. Filters to recent years for more relevant trend analysis

-- Assumptions and Limitations:
-- - Provider ID is derived from the first 6 characters of the source filename
-- - Assumes continuous operation between first and last report dates
-- - Does not account for mergers, acquisitions, or provider closures
-- - Market exit analysis would require additional validation

-- Possible Extensions:
-- 1. Add geographic analysis by incorporating provider location data
-- 2. Include provider size/volume metrics to weight market impact
-- 3. Compare growth rates across different ownership types
-- 4. Analyze seasonal patterns in market entry timing
-- 5. Calculate market concentration metrics (HHI) over time

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:19:56.362933
    - Additional Notes: Query tracks provider entry and growth patterns using cost report submission dates. Limited to providers active since 2010. Growth calculations may be affected by data lag in cost report submissions and may not reflect real-time market conditions. Provider ID extraction method should be validated against actual provider identification standards.
    
    */