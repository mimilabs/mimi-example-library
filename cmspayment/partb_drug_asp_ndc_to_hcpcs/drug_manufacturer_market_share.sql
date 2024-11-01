-- Title: Drug Manufacturer Market Share Analysis
-- Business Purpose: Analyzes manufacturer presence and dominance in Medicare Part B drug market to:
-- - Help healthcare organizations understand supplier concentration and negotiating power
-- - Identify potential risks in drug supply chains
-- - Support strategic sourcing and vendor management decisions

-- Main Query
WITH manufacturer_metrics AS (
    SELECT 
        labeler_name,
        COUNT(DISTINCT hcpcs_code) as unique_hcpcs,
        COUNT(DISTINCT ndc) as unique_ndcs,
        COUNT(DISTINCT drug_name) as unique_drugs,
        -- Get most recent data only
        MAX(mimi_src_file_date) as latest_data_date
    FROM mimi_ws_1.cmspayment.partb_drug_asp_ndc_to_hcpcs
    GROUP BY labeler_name
),

ranked_manufacturers AS (
    SELECT 
        labeler_name,
        unique_hcpcs,
        unique_ndcs,
        unique_drugs,
        -- Calculate market presence scores
        ROUND((unique_hcpcs * 100.0 / (SELECT MAX(unique_hcpcs) FROM manufacturer_metrics)), 1) as hcpcs_score,
        ROUND((unique_ndcs * 100.0 / (SELECT MAX(unique_ndcs) FROM manufacturer_metrics)), 1) as ndc_score,
        ROUND((unique_drugs * 100.0 / (SELECT MAX(unique_drugs) FROM manufacturer_metrics)), 1) as drug_score,
        -- Calculate composite score
        (ROUND((unique_hcpcs * 100.0 / (SELECT MAX(unique_hcpcs) FROM manufacturer_metrics)), 1) +
         ROUND((unique_ndcs * 100.0 / (SELECT MAX(unique_ndcs) FROM manufacturer_metrics)), 1) +
         ROUND((unique_drugs * 100.0 / (SELECT MAX(unique_drugs) FROM manufacturer_metrics)), 1)) / 3 as market_presence_score
    FROM manufacturer_metrics
)

SELECT 
    labeler_name,
    unique_hcpcs,
    unique_ndcs,
    unique_drugs,
    hcpcs_score,
    ndc_score,
    drug_score,
    ROUND(market_presence_score, 1) as market_presence_score
FROM ranked_manufacturers
WHERE market_presence_score > 10  -- Focus on significant players
ORDER BY market_presence_score DESC
LIMIT 20;

-- How it works:
-- 1. First CTE aggregates key metrics per manufacturer
-- 2. Second CTE calculates relative market presence scores
-- 3. Final query filters and presents top manufacturers by composite score

-- Assumptions and Limitations:
-- - Assumes current data is representative of market position
-- - Does not account for drug volume or revenue
-- - Equal weighting of HCPCS, NDC, and drug counts in composite score
-- - Market presence score is relative, not absolute

-- Possible Extensions:
-- 1. Add time-based trending of market presence
-- 2. Include therapeutic category analysis
-- 3. Add geographical distribution if combined with claims data
-- 4. Incorporate drug pricing data for market value analysis
-- 5. Add competitor pair analysis for specific drug categories

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:14:16.768567
    - Additional Notes: Query calculates relative market presence using a composite score based on HCPCS codes, NDCs, and unique drugs. Score threshold of 10% filters for significant manufacturers only. Consider adjusting this threshold based on specific analysis needs.
    
    */