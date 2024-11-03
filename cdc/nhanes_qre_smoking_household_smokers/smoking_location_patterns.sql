/*
Title: Household Smoking Location Pattern Analysis

Business Purpose:
This analysis examines where smoking occurs in households to:
1. Understand compliance with indoor smoking restrictions
2. Identify patterns of smoking in alternative locations (decks, porches, garages)
3. Support targeted interventions for reducing indoor smoking exposure
4. Guide public health messaging about smoke-free home policies

Key metrics focus on comparing indoor vs. outdoor household smoking behavior to inform
smoking cessation and exposure reduction programs.
*/

WITH household_locations AS (
    -- Compare total household smokers vs. those who smoke inside
    SELECT 
        seqn,
        COALESCE(smd460, 0) as total_smokers,
        COALESCE(smd470, 0) as indoor_smokers,
        COALESCE(smd480, 0) as days_smoked_inside,
        -- Calculate outdoor-only smokers
        COALESCE(smd460, 0) - COALESCE(smd470, 0) as outdoor_only_smokers
    FROM mimi_ws_1.cdc.nhanes_qre_smoking_household_smokers
    WHERE smd460 IS NOT NULL  -- Focus on valid responses
)

SELECT 
    -- Categorize households by smoking patterns
    CASE 
        WHEN total_smokers = 0 THEN 'Non-smoking household'
        WHEN indoor_smokers = 0 THEN 'Outdoor-only smoking'
        WHEN indoor_smokers = total_smokers THEN 'All smokers smoke inside'
        ELSE 'Mixed indoor/outdoor smoking'
    END as household_pattern,
    
    -- Calculate key metrics
    COUNT(*) as household_count,
    AVG(total_smokers) as avg_total_smokers,
    AVG(indoor_smokers) as avg_indoor_smokers,
    AVG(outdoor_only_smokers) as avg_outdoor_only_smokers,
    AVG(days_smoked_inside) as avg_days_smoked_inside,
    
    -- Calculate percentages
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as pct_of_households
    
FROM household_locations
GROUP BY 
    CASE 
        WHEN total_smokers = 0 THEN 'Non-smoking household'
        WHEN indoor_smokers = 0 THEN 'Outdoor-only smoking'
        WHEN indoor_smokers = total_smokers THEN 'All smokers smoke inside'
        ELSE 'Mixed indoor/outdoor smoking'
    END
ORDER BY household_count DESC;

/*
How this query works:
1. Creates a CTE to normalize smoking location data and calculate derived metrics
2. Categorizes households into distinct smoking pattern groups
3. Calculates summary statistics for each group
4. Provides percentage distribution across patterns

Assumptions and Limitations:
- Assumes survey responses are accurate and representative
- Does not account for seasonal variations in outdoor smoking
- Cannot distinguish between different types of outdoor spaces
- Missing data is treated as zero smoking activity

Possible Extensions:
1. Add temporal analysis to track changes in patterns over time
2. Include demographic factors to identify high-risk populations
3. Incorporate weather/climate data to understand outdoor smoking patterns
4. Add geographic analysis to identify regional differences
5. Compare patterns against local smoking regulations
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:27:30.900070
    - Additional Notes: This analysis provides a foundational view of household smoking behaviors by location (indoor vs outdoor), which can be particularly valuable for public health interventions targeting specific household types. The categorization scheme allows for clear segmentation of households based on their smoking patterns, making it useful for targeted program development.
    
    */