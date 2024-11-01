-- hospital_owner_type_transition.sql

/*
Business Purpose:
This query analyzes the evolution of hospital ownership types over time to identify:
- Shifts between individual and organizational ownership
- Changes in ownership structure complexity
- Trends in for-profit vs non-profit ownership transitions

The insights support:
- Healthcare market transformation analysis
- Regulatory compliance monitoring
- Investment strategy development
*/

WITH base_snapshot AS (
    -- Get the latest snapshot for each hospital's ownership structure
    SELECT 
        enrollment_id,
        organization_name,
        type_owner,
        role_text_owner,
        association_date_owner,
        percentage_ownership,
        CASE 
            WHEN for_profit_owner = 'Y' THEN 'For-Profit'
            WHEN non_profit_owner = 'Y' THEN 'Non-Profit'
            ELSE 'Other'
        END AS profit_status,
        mimi_src_file_date
    FROM mimi_ws_1.datacmsgov.pc_hospital_owner
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) FROM mimi_ws_1.datacmsgov.pc_hospital_owner)
),

ownership_changes AS (
    -- Calculate ownership type changes over time
    SELECT 
        enrollment_id,
        COUNT(DISTINCT type_owner) as ownership_type_count,
        MAX(percentage_ownership) as max_ownership_stake,
        CONCAT_WS(', ', COLLECT_SET(profit_status)) as ownership_models,
        COUNT(DISTINCT role_text_owner) as distinct_roles
    FROM base_snapshot
    GROUP BY enrollment_id
)

SELECT 
    CASE 
        WHEN ownership_type_count = 1 AND max_ownership_stake >= 90 THEN 'Single Owner Dominant'
        WHEN ownership_type_count = 1 THEN 'Single Type Multiple Owners'
        ELSE 'Mixed Ownership Structure'
    END AS ownership_pattern,
    ownership_models,
    COUNT(DISTINCT enrollment_id) as hospital_count,
    AVG(distinct_roles) as avg_management_roles,
    AVG(max_ownership_stake) as avg_max_ownership_stake
FROM ownership_changes
GROUP BY 
    CASE 
        WHEN ownership_type_count = 1 AND max_ownership_stake >= 90 THEN 'Single Owner Dominant'
        WHEN ownership_type_count = 1 THEN 'Single Type Multiple Owners'
        ELSE 'Mixed Ownership Structure'
    END,
    ownership_models
ORDER BY hospital_count DESC;

/*
How it works:
1. Creates a base snapshot using the latest available data
2. Analyzes ownership changes and complexity metrics
3. Categorizes hospitals based on ownership patterns
4. Aggregates results to show distribution of ownership structures

Assumptions and Limitations:
- Uses latest snapshot only - historical trends require additional time-based analysis
- Assumes ownership percentages are accurately reported
- May not capture complex ownership structures involving multiple layers
- Limited to direct ownership relationships

Possible Extensions:
1. Add time-series analysis to track ownership pattern changes
2. Include geographic analysis of ownership patterns
3. Analyze relationship between ownership structure and hospital size
4. Add financial performance correlation analysis
5. Include ownership chain analysis for multi-level structures
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:22:22.665358
    - Additional Notes: The query uses COLLECT_SET and CONCAT_WS functions for aggregating ownership types, which are Spark SQL specific functions. The analysis focuses on the latest snapshot only and provides a high-level categorization of hospital ownership patterns based on ownership type count, stake percentage, and profit status. For temporal analysis, the query would need to be modified to include historical data comparisons.
    
    */