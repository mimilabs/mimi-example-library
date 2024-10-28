
/*******************************************************************************
Title: Core CBSA-ZIP Code Residential Distribution Analysis

Business Purpose:
This query analyzes the distribution of residential areas across Core-Based 
Statistical Areas (CBSAs) and ZIP codes to understand geographic coverage and 
residential concentration patterns. This information is valuable for:
- Market analysis and demographic research
- Urban planning and development
- Real estate investment decisions
- Public policy and resource allocation
*******************************************************************************/

-- Main Analysis Query
SELECT 
    -- Basic geographic identifiers
    cbsa,
    usps_zip_pref_state AS state,
    COUNT(DISTINCT zip) as zip_count,
    
    -- Residential concentration metrics
    ROUND(AVG(res_ratio) * 100, 2) as avg_residential_ratio,
    ROUND(MAX(res_ratio) * 100, 2) as max_residential_ratio,
    
    -- Get the top 3 ZIP codes with highest residential ratios
    CONCAT(
      MIN(CASE WHEN res_rank <= 3 THEN 
        CONCAT(zip, ' (', ROUND(res_ratio * 100, 0), '%)')
      END),
      ' | ',
      MIN(CASE WHEN res_rank = 2 THEN 
        CONCAT(zip, ' (', ROUND(res_ratio * 100, 0), '%)')
      END),
      ' | ',
      MIN(CASE WHEN res_rank = 3 THEN 
        CONCAT(zip, ' (', ROUND(res_ratio * 100, 0), '%)')
      END)
    ) as top_residential_zips
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cbsa ORDER BY res_ratio DESC) as res_rank
    FROM mimi_ws_1.huduser.cbsa_to_zip_otm
    WHERE cbsa != '99999' -- Exclude non-CBSA areas
        AND res_ratio > 0.5 -- Focus on areas with >50% residential ratio
)
GROUP BY cbsa, usps_zip_pref_state
HAVING COUNT(DISTINCT zip) >= 5 -- Focus on CBSAs with meaningful ZIP coverage
ORDER BY avg_residential_ratio DESC
LIMIT 20;

/*******************************************************************************
How It Works:
1. Groups data by CBSA and state to analyze residential patterns
2. Calculates average and maximum residential ratios per CBSA
3. Identifies top 3 ZIP codes with highest residential concentration (>50%)
4. Filters out non-CBSA areas and those with limited ZIP coverage
5. Shows top 20 CBSAs by average residential ratio

Assumptions & Limitations:
- Uses current snapshot data (as of 2024-03-20)
- Focuses only on residential ratios, not business or other uses
- Assumes 50% threshold for "high residential" classification
- Limited to CBSAs with at least 5 ZIP codes for statistical relevance
- Shows only top 3 high-residential ZIP codes per CBSA

Possible Extensions:
1. Add time-based analysis when historical data becomes available
2. Include business ratio analysis for commercial district identification
3. Add population data for per-capita analysis
4. Compare residential patterns across different CBSA sizes
5. Analyze seasonal variations in residential patterns
*******************************************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T15:22:20.013614
    - Additional Notes: Query focuses on CBSAs with significant residential presence (>50% ratio) and minimum 5 ZIP codes. Results show top 20 CBSAs ranked by average residential ratio, with detailed breakdowns of their top 3 most residential ZIP codes. Note that non-CBSA areas (code 99999) are excluded from analysis.
    
    */