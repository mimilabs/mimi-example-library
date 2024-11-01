/*
metropolitan_growth_potential.sql

Business Purpose:
Identifies high-potential metropolitan areas for business expansion by analyzing their
integrated economic relationships through CSA connections and metropolitan division structures.
This helps business strategists identify markets with strong regional economic ties and
potential for cross-market growth.

Created by: Healthcare Analytics Team
Last Modified: 2024-02-14
*/

WITH metro_hierarchy AS (
    -- Get distinct metropolitan areas and their structural complexity
    SELECT 
        cbsa_code,
        cbsa_title,
        csa_code,
        csa_title,
        metropolitan_division_code,
        COUNT(DISTINCT county_county_equivalent) as county_count,
        COUNT(DISTINCT metropolitan_division_code) as division_count
    FROM mimi_ws_1.census.cbsa_to_metro_div_csa
    WHERE metropolitan_micropolitan_statistical_area = 'Metropolitan Statistical Area'
    GROUP BY 1,2,3,4,5
),

market_complexity AS (
    -- Calculate market complexity indicators
    SELECT 
        cbsa_title,
        csa_title,
        county_count,
        CASE 
            WHEN division_count > 0 THEN 'Multi-Division'
            ELSE 'Single-Market'
        END as market_structure,
        CASE 
            WHEN csa_code IS NOT NULL THEN 'Part of Larger Economic Region'
            ELSE 'Independent Metro'
        END as regional_integration
    FROM metro_hierarchy
)

SELECT 
    cbsa_title as metropolitan_area,
    market_structure,
    regional_integration,
    county_count as geographic_reach,
    CASE 
        WHEN market_structure = 'Multi-Division' 
        AND regional_integration = 'Part of Larger Economic Region' 
        THEN 'High Growth Potential'
        WHEN market_structure = 'Multi-Division' 
        OR regional_integration = 'Part of Larger Economic Region'
        THEN 'Medium Growth Potential'
        ELSE 'Standard Growth Potential'
    END as expansion_opportunity
FROM market_complexity
ORDER BY county_count DESC, metropolitan_area;

/*
How it works:
1. First CTE identifies metropolitan areas and calculates their structural metrics
2. Second CTE categorizes markets based on division presence and CSA integration
3. Final query assigns growth potential categories based on market complexity

Assumptions and Limitations:
- Only considers Metropolitan Statistical Areas (excludes Micropolitan)
- Assumes market complexity correlates with growth potential
- Does not account for population size or economic indicators
- Based on geographic structure rather than actual market performance

Possible Extensions:
1. Add population data to weight the opportunities
2. Include economic indicators like GDP or employment
3. Create year-over-year comparison to show changing market dynamics
4. Add healthcare-specific metrics like hospital bed counts or physician density
5. Include competitor presence analysis
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:31:28.432607
    - Additional Notes: Query focuses on structural indicators (divisions, CSA connections, county counts) to evaluate metropolitan market potential. Best used for initial market screening rather than final decision-making due to exclusion of economic and demographic metrics.
    
    */