-- Population Center Distance from State Capital Analysis
-- Business Purpose: Identifies census block groups that are furthest from their state's
-- population center, helping understand population distribution patterns and potential
-- service accessibility challenges. This analysis can inform decisions about resource
-- allocation, infrastructure planning, and service delivery optimization.

WITH state_centers AS (
    -- Calculate the population-weighted center for each state
    SELECT 
        statefp,
        SUM(latitude * population) / SUM(population) as state_center_lat,
        SUM(longitude * population) / SUM(population) as state_center_long,
        SUM(population) as total_state_pop
    FROM mimi_ws_1.census.centerofpop_bg
    GROUP BY statefp
),

block_group_distances AS (
    -- Calculate distance from each block group to its state center
    SELECT 
        bg.statefp,
        bg.countyfp,
        bg.population,
        bg.latitude,
        bg.longitude,
        sc.state_center_lat,
        sc.state_center_long,
        -- Haversine formula for distance calculation (in miles)
        3959 * 2 * ASIN(SQRT(
            POWER(SIN((bg.latitude - sc.state_center_lat) * PI() / 180 / 2), 2) +
            COS(bg.latitude * PI() / 180) * 
            COS(sc.state_center_lat * PI() / 180) *
            POWER(SIN((bg.longitude - sc.state_center_long) * PI() / 180 / 2), 2)
        )) as distance_to_center
    FROM mimi_ws_1.census.centerofpop_bg bg
    JOIN state_centers sc ON bg.statefp = sc.statefp
)

-- Get the top 20 block groups furthest from their state centers
SELECT 
    statefp as state_fips,
    countyfp as county_fips,
    population,
    ROUND(distance_to_center, 2) as miles_from_state_center,
    latitude,
    longitude
FROM block_group_distances
WHERE population > 100  -- Filter out very small populations
ORDER BY distance_to_center DESC
LIMIT 20;

/* How this query works:
1. First CTE calculates population-weighted centers for each state
2. Second CTE computes the distance from each block group to its state center
3. Final query returns the block groups furthest from their state centers

Assumptions and limitations:
- Uses Haversine formula which assumes Earth is perfectly spherical
- Excludes block groups with population < 100 to focus on meaningful communities
- Distance is "as the crow flies" not driving distance
- Alaska and Hawaii may show extreme distances due to geography

Possible extensions:
1. Add demographic data to analyze characteristics of remote populations
2. Compare against locations of key services (hospitals, schools)
3. Analyze seasonal variations in population centers
4. Create population density rings around state centers
5. Calculate percentage of state population within different distance bands
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:09:11.669841
    - Additional Notes: Query analyzes spatial distribution of population relative to state centers. Useful for regional planning and service allocation. Note that the Haversine distance calculation may not be suitable for Alaska due to its proximity to the pole, and results for Hawaii should be interpreted considering its archipelago nature.
    
    */