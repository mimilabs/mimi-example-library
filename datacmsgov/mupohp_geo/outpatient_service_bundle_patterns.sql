-- Title: Outpatient Service Bundle Analysis for Strategic Planning
--
-- Business Purpose:
-- This query identifies and analyzes high-volume outpatient service bundles (APCs)
-- that are frequently performed together, helping healthcare organizations:
-- 1. Optimize service line planning and resource allocation
-- 2. Identify opportunities for bundled payment programs
-- 3. Better understand common treatment patterns
-- 4. Support strategic facility planning decisions

WITH service_pairs AS (
    -- Get pairs of APCs that occur in same state with significant volume
    SELECT 
        a.rndrng_prvdr_geo_desc as state,
        a.apc_cd as apc1,
        a.apc_desc as apc1_desc,
        b.apc_cd as apc2, 
        b.apc_desc as apc2_desc,
        a.bene_cnt as apc1_patients,
        b.bene_cnt as apc2_patients,
        -- Calculate overlap coefficient
        LEAST(a.bene_cnt, b.bene_cnt) / 
        GREATEST(a.bene_cnt, b.bene_cnt) as service_overlap_ratio
    FROM mimi_ws_1.datacmsgov.mupohp_geo a
    JOIN mimi_ws_1.datacmsgov.mupohp_geo b 
        ON a.rndrng_prvdr_geo_cd = b.rndrng_prvdr_geo_cd
        AND a.apc_cd < b.apc_cd  -- Avoid duplicate pairs
    WHERE a.mimi_src_file_date = '2022-12-31'
        AND b.mimi_src_file_date = '2022-12-31'
        AND a.rndrng_prvdr_geo_lvl = 'State'
        AND b.rndrng_prvdr_geo_lvl = 'State'
        AND a.bene_cnt >= 1000  -- Focus on significant volume
        AND b.bene_cnt >= 1000
)

SELECT 
    state,
    apc1,
    apc1_desc,
    apc2,
    apc2_desc,
    apc1_patients,
    apc2_patients,
    service_overlap_ratio,
    -- Categorize the relationship strength
    CASE 
        WHEN service_overlap_ratio >= 0.8 THEN 'Very Strong'
        WHEN service_overlap_ratio >= 0.6 THEN 'Strong'
        WHEN service_overlap_ratio >= 0.4 THEN 'Moderate'
        ELSE 'Weak'
    END as relationship_strength
FROM service_pairs
WHERE service_overlap_ratio >= 0.4  -- Focus on meaningful relationships
ORDER BY service_overlap_ratio DESC, state
LIMIT 100;

-- How the Query Works:
-- 1. Creates service pairs by self-joining the geographic data within each state
-- 2. Calculates an overlap ratio to measure how frequently services occur together
-- 3. Filters for significant volume and meaningful relationships
-- 4. Categorizes relationship strength for easy interpretation
--
-- Assumptions and Limitations:
-- 1. Uses beneficiary count as a proxy for service co-occurrence
-- 2. State-level aggregation may mask facility-level patterns
-- 3. Temporal relationships between services are not captured
-- 4. Minimum volume threshold of 1000 beneficiaries may need adjustment
--
-- Possible Extensions:
-- 1. Add financial metrics (avg charges, payments) for paired services
-- 2. Include temporal analysis across multiple years
-- 3. Create network analysis of service relationships
-- 4. Add clinical specialty categorization of APCs
-- 5. Calculate market basket opportunities by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:17:03.558438
    - Additional Notes: This query uses a minimum beneficiary threshold of 1000 and overlap ratio of 0.4, which may need adjustment based on specific analysis needs. The overlap ratio calculation assumes that higher beneficiary counts in the same state indicate service correlation, which may not always reflect actual clinical relationships.
    
    */