-- Title: Healthcare Provider Specialty Distribution and Technology Usage Analysis

/* Business Purpose:
This query provides insights into the distribution of healthcare provider specialties
and their technology choices to help:
- Identify underserved medical specialties in different regions
- Guide health IT vendor market strategies
- Support healthcare workforce planning initiatives
- Inform medical education and training programs

The analysis combines specialty distribution with technology adoption patterns
to reveal opportunities for targeted solutions and services.
*/

WITH specialty_summary AS (
    -- Get the count and percentage of providers by specialty
    SELECT 
        clinician_specialty,
        practice_state_or_us_territory as state,
        developer as tech_vendor,
        COUNT(DISTINCT npi) as provider_count,
        ROUND(COUNT(DISTINCT npi) * 100.0 / SUM(COUNT(DISTINCT npi)) OVER(PARTITION BY practice_state_or_us_territory), 2) as specialty_pct
    FROM mimi_ws_1.healthit.chit_cpip
    WHERE clinician_specialty IS NOT NULL
    GROUP BY clinician_specialty, practice_state_or_us_territory, developer
),
ranked_specialties AS (
    -- Rank specialties by provider count within each state
    SELECT 
        state,
        clinician_specialty,
        tech_vendor,
        provider_count,
        specialty_pct,
        ROW_NUMBER() OVER(PARTITION BY state ORDER BY provider_count DESC) as specialty_rank
    FROM specialty_summary
)
-- Final output showing top specialties by state with their technology vendors
SELECT 
    state,
    clinician_specialty,
    tech_vendor,
    provider_count,
    specialty_pct,
    CASE 
        WHEN specialty_rank <= 3 THEN 'Top 3 Specialty'
        WHEN specialty_rank <= 5 THEN 'Top 5 Specialty'
        ELSE 'Other'
    END as market_position
FROM ranked_specialties
WHERE specialty_rank <= 5
ORDER BY state, specialty_rank;

/* How the Query Works:
1. First CTE (specialty_summary) calculates the count and percentage of providers
   for each specialty in each state, including their technology vendor
2. Second CTE (ranked_specialties) ranks specialties within each state by provider count
3. Final query filters for top 5 specialties and adds market position classification

Assumptions and Limitations:
- Assumes NPI numbers are unique per provider
- Limited to providers who have reported certified health IT usage
- Does not account for providers working across multiple states
- Technology vendor analysis may be affected by multi-vendor implementations

Possible Extensions:
1. Add time-based trending analysis using mimi_src_file_date
2. Include practice size analysis to segment by facility scale
3. Add geographic clustering analysis for regional patterns
4. Incorporate participation_type to analyze reporting methods
5. Compare technology adoption patterns between different specialty groups
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:27:12.984547
    - Additional Notes: Query focuses on regional specialty distribution and technology vendor relationships, supporting market analysis and healthcare workforce planning. Results are most relevant for state-level strategic planning and vendor market analysis. Note that the percentage calculations are relative to each state's total provider count, not national totals.
    
    */