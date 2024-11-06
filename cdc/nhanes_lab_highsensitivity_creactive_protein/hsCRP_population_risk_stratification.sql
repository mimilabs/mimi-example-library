-- hs-CRP Risk Stratification and Population Health Insights

/*
Business Purpose:
Develop a comprehensive population health risk assessment framework 
using high-sensitivity C-Reactive Protein (hs-CRP) measurements to 
identify potential inflammation-related health risks across different 
population segments.

Key Objectives:
- Quantify population-level inflammation risk
- Create risk categorization for preventive healthcare interventions
- Support population health management strategies
*/

WITH cRP_risk_categories AS (
    SELECT 
        seqn,
        lbxhscrp,
        CASE 
            WHEN lbxhscrp < 1.0 THEN 'Low Risk'
            WHEN lbxhscrp BETWEEN 1.0 AND 3.0 THEN 'Moderate Risk'
            WHEN lbxhscrp > 3.0 THEN 'High Risk'
            ELSE 'Undefined'
        END AS inflammation_risk_level,
        mimi_src_file_date
    FROM mimi_ws_1.cdc.nhanes_lab_highsensitivity_creactive_protein
    WHERE lbxhscrp IS NOT NULL
),

risk_distribution AS (
    SELECT 
        inflammation_risk_level,
        COUNT(*) AS population_count,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS risk_percentage,
        ROUND(AVG(lbxhscrp), 2) AS avg_crp_level
    FROM cRP_risk_categories
    GROUP BY inflammation_risk_level
)

SELECT 
    inflammation_risk_level,
    population_count,
    risk_percentage,
    avg_crp_level,
    mimi_src_file_date
FROM risk_distribution
JOIN (SELECT DISTINCT mimi_src_file_date FROM cRP_risk_categories) src
ORDER BY 
    CASE inflammation_risk_level
        WHEN 'Low Risk' THEN 1
        WHEN 'Moderate Risk' THEN 2
        WHEN 'High Risk' THEN 3
        ELSE 4
    END;

/*
Query Mechanics:
- Categorizes hs-CRP levels into risk strata
- Calculates population distribution across risk levels
- Provides percentage and average CRP level per risk category

Assumptions:
- Uses standard clinical risk thresholds for hs-CRP
- Assumes data represents a representative population sample
- Excludes null or invalid measurements

Potential Extensions:
1. Integrate demographic crosswalks for deeper segmentation
2. Time-series analysis of inflammation risk trends
3. Correlate risk levels with specific health outcomes
*/

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T22:00:33.799848
    - Additional Notes: This query provides a high-level risk assessment of population inflammation based on high-sensitivity C-Reactive Protein levels, categorizing results into low, moderate, and high-risk groups with percentage distribution and average CRP levels.
    
    */