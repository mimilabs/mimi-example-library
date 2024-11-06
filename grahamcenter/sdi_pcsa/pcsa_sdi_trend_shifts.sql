-- sdi_trends_analysis.sql
--
-- Business Purpose: Track temporal changes in Social Deprivation Index (SDI) scores 
-- across Primary Care Service Areas (PCSAs) to identify areas experiencing significant 
-- socioeconomic shifts. This information helps healthcare organizations and policymakers 
-- identify emerging high-need areas and adjust resource allocation strategies proactively.

WITH base_years AS (
    -- Get distinct years from the dataset for comparison
    SELECT DISTINCT 
        YEAR(mimi_src_file_date) as data_year
    FROM mimi_ws_1.grahamcenter.sdi_pcsa
    ORDER BY data_year DESC
    LIMIT 2
),

recent_years_data AS (
    -- Get SDI data for the two most recent years
    SELECT 
        p.pcsa_fips,
        p.pcsa_population,
        p.sdi_score,
        YEAR(p.mimi_src_file_date) as data_year
    FROM mimi_ws_1.grahamcenter.sdi_pcsa p
    WHERE YEAR(p.mimi_src_file_date) IN (SELECT data_year FROM base_years)
),

sdi_changes AS (
    -- Calculate year-over-year changes in SDI scores
    SELECT 
        r1.pcsa_fips,
        r1.pcsa_population as recent_population,
        r1.sdi_score as recent_sdi,
        r2.sdi_score as previous_sdi,
        r1.sdi_score - r2.sdi_score as sdi_change,
        ((r1.sdi_score - r2.sdi_score) / NULLIF(r2.sdi_score, 0)) * 100 as sdi_change_pct
    FROM recent_years_data r1
    JOIN recent_years_data r2 
        ON r1.pcsa_fips = r2.pcsa_fips
        AND r1.data_year > r2.data_year
)

SELECT 
    pcsa_fips,
    recent_population,
    recent_sdi,
    previous_sdi,
    ROUND(sdi_change, 2) as sdi_change,
    ROUND(sdi_change_pct, 1) as sdi_change_pct,
    CASE 
        WHEN sdi_change_pct >= 10 THEN 'Significant Increase'
        WHEN sdi_change_pct <= -10 THEN 'Significant Decrease'
        ELSE 'Stable'
    END as trend_category
FROM sdi_changes
WHERE ABS(sdi_change_pct) >= 5  -- Focus on areas with notable changes
ORDER BY ABS(sdi_change_pct) DESC
LIMIT 100;

-- How it works:
-- 1. Identifies the two most recent years in the dataset
-- 2. Pulls SDI scores and population data for these years
-- 3. Calculates absolute and percentage changes in SDI scores
-- 4. Categorizes PCSAs based on the magnitude of change
-- 5. Returns the top 100 areas with the most significant changes

-- Assumptions and Limitations:
-- - Assumes at least two years of data are available
-- - Focuses on relative changes rather than absolute SDI values
-- - Limited to top 100 areas with largest changes
-- - 10% threshold for "significant" change is arbitrary and may need adjustment
-- - Does not account for statistical significance of changes

-- Possible Extensions:
-- 1. Add geographic clustering analysis to identify regional patterns of change
-- 2. Include component score changes to understand drivers of SDI shifts
-- 3. Incorporate longer-term trends using more than two time points
-- 4. Add population-weighted analysis to prioritize high-impact areas
-- 5. Include confidence intervals or statistical significance testing
-- 6. Cross-reference with major economic events or policy changes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:50:45.401324
    - Additional Notes: The query identifies areas experiencing significant socioeconomic changes by comparing SDI scores across years. Note that the 5% and 10% thresholds for change detection may need adjustment based on typical SDI score variations in the target region. The query currently returns top 100 areas but can be modified to show all areas or use different filtering criteria.
    
    */