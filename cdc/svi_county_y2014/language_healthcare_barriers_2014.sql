-- minority_language_healthcare_access_2014.sql
--
-- Business Purpose: 
-- Analyze counties where language barriers and minority status intersect with healthcare access challenges.
-- This helps healthcare organizations identify areas needing targeted language services,
-- cultural competency programs, and specialized outreach strategies.

WITH ranked_counties AS (
  -- Calculate key risk metrics and rank counties
  SELECT 
    state,
    county,
    e_totpop,
    ep_limeng AS pct_limited_english,
    ep_minrty AS pct_minority,
    ep_uninsur AS pct_uninsured,
    -- Create risk tiers based on percentiles
    CASE 
      WHEN ep_limeng > 75 THEN 'High'
      WHEN ep_limeng > 50 THEN 'Medium'
      ELSE 'Low'
    END AS language_risk,
    CASE 
      WHEN ep_uninsur > 75 THEN 'High'
      WHEN ep_uninsur > 50 THEN 'Medium' 
      ELSE 'Low'
    END AS uninsured_risk
  FROM mimi_ws_1.cdc.svi_county_y2014
  WHERE e_totpop >= 10000  -- Focus on counties with meaningful population size
)

SELECT
  state,
  -- Group results by state for strategic planning
  COUNT(*) AS total_counties,
  COUNT(CASE WHEN language_risk = 'High' AND uninsured_risk = 'High' THEN 1 END) AS high_risk_counties,
  AVG(pct_limited_english) AS avg_limited_english_pct,
  AVG(pct_minority) AS avg_minority_pct,
  AVG(pct_uninsured) AS avg_uninsured_pct,
  -- Calculate combined risk ratio
  ROUND(COUNT(CASE WHEN language_risk = 'High' AND uninsured_risk = 'High' THEN 1 END) * 100.0 / COUNT(*), 1) AS high_risk_county_pct
FROM ranked_counties
GROUP BY state
HAVING COUNT(CASE WHEN language_risk = 'High' AND uninsured_risk = 'High' THEN 1 END) > 0
ORDER BY high_risk_county_pct DESC;

-- How this works:
-- 1. Creates a CTE that calculates risk tiers for language barriers and uninsured rates
-- 2. Filters for counties with population >= 10,000 to ensure statistical relevance
-- 3. Aggregates results by state to show where intervention may be most needed
-- 4. Focuses on intersection of language barriers and lack of insurance
--
-- Assumptions and limitations:
-- - Assumes current language barrier patterns reflect actual healthcare access challenges
-- - Limited to 2014 data point; trends over time not captured
-- - Population threshold may exclude some rural areas with unique needs
-- - Does not account for proximity to language-appropriate services
--
-- Possible extensions:
-- 1. Add geographic clustering analysis to identify regional patterns
-- 2. Include healthcare facility density metrics to assess service availability
-- 3. Incorporate cost of living adjustments for more nuanced risk assessment
-- 4. Add temporal analysis if combining with other years' data
-- 5. Include specific language group breakdowns for targeted intervention planning

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:35:44.630754
    - Additional Notes: Query identifies states with compound risk of limited English proficiency and lack of health insurance, helping target language assistance programs and culturally-sensitive healthcare outreach. Only includes counties with population >= 10,000 for statistical relevance.
    
    */