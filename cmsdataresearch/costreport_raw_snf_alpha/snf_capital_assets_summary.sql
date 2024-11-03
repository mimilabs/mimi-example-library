-- SNF Capital Expenditure Analysis - Investment Patterns and Asset Management
-- ================================================================

-- Business Purpose:
-- ---------------
-- This query analyzes capital expenditure and asset management patterns of Skilled Nursing Facilities to:
-- - Understand investment in building improvements and equipment
-- - Evaluate capital-related costs and depreciation 
-- - Identify patterns in facility modernization efforts
-- - Compare fixed asset values and maintenance expenses

WITH base_assets AS (
    -- Extract building and equipment related data
    SELECT 
        rpt_rec_num,
        wksht_cd,
        line_num,
        clmn_num,
        itm_alphnmrc_itm_txt,
        mimi_src_file_date
    FROM mimi_ws_1.cmsdataresearch.costreport_raw_snf_alpha
    WHERE wksht_cd IN ('A7', 'A8') -- Capital asset worksheets
        AND line_num IN ('1', '2', '3', '4', '5') -- Key asset categories
        AND mimi_src_file_date >= '2020-01-01'
),

provider_assets AS (
    -- Organize asset information by provider
    SELECT 
        rpt_rec_num,
        mimi_src_file_date,
        MAX(CASE WHEN wksht_cd = 'A7' AND line_num = '1' AND clmn_num = '1' 
            THEN itm_alphnmrc_itm_txt END) as land_value,
        MAX(CASE WHEN wksht_cd = 'A7' AND line_num = '2' AND clmn_num = '1' 
            THEN itm_alphnmrc_itm_txt END) as building_value,
        MAX(CASE WHEN wksht_cd = 'A8' AND line_num = '1' AND clmn_num = '1' 
            THEN itm_alphnmrc_itm_txt END) as equipment_value
    FROM base_assets
    GROUP BY rpt_rec_num, mimi_src_file_date
)

-- Final summary with key capital metrics
SELECT 
    DATE_TRUNC('year', mimi_src_file_date) as report_year,
    COUNT(DISTINCT rpt_rec_num) as num_facilities,
    COUNT(CASE WHEN building_value IS NOT NULL THEN rpt_rec_num END) as facilities_with_building_data,
    COUNT(CASE WHEN equipment_value IS NOT NULL THEN rpt_rec_num END) as facilities_with_equipment_data,
    AVG(CASE 
        WHEN REGEXP_REPLACE(building_value, '[^0-9.]', '') != '' 
        THEN CAST(REGEXP_REPLACE(building_value, '[^0-9.]', '') AS DECIMAL(18,2))
        END) as avg_building_value,
    AVG(CASE 
        WHEN REGEXP_REPLACE(equipment_value, '[^0-9.]', '') != ''
        THEN CAST(REGEXP_REPLACE(equipment_value, '[^0-9.]', '') AS DECIMAL(18,2))
        END) as avg_equipment_value
FROM provider_assets
WHERE building_value IS NOT NULL 
  AND equipment_value IS NOT NULL
  AND REGEXP_REPLACE(building_value, '[^0-9.]', '') != ''
  AND REGEXP_REPLACE(equipment_value, '[^0-9.]', '') != ''
GROUP BY DATE_TRUNC('year', mimi_src_file_date)
ORDER BY report_year;

-- How this works:
-- 1. First CTE extracts relevant capital asset data from worksheets A7 and A8
-- 2. Second CTE organizes the data by provider, pivoting key asset values
-- 3. Final query summarizes capital metrics by year with data completeness checks
-- 4. Uses REGEXP_REPLACE to clean numeric values before casting
-- 5. Includes additional validation to ensure numeric values are present

-- Assumptions and Limitations:
-- - Assumes consistent reporting of asset values across facilities
-- - Limited to basic asset categories (land, building, equipment)
-- - Does not account for differences in depreciation methods
-- - Filters out non-numeric values in final calculations

-- Possible Extensions:
-- 1. Add depreciation analysis from worksheet A8
-- 2. Include maintenance expense trends from worksheet B
-- 3. Compare capital spending patterns by facility size or ownership type
-- 4. Analyze correlation between capital investment and quality metrics
-- 5. Add geographic analysis of investment patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:02:31.263975
    - Additional Notes: Query focuses on analyzing SNF capital assets from worksheets A7/A8 with robust numeric validation. Data cleaning steps may impact completeness if facilities use varying formats for reporting monetary values. Results are aggregated annually and limited to records from 2020 onwards.
    
    */