-- Health_Site_URL_Domain_Analysis.sql

-- Business Purpose:
-- - Analyze the distribution of health information sources by domain types (.gov, .org, etc.)
-- - Identify key authoritative sources and their coverage across health topics
-- - Support content quality and sourcing strategy decisions
-- - Enable evaluation of partnerships with external content providers

WITH site_domains AS (
    -- Extract domain from URLs and classify them
    SELECT 
        topic_id,
        url,
        title,
        CASE 
            WHEN url LIKE '%.gov%' THEN 'Government'
            WHEN url LIKE '%.org%' THEN 'Non-Profit'
            WHEN url LIKE '%.edu%' THEN 'Educational'
            WHEN url LIKE '%.com%' THEN 'Commercial'
            ELSE 'Other'
        END AS domain_type,
        mimi_src_file_date
    FROM mimi_ws_1.medlineplus.site
    WHERE url IS NOT NULL
),

domain_metrics AS (
    -- Calculate metrics by domain type
    SELECT 
        domain_type,
        COUNT(DISTINCT url) as unique_sites,
        COUNT(DISTINCT topic_id) as topics_covered,
        COUNT(*) as total_references
    FROM site_domains
    GROUP BY domain_type
)

SELECT 
    domain_type,
    unique_sites,
    topics_covered,
    total_references,
    ROUND(100.0 * unique_sites / SUM(unique_sites) OVER(), 2) as pct_of_total_sites,
    ROUND(1.0 * total_references / topics_covered, 2) as avg_references_per_topic
FROM domain_metrics
ORDER BY unique_sites DESC;

-- How it works:
-- 1. First CTE extracts and classifies domains from URLs
-- 2. Second CTE calculates key metrics for each domain type
-- 3. Final query adds percentages and averages with proper rounding

-- Assumptions and Limitations:
-- - URLs are properly formatted and contain standard domain extensions
-- - Simple domain classification may not capture all nuances
-- - Does not account for subdomain specifics
-- - Domain type is a proxy for authority/credibility

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in domain distribution over time
-- 2. Include subquery to identify top referring domains within each category
-- 3. Cross-reference with topic importance or usage metrics
-- 4. Add geographical analysis based on country-specific domains
-- 5. Implement more sophisticated domain classification logic

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:26:34.897683
    - Additional Notes: Query performs surface-level domain analysis and may need adjustments for international domains (.co.uk, etc.) or newer TLDs. Consider adding domain validation logic for production use. Performance may degrade with large URL datasets due to string pattern matching.
    
    */