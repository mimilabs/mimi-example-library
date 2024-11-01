-- ownership_concentration_analysis.sql

-- Business Purpose: Analyze ownership patterns and market concentration of Home Health Agencies
-- by identifying distinct providers and their organizational relationships through
-- cost report submissions. This helps understand market dynamics, consolidation trends,
-- and potential antitrust concerns in the home healthcare sector.

WITH provider_ownership AS (
    -- Extract provider ownership information from worksheet S-2, which contains
    -- organizational structure and control details
    SELECT DISTINCT
        rpt_rec_num,
        MAX(CASE 
            WHEN wksht_cd = 'S200000' 
            AND line_num = '101' 
            AND clmn_num = '1' 
            THEN itm_alphnmrc_itm_txt 
        END) as provider_name,
        MAX(CASE 
            WHEN wksht_cd = 'S200000' 
            AND line_num = '102' 
            AND clmn_num = '1' 
            THEN itm_alphnmrc_itm_txt 
        END) as ownership_type,
        YEAR(mimi_src_file_date) as report_year
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_hha_alpha
    WHERE wksht_cd = 'S200000'
    AND line_num IN ('101', '102')
    GROUP BY rpt_rec_num, YEAR(mimi_src_file_date)
)

SELECT 
    report_year,
    ownership_type,
    COUNT(DISTINCT rpt_rec_num) as provider_count,
    COUNT(DISTINCT rpt_rec_num) * 100.0 / 
        SUM(COUNT(DISTINCT rpt_rec_num)) OVER (PARTITION BY report_year) as market_share_pct
FROM provider_ownership
WHERE ownership_type IS NOT NULL
GROUP BY report_year, ownership_type
ORDER BY report_year DESC, provider_count DESC;

-- How it works:
-- 1. Creates CTE to extract provider names and ownership types from S-2 worksheet
-- 2. Aggregates data by report year and ownership type
-- 3. Calculates market share percentages for each ownership category
-- 4. Orders results chronologically with largest ownership groups first

-- Assumptions and Limitations:
-- - Assumes consistent reporting of ownership information across years
-- - Limited to providers that complete worksheet S-2
-- - May not capture complex ownership structures or partial acquisitions
-- - Market share calculations treat all providers equally regardless of size

-- Possible Extensions:
-- 1. Add geographic dimensions to analyze regional concentration
-- 2. Include provider size metrics (revenue, visits) for weighted market share
-- 3. Track ownership changes over time to identify consolidation patterns
-- 4. Compare ownership concentration with quality metrics
-- 5. Analyze chain vs. independent provider performance metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:15:00.853432
    - Additional Notes: Query focuses on ownership distribution patterns but accuracy depends on consistent S-2 worksheet reporting. Market share calculations are based on provider count rather than revenue or patient volume, which may not reflect true market power. Consider local regulatory requirements when using for market analysis.
    
    */