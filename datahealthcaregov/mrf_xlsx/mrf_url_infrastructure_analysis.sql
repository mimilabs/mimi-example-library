-- Healthcare.gov MRF URL Pattern Analysis
-- ================================================

-- Business Purpose:
-- This query analyzes patterns in the MRF URL submissions to identify:
-- 1. The most common file hosting platforms used by issuers
-- 2. Potential data accessibility issues based on URL structure
-- 3. Technical infrastructure choices that may impact data quality
-- This information helps regulators and data consumers assess the reliability
-- and accessibility of price transparency data.

WITH url_patterns AS (
  SELECT 
    -- Extract the domain from URL for analysis
    REGEXP_EXTRACT(LOWER(url_submitted), '://([^/]+)', 1) as hosting_domain,
    -- Check if URL uses HTTPS
    CASE WHEN LOWER(url_submitted) LIKE 'https://%' THEN 1 ELSE 0 END as is_secure,
    -- Identify file format from URL
    CASE 
      WHEN LOWER(url_submitted) LIKE '%.json%' THEN 'JSON'
      WHEN LOWER(url_submitted) LIKE '%.xml%' THEN 'XML'
      WHEN LOWER(url_submitted) LIKE '%.gz%' THEN 'GZIP'
      ELSE 'OTHER'
    END as file_format,
    COUNT(DISTINCT issuer_id) as issuer_count,
    COUNT(*) as url_count
  FROM mimi_ws_1.datahealthcaregov.mrf_xlsx
  WHERE url_submitted IS NOT NULL
  GROUP BY 1, 2, 3
)

SELECT 
  hosting_domain,
  is_secure,
  file_format,
  issuer_count,
  url_count,
  ROUND(100.0 * issuer_count / SUM(issuer_count) OVER(), 2) as pct_issuers,
  ROUND(100.0 * url_count / SUM(url_count) OVER(), 2) as pct_urls
FROM url_patterns
WHERE hosting_domain IS NOT NULL
ORDER BY url_count DESC
LIMIT 20;

-- How it works:
-- 1. Creates a CTE to analyze URL patterns using regex and string functions
-- 2. Extracts key technical components: hosting domain, security protocol, file format
-- 3. Aggregates metrics by these components
-- 4. Calculates percentage distributions to identify dominant patterns

-- Assumptions and Limitations:
-- 1. URLs are well-formed and follow standard patterns
-- 2. Domain extraction regex works for standard URL formats
-- 3. File format detection is based on URL string patterns only
-- 4. Analysis is limited to top 20 most common patterns

-- Possible Extensions:
-- 1. Add URL response code checking to verify accessibility
-- 2. Include temporal analysis to track changes in hosting patterns
-- 3. Cross-reference with file size or download speed metrics
-- 4. Add geographic analysis of hosting locations
-- 5. Incorporate SSL certificate validation status

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:10:23.063862
    - Additional Notes: Query focuses on technical infrastructure patterns in MRF hosting. Results should be monitored over time as hosting patterns may change. Domain extraction may need adjustment for non-standard URL formats. Consider adding error handling for malformed URLs.
    
    */