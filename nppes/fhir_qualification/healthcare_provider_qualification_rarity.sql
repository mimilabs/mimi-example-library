-- Title: Healthcare Provider Qualification Rarity and Market Insight Analysis

-- Business Purpose:
-- Identify unique and scarce healthcare provider qualifications to:
-- 1. Inform strategic workforce planning
-- 2. Support recruitment and talent acquisition strategies
-- 3. Highlight potential niche specialization opportunities
-- 4. Provide insights into credential market dynamics

WITH qualification_frequency AS (
    SELECT 
        code_text,                          -- Qualification description
        COUNT(DISTINCT npi) as provider_count,  -- Number of unique providers
        COUNT(*) as total_entries,          -- Total qualification entries
        
        -- Calculate percentage of total providers with this qualification
        ROUND(
            COUNT(DISTINCT npi) * 100.0 / 
            (SELECT COUNT(DISTINCT npi) FROM mimi_ws_1.nppes.fhir_qualification), 
            2
        ) as provider_percentage
    FROM 
        mimi_ws_1.nppes.fhir_qualification
    WHERE 
        -- Exclude null or empty qualification descriptions
        code_text IS NOT NULL 
        AND TRIM(code_text) != ''
    GROUP BY 
        code_text
),

rarity_classification AS (
    SELECT 
        code_text,
        provider_count,
        total_entries,
        provider_percentage,
        
        -- Categorize qualification rarity
        CASE 
            WHEN provider_percentage < 0.1 THEN 'Ultra Rare'
            WHEN provider_percentage BETWEEN 0.1 AND 1 THEN 'Rare'
            WHEN provider_percentage BETWEEN 1 AND 5 THEN 'Uncommon'
            ELSE 'Common'
        END as rarity_category
    FROM 
        qualification_frequency
)

SELECT 
    code_text,
    provider_count,
    total_entries,
    provider_percentage,
    rarity_category
FROM 
    rarity_classification
WHERE 
    provider_count > 10  -- Focus on qualifications with meaningful representation
ORDER BY 
    provider_percentage ASC  -- Sort from rarest to most common
LIMIT 100;  -- Limit to top 100 rare qualifications

-- Query Mechanics:
-- 1. First CTE (qualification_frequency) counts providers per qualification
-- 2. Second CTE (rarity_classification) categorizes qualifications by rarity
-- 3. Final SELECT retrieves key insights about qualification distribution

-- Assumptions and Limitations:
-- - Data represents current NPPES snapshot
-- - Relies on accurate and complete self-reported qualifications
-- - Does not validate credential authenticity
-- - Snapshot in time, not historical trend

-- Possible Query Extensions:
-- 1. Add temporal analysis of qualification trends
-- 2. Join with provider specialty data
-- 3. Geographical breakdown of rare qualifications
-- 4. Compare rarity across different healthcare sectors

/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:15:53.782777
    - Additional Notes: Provides insights into rare healthcare provider qualifications. Uses percentage thresholds to categorize qualification rarity. Requires review and potential refinement based on specific organizational needs.
    
    */