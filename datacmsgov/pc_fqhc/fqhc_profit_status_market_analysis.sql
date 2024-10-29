-- TITLE: FQHC Financial Accessibility Analysis by Profit Status and Market Concentration

/*
BUSINESS PURPOSE:
This analysis examines the distribution of for-profit vs. non-profit FQHCs to identify
potential gaps in healthcare accessibility and market concentration patterns. Key insights help:
- Healthcare investors evaluate market opportunities
- Policy makers assess healthcare access equity
- Healthcare systems plan strategic expansions
- Public health officials identify areas needing additional resources

The query provides a foundation for analyzing how ownership structure impacts healthcare delivery
and identifies areas that may need additional support or oversight.
*/

WITH profit_status_by_state AS (
  -- Calculate the mix of proprietary vs non-profit FQHCs by state
  SELECT 
    state,
    COUNT(DISTINCT npi) as total_fqhcs,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN npi END) as for_profit_count,
    COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'N' THEN npi END) as non_profit_count,
    -- Calculate concentration percentages
    ROUND(COUNT(DISTINCT CASE WHEN proprietary_nonprofit = 'P' THEN npi END) * 100.0 / 
          NULLIF(COUNT(DISTINCT npi), 0), 1) as for_profit_pct,
    -- Count unique organizations to assess market concentration
    COUNT(DISTINCT organization_name) as unique_organizations
  FROM mimi_ws_1.datacmsgov.pc_fqhc
  GROUP BY state
)

SELECT 
  state,
  total_fqhcs,
  for_profit_count,
  non_profit_count,
  for_profit_pct,
  unique_organizations,
  -- Calculate market concentration indicator
  ROUND(total_fqhcs * 1.0 / NULLIF(unique_organizations, 0), 1) as fqhcs_per_org,
  -- Flag states with potential access concerns
  CASE 
    WHEN for_profit_pct > 75 THEN 'High For-Profit Concentration'
    WHEN for_profit_pct < 25 THEN 'High Non-Profit Concentration'
    ELSE 'Balanced Mix'
  END as market_classification
FROM profit_status_by_state
WHERE state IS NOT NULL
ORDER BY total_fqhcs DESC;

/*
HOW IT WORKS:
1. Creates a CTE to analyze FQHC profit status distribution by state
2. Calculates key metrics including total FQHCs, profit/non-profit counts and percentages
3. Determines market concentration by comparing unique organizations to total facilities
4. Classifies markets based on for-profit percentage thresholds
5. Orders results by total FQHC count to highlight largest markets

ASSUMPTIONS & LIMITATIONS:
- Assumes NPI is the best identifier for unique facilities
- Does not account for facility size or patient volume
- Market classification thresholds (75%/25%) are arbitrary and may need adjustment
- Does not consider demographic or socioeconomic factors
- Some states may have missing or incomplete data

POSSIBLE EXTENSIONS:
1. Add time-series analysis to track changes in profit status mix over time
2. Incorporate facility size metrics (if available) for weighted analysis
3. Join with demographic data to analyze accessibility relative to population needs
4. Add geographic clustering analysis to identify FQHC deserts
5. Include quality metrics to compare outcomes between profit statuses
6. Analyze relationships between market concentration and healthcare costs
7. Add rural vs urban segmentation to the analysis
*//*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:11:01.840312
    - Additional Notes: Query provides market-level insights about FQHC ownership structures and concentration. Key metrics include for-profit vs. non-profit ratios and facilities per organization. Results are most reliable for states with complete reporting. The 75%/25% thresholds for market classification should be adjusted based on specific analysis needs.
    
    */