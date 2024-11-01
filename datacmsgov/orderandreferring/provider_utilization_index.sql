-- Medicare Provider Primary Utilization Index
-- 
-- Business Purpose:
-- This analysis creates a Provider Utilization Index to identify the most versatile
-- Medicare providers based on their authorization scope and potential referral value.
-- The index helps:
-- - Target high-value providers for network development
-- - Optimize care coordination pathways
-- - Identify providers best suited for value-based care programs

WITH provider_metrics AS (
  SELECT 
    npi,
    first_name,
    last_name,
    -- Calculate total authorizations per provider
    (CAST(partb AS INT) + 
     CAST(dme AS INT) + 
     CAST(hha AS INT) + 
     CAST(pmd AS INT) + 
     CAST(hospice AS INT)) as total_auth_count,
    
    -- Assign weights to high-value services
    CASE WHEN partb = 'Y' THEN 2.0 ELSE 0 END +
    CASE WHEN hha = 'Y' THEN 1.5 ELSE 0 END +
    CASE WHEN hospice = 'Y' THEN 1.5 ELSE 0 END +
    CASE WHEN dme = 'Y' THEN 1.0 ELSE 0 END +
    CASE WHEN pmd = 'Y' THEN 1.0 ELSE 0 END as weighted_score
  FROM mimi_ws_1.datacmsgov.orderandreferring
  WHERE _input_file_date = (SELECT MAX(_input_file_date) FROM mimi_ws_1.datacmsgov.orderandreferring)
)

SELECT
  npi,
  first_name,
  last_name,
  total_auth_count,
  ROUND(weighted_score, 2) as utilization_index,
  NTILE(5) OVER (ORDER BY weighted_score DESC) as utilization_quintile
FROM provider_metrics
WHERE total_auth_count > 0
ORDER BY weighted_score DESC, total_auth_count DESC
LIMIT 1000;

-- How this query works:
-- 1. Creates a CTE to calculate key metrics per provider
-- 2. Assigns weighted scores based on service authorization types
-- 3. Calculates a utilization index and quintile ranking
-- 4. Returns top 1000 providers by weighted score
--
-- Assumptions and Limitations:
-- - Assumes current authorization status (_input_file_date filtering)
-- - Weights are assigned based on typical service complexity/value
-- - Limited to top 1000 providers for initial analysis
--
-- Possible Extensions:
-- 1. Add geographical clustering to identify regional patterns
-- 2. Include time-based authorization stability metrics
-- 3. Create separate indices for different specialties or service types
-- 4. Add provider specialty data for more nuanced scoring
-- 5. Implement machine learning to optimize weightings based on outcomes

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:28:59.702275
    - Additional Notes: The query implements a weighted scoring system for Medicare providers where Part B (2.0) and care coordination services like HHA/Hospice (1.5) are weighted higher than DME/PMD services (1.0). The utilization quintiles provide easy segmentation for provider targeting and network development purposes.
    
    */