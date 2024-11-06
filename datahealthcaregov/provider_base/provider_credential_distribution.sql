-- provider_credentials_analysis.sql

-- Business Purpose: Analyze provider credentials and qualifications to:
-- 1. Understand the mix of provider education and training levels
-- 2. Identify opportunities for advanced practice providers
-- 3. Support credentialing and quality assurance initiatives
-- 4. Guide workforce development and recruitment strategies

WITH credential_summary AS (
  -- Aggregate provider credentials and specialties
  SELECT 
    COALESCE(suffix, 'Not Specified') as credential,
    specialty,
    provider_type,
    COUNT(DISTINCT npi) as provider_count,
    COUNT(DISTINCT CASE WHEN accepting = 'Y' THEN npi END) as accepting_patients_count
  FROM mimi_ws_1.datahealthcaregov.provider_base
  WHERE suffix IS NOT NULL 
    AND last_updated_on >= DATE_SUB(CURRENT_DATE(), 180)  -- Focus on recent data
  GROUP BY suffix, specialty, provider_type
),

credential_ranking AS (
  -- Rank credentials by prevalence within specialties
  SELECT 
    credential,
    specialty,
    provider_type,
    provider_count,
    accepting_patients_count,
    ROUND(accepting_patients_count * 100.0 / provider_count, 1) as acceptance_rate,
    RANK() OVER (PARTITION BY specialty ORDER BY provider_count DESC) as credential_rank
  FROM credential_summary
)

-- Final output with key credential insights
SELECT 
  specialty,
  credential,
  provider_type,
  provider_count,
  acceptance_rate,
  ROUND(provider_count * 100.0 / SUM(provider_count) OVER (PARTITION BY specialty), 1) as pct_of_specialty
FROM credential_ranking
WHERE credential_rank <= 5  -- Focus on top 5 credentials per specialty
  AND provider_count >= 10  -- Minimum threshold for significance
ORDER BY 
  specialty,
  provider_count DESC,
  credential;

-- How this query works:
-- 1. Summarizes provider credentials by specialty and type
-- 2. Calculates acceptance rates for each credential group
-- 3. Ranks credentials within specialties by prevalence
-- 4. Filters to show most common credentials meeting minimum thresholds

-- Assumptions and Limitations:
-- 1. Relies on standardized credential formatting in suffix field
-- 2. Limited to providers with recent updates (last 180 days)
-- 3. Minimum threshold of 10 providers per credential group
-- 4. Does not account for multiple credentials per provider

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Include facility type analysis
-- 3. Trend analysis over time using last_updated_on
-- 4. Cross-reference with languages for cultural competency
-- 5. Compare urban vs rural credential mix
-- 6. Analyze advanced practice provider distribution

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:36:46.075929
    - Additional Notes: The query focuses on active providers and their credentials, filtering for recent data (last 180 days) and requiring minimum thresholds (10+ providers per credential group) to ensure statistical relevance. The acceptance rate calculation provides additional context about provider availability within each credential group.
    
    */