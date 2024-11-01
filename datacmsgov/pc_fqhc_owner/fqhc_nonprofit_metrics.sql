-- fqhc_nonprofit_status_impact.sql

-- Business Purpose:
-- Analyze and compare key characteristics of FQHCs based on their non-profit status to:
-- 1. Identify differences in ownership structure between non-profit and for-profit FQHCs
-- 2. Assess the relationship between non-profit status and ownership percentages
-- 3. Provide insights for policy makers and healthcare administrators on FQHC operational models

WITH base_metrics AS (
    -- Get the latest snapshot for each FQHC
    SELECT DISTINCT
        organization_name,
        enrollment_id,
        associate_id,
        non_profit_owner,
        percentage_ownership,
        type_owner,
        role_text_owner
    FROM mimi_ws_1.datacmsgov.pc_fqhc_owner
    QUALIFY ROW_NUMBER() OVER (PARTITION BY enrollment_id ORDER BY mimi_src_file_date DESC) = 1
),

ownership_summary AS (
    -- Calculate ownership metrics by non-profit status
    SELECT 
        CASE 
            WHEN non_profit_owner = 'Y' THEN 'Non-Profit'
            WHEN non_profit_owner = 'N' THEN 'For-Profit'
            ELSE 'Unspecified'
        END AS ownership_category,
        COUNT(DISTINCT enrollment_id) as total_fqhcs,
        AVG(CAST(percentage_ownership AS DECIMAL(10,2))) as avg_ownership_percentage,
        COUNT(DISTINCT CASE WHEN type_owner = 'I' THEN enrollment_id END) as individual_owned_count,
        COUNT(DISTINCT CASE WHEN type_owner = 'O' THEN enrollment_id END) as org_owned_count
    FROM base_metrics
    GROUP BY 
        CASE 
            WHEN non_profit_owner = 'Y' THEN 'Non-Profit'
            WHEN non_profit_owner = 'N' THEN 'For-Profit'
            ELSE 'Unspecified'
        END
)

-- Final output combining key metrics
SELECT 
    ownership_category,
    total_fqhcs,
    avg_ownership_percentage,
    individual_owned_count,
    org_owned_count,
    ROUND(individual_owned_count * 100.0 / total_fqhcs, 2) as pct_individual_owned,
    ROUND(org_owned_count * 100.0 / total_fqhcs, 2) as pct_org_owned
FROM ownership_summary
ORDER BY total_fqhcs DESC;

-- How the Query Works:
-- 1. base_metrics CTE gets the most recent snapshot of FQHC data
-- 2. ownership_summary CTE calculates key metrics by non-profit status
-- 3. Final SELECT combines and formats the results with percentage calculations

-- Assumptions and Limitations:
-- 1. Assumes non_profit_owner field is consistently populated
-- 2. Only considers the most recent snapshot for each FQHC
-- 3. Does not account for mixed ownership structures
-- 4. May not reflect temporal changes in ownership status

-- Possible Extensions:
-- 1. Add geographic analysis to compare non-profit distribution by state
-- 2. Include financial metrics comparison between profit statuses
-- 3. Analyze correlation between non-profit status and specific owner roles
-- 4. Track changes in profit status over time
-- 5. Compare service offerings between non-profit and for-profit FQHCs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:06:46.249095
    - Additional Notes: The query provides an overview of FQHC metrics segmented by profit status, focusing on ownership percentages and distribution of individual vs organizational ownership. Note that the results are based on the most recent snapshot only and may not reflect historical changes in ownership structure.
    
    */