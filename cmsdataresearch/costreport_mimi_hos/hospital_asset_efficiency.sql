-- Hospital Asset Utilization and Investment Analysis
-- Business Purpose: This query analyzes hospitals' asset utilization and investment patterns to understand:
-- - How effectively hospitals deploy their fixed assets like buildings and equipment
-- - Capital investment strategies across different hospital types and regions
-- - Asset efficiency metrics to evaluate operational performance
-- This helps identify opportunities for asset optimization, investment planning, and operational efficiency.

WITH asset_metrics AS (
    SELECT 
        fiscal_year_begin_date,
        hospital_name,
        state_code,
        provider_type,
        type_of_control,
        
        -- Asset utilization metrics
        total_assets,
        fixed_equipment,
        major_movable_equipment,
        buildings,
        total_costs,
        
        -- Calculate key ratios
        CASE 
            WHEN NULLIF(total_assets, 0) IS NOT NULL 
            THEN total_costs / total_assets 
            ELSE NULL 
        END AS asset_turnover_ratio,
        
        CASE 
            WHEN NULLIF(total_assets, 0) IS NOT NULL 
            THEN (fixed_equipment + major_movable_equipment + buildings) / total_assets 
            ELSE NULL 
        END AS fixed_asset_ratio,
        
        -- Technology investment indicator
        health_information_technology_designated_assets,
        
        -- Size indicator
        number_of_beds
    FROM mimi_ws_1.cmsdataresearch.costreport_mimi_hos
    WHERE fiscal_year_begin_date >= '2020-01-01'
    AND total_assets > 0
)

SELECT 
    state_code,
    provider_type,
    COUNT(DISTINCT hospital_name) as hospital_count,
    
    -- Asset utilization metrics
    ROUND(AVG(asset_turnover_ratio), 2) as avg_asset_turnover,
    ROUND(AVG(fixed_asset_ratio), 2) as avg_fixed_asset_ratio,
    
    -- Technology investment
    ROUND(AVG(health_information_technology_designated_assets), 0) as avg_hit_investment,
    
    -- Size and scale metrics
    ROUND(AVG(number_of_beds), 0) as avg_beds,
    ROUND(AVG(total_assets), 0) as avg_total_assets,
    
    -- Asset composition
    ROUND(AVG(fixed_equipment), 0) as avg_fixed_equipment,
    ROUND(AVG(major_movable_equipment), 0) as avg_movable_equipment,
    ROUND(AVG(buildings), 0) as avg_building_value

FROM asset_metrics
GROUP BY state_code, provider_type
HAVING COUNT(DISTINCT hospital_name) >= 3  -- Ensure meaningful aggregation
ORDER BY state_code, provider_type;

-- How it works:
-- 1. Creates a CTE with calculated asset utilization metrics for each hospital
-- 2. Aggregates metrics by state and provider type to show patterns
-- 3. Includes only recent data (2020 onwards) to reflect current asset deployment
-- 4. Calculates key ratios to evaluate asset efficiency
-- 5. Groups results to show meaningful patterns while protecting individual hospital data

-- Assumptions and Limitations:
-- 1. Assumes accuracy of reported asset values in cost reports
-- 2. Limited to hospitals with complete asset data (non-zero total assets)
-- 3. Does not account for differences in accounting methods between hospitals
-- 4. Aggregated view may mask individual hospital variations
-- 5. Recent data may be affected by COVID-19 impacts

-- Possible Extensions:
-- 1. Add trend analysis over multiple years to show investment patterns
-- 2. Include more detailed analysis of technology investments
-- 3. Add peer group comparisons based on hospital size/type
-- 4. Incorporate quality metrics to relate asset utilization to outcomes
-- 5. Add regional economic indicators to contextualize investment patterns

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:16:04.230239
    - Additional Notes: Query focuses on capital deployment efficiency and may need adjustment of the fiscal_year_begin_date filter based on data availability. The asset_turnover_ratio and fixed_asset_ratio calculations assume positive, non-zero total_assets values and may need validation for specific use cases.
    
    */