-- hospital_geographic_footprint.sql
-- Purpose: Analyze the geographic distribution of hospitals reporting cost data
-- to identify market coverage, gaps, and expansion opportunities.
-- Business Value: Support strategic market planning, network adequacy analysis,
-- and competitive intelligence for healthcare organizations

-- Get distinct hospital locations and counts by state/region
WITH hospital_locations AS (
  SELECT DISTINCT
    rpt_rec_num,
    -- Extract state from address field in worksheet S-2 line 1
    CASE 
      WHEN wksht_cd = 'S200001' 
      AND line_num = 1 
      AND clmn_num = 1
      THEN SUBSTR(itm_alphnmrc_itm_txt, -2) -- Last 2 chars typically state code
    END AS state_code,
    MAX(mimi_src_file_date) as latest_report_date
  FROM mimi_ws_1.cmsdataresearch.costreport_raw_hos_alpha
  WHERE wksht_cd = 'S200001' -- S-2 worksheet contains facility info
  GROUP BY 1,2
)

SELECT
  COALESCE(state_code, 'UNKNOWN') as state,
  COUNT(DISTINCT rpt_rec_num) as num_hospitals,
  MIN(latest_report_date) as earliest_report,
  MAX(latest_report_date) as most_recent_report
FROM hospital_locations
WHERE state_code IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC, 1

-- How this works:
-- 1. First CTE extracts state codes from facility addresses in worksheet S-2
-- 2. Main query aggregates hospitals by state with key metrics
-- 3. Results show geographic distribution and reporting timeframes

-- Assumptions & Limitations:
-- - Assumes state codes are consistently formatted in addresses
-- - Limited to facilities filing CMS cost reports
-- - May not capture all facility locations if address format varies
-- - Some facilities may have multiple reports in different time periods

-- Possible Extensions:
-- 1. Add facility type classification from other worksheets
-- 2. Calculate year-over-year changes in facility counts by region
-- 3. Join with external demographic/market data for deeper analysis
-- 4. Add rural vs urban designation analysis
-- 5. Include bed size or volume metrics for market share analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:43:46.484949
    - Additional Notes: Query extracts state-level hospital distribution from CMS cost report data. Note that state code extraction logic assumes standardized address formatting in worksheet S-2. Results may need validation against reference data for accuracy of state assignments. Consider implementing additional address parsing logic for more reliable geographic classification.
    
    */