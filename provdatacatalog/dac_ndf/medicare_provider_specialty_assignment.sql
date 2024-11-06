-- Title: Medicare Provider Assignment and Specialty Concentration Analysis

/*
Business Purpose:
Analyze Medicare provider assignment rates and specialty concentration to:
1. Understand provider participation in Medicare reimbursement models
2. Identify potential market opportunities for healthcare services
3. Support strategic planning for healthcare network development

Key Insights:
- Measure provider willingness to accept Medicare approved rates
- Evaluate specialty distribution across different geographic regions
- Identify potential gaps in Medicare provider coverage
*/

WITH provider_assignment_summary AS (
    -- Aggregate provider assignment and specialty data
    SELECT 
        state,
        pri_spec,
        COUNT(DISTINCT npi) AS total_providers,
        SUM(CASE WHEN ind_assgn = 'Y' THEN 1 ELSE 0 END) AS assigned_providers,
        ROUND(
            100.0 * SUM(CASE WHEN ind_assgn = 'Y' THEN 1 ELSE 0 END) / COUNT(DISTINCT npi), 
            2
        ) AS pct_assigned_providers
    FROM mimi_ws_1.provdatacatalog.dac_ndf
    WHERE pri_spec IS NOT NULL
    GROUP BY state, pri_spec
),

state_specialty_ranking AS (
    -- Rank specialties within each state by provider concentration
    SELECT 
        state,
        pri_spec,
        total_providers,
        assigned_providers,
        pct_assigned_providers,
        RANK() OVER (PARTITION BY state ORDER BY total_providers DESC) AS state_specialty_rank
    FROM provider_assignment_summary
)

-- Final query focusing on top 3 specialties per state
SELECT 
    state,
    pri_spec,
    total_providers,
    assigned_providers,
    pct_assigned_providers,
    state_specialty_rank
FROM state_specialty_ranking
WHERE state_specialty_rank <= 3
ORDER BY state, total_providers DESC
LIMIT 500;

/*
Query Mechanics:
- First CTE aggregates provider counts and assignment rates by state and specialty
- Second CTE ranks specialties within each state by total provider count
- Final query selects top 3 specialties per state

Assumptions and Limitations:
- Uses primary specialty only
- Assumes 'Y' in ind_assgn indicates Medicare assignment acceptance
- Limited to 500 rows for performance and readability

Potential Extensions:
1. Add secondary specialty analysis
2. Include telehealth provider breakdown
3. Incorporate group practice size dimensions
4. Analyze longitudinal trends with mimi_src_file_date
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:11:58.539097
    - Additional Notes: Query provides state-level insights into Medicare provider specialty distribution and assignment rates. Focuses on top 3 specialties per state, with detailed breakdown of provider participation in Medicare reimbursement models.
    
    */