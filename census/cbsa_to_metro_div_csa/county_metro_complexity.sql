/* county_metro_specialization.sql

Business Purpose:
Identifies counties that serve multiple metropolitan statistical purposes, such as being 
part of both a CBSA and CSA or having special metropolitan division designations. 
This analysis helps understand:
- Areas with complex economic interconnections
- Counties that may have unique regulatory or reporting requirements
- Opportunities for cross-market business strategies
*/

WITH county_metro_roles AS (
    SELECT 
        state_name,
        county_county_equivalent,
        -- Count distinct types of metro associations
        COUNT(DISTINCT cbsa_code) as num_cbsa,
        COUNT(DISTINCT metropolitan_division_code) as num_metro_div,
        COUNT(DISTINCT csa_code) as num_csa,
        -- Create flag for multi-role counties
        CASE 
            WHEN COUNT(DISTINCT metropolitan_division_code) > 0 THEN 'Has Metro Division'
            WHEN COUNT(DISTINCT csa_code) > 0 THEN 'Part of CSA Only'
            ELSE 'Standard CBSA Only'
        END as metro_role
    FROM mimi_ws_1.census.cbsa_to_metro_div_csa
    GROUP BY state_name, county_county_equivalent
)

SELECT 
    state_name,
    metro_role,
    COUNT(*) as county_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY state_name), 1) as pct_of_state
FROM county_metro_roles
GROUP BY state_name, metro_role
HAVING COUNT(*) > 1
ORDER BY state_name, metro_role;

/* How it works:
1. Creates a CTE that analyzes each county's participation in different metro structures
2. Calculates counts of different metro associations per county
3. Assigns a role category based on the highest level of metro structure involved
4. Summarizes results by state and role type with percentage calculations

Assumptions and Limitations:
- Assumes current CBSA/CSA definitions are stable
- Does not account for population or economic size differences
- Metro division presence is considered the highest level of specialization

Possible Extensions:
1. Add time-based analysis using mimi_src_file_date to track role changes
2. Include population data to weight the importance of specialized counties
3. Create tiers of specialization based on number of associations
4. Compare central vs outlying county specialization patterns
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:24:15.146830
    - Additional Notes: Query focuses on identifying counties with multiple metropolitan roles, which is useful for regional economic analysis and business planning. Consider adding economic indicators or demographic data for more comprehensive analysis of these specialized metropolitan areas.
    
    */