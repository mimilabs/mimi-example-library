-- Title: Medicare Part B Drug Manufacturer Concentration Analysis

-- Business Purpose:
-- - Analyze manufacturer market presence in Medicare Part B drug space
-- - Identify dominant manufacturers by unique drug count
-- - Track manufacturer portfolio diversity over time
-- - Support strategic planning for market entry/expansion
-- - Assist in competitive intelligence and vendor assessment

-- Main Query
WITH manufacturer_stats AS (
    SELECT 
        labeler_name,
        -- Count unique drugs and codes per manufacturer
        COUNT(DISTINCT drug_name) as unique_drugs,
        COUNT(DISTINCT hcpcs_code) as unique_hcpcs,
        COUNT(DISTINCT ndc) as unique_ndcs,
        -- Get most recent data point
        MAX(mimi_src_file_date) as latest_data_date,
        -- Calculate portfolio complexity
        COUNT(DISTINCT short_descriptor)/COUNT(DISTINCT drug_name) as descriptor_drug_ratio
    FROM mimi_ws_1.cmspayment.partb_drug_awp_ndc_to_hcpcs
    WHERE labeler_name IS NOT NULL
    GROUP BY labeler_name
),
ranked_manufacturers AS (
    SELECT 
        *,
        -- Calculate market share percentiles
        PERCENT_RANK() OVER (ORDER BY unique_drugs) as drug_portfolio_percentile,
        ROW_NUMBER() OVER (ORDER BY unique_drugs DESC) as mfr_rank
    FROM manufacturer_stats
)
SELECT 
    labeler_name as manufacturer,
    unique_drugs,
    unique_hcpcs,
    unique_ndcs,
    ROUND(descriptor_drug_ratio, 2) as complexity_score,
    ROUND(drug_portfolio_percentile * 100, 1) as portfolio_percentile,
    mfr_rank
FROM ranked_manufacturers
WHERE mfr_rank <= 20  -- Focus on top 20 manufacturers
ORDER BY unique_drugs DESC;

-- How this query works:
-- 1. First CTE aggregates key metrics by manufacturer
-- 2. Second CTE adds ranking and percentile calculations
-- 3. Final SELECT formats and filters results
-- 4. Complexity score >1 indicates more complex product lines

-- Assumptions and Limitations:
-- - Assumes labeler_name is standardized and reliable
-- - Does not account for manufacturer mergers/acquisitions
-- - Does not consider drug volume or revenue
-- - Current time window may not reflect historical trends

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include therapeutic category analysis
-- 3. Add market concentration metrics (HHI)
-- 4. Compare brand vs generic manufacturer profiles
-- 5. Incorporate drug pricing metrics
-- 6. Add geographic distribution analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:20:57.647451
    - Additional Notes: Query analyzes manufacturer concentration in Medicare Part B drug market through portfolio size and complexity metrics. Best used for quarterly/annual market analysis and vendor assessment. May need adjustment of the TOP 20 threshold based on specific analysis needs.
    
    */