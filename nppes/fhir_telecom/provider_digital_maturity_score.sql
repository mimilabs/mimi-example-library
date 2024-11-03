-- provider_digital_engagement_score.sql

-- Business Purpose: Calculate a digital engagement score for healthcare providers based on 
-- their contact methods and communication channels. This score helps identify providers
-- who are more technologically advanced and potentially better positioned for modern
-- healthcare delivery models, telehealth initiatives, and value-based care programs.

WITH provider_channels AS (
    -- Count distinct communication channels per provider
    SELECT 
        npi,
        COUNT(DISTINCT system) as channel_count,
        COUNT(CASE WHEN system = 'email' THEN 1 END) as email_count,
        COUNT(CASE WHEN system = 'url' THEN 1 END) as website_count,
        COUNT(CASE WHEN system = 'phone' THEN 1 END) as phone_count,
        MAX(period_start) as last_update
    FROM mimi_ws_1.nppes.fhir_telecom
    GROUP BY npi
),
engagement_scores AS (
    -- Calculate engagement score components
    SELECT 
        npi,
        channel_count,
        -- Base score from channel diversity (0-3 points)
        channel_count as diversity_score,
        -- Digital presence score (0-2 points)
        CASE 
            WHEN email_count > 0 AND website_count > 0 THEN 2
            WHEN email_count > 0 OR website_count > 0 THEN 1
            ELSE 0 
        END as digital_presence_score,
        -- Recency score based on last update (0-1 point)
        CASE 
            WHEN last_update >= DATE_SUB(CURRENT_DATE(), 365) THEN 1
            ELSE 0 
        END as recency_score
    FROM provider_channels
)
SELECT 
    npi,
    -- Calculate total engagement score (0-6 scale)
    diversity_score + digital_presence_score + recency_score as total_engagement_score,
    -- Provide engagement level classification
    CASE 
        WHEN (diversity_score + digital_presence_score + recency_score) >= 5 THEN 'High'
        WHEN (diversity_score + digital_presence_score + recency_score) >= 3 THEN 'Medium'
        ELSE 'Low'
    END as engagement_level,
    -- Include component scores for transparency
    diversity_score,
    digital_presence_score,
    recency_score
FROM engagement_scores
ORDER BY total_engagement_score DESC;

-- How it works:
-- 1. First CTE counts distinct communication channels and specific system types per provider
-- 2. Second CTE calculates component scores based on channel diversity, digital presence, and data recency
-- 3. Final query combines scores and classifies providers into engagement levels

-- Assumptions and limitations:
-- - Assumes all contact methods are equally valid/active
-- - Does not consider the quality or validity of contact information
-- - Recent updates are weighted equally regardless of type
-- - Score components are simplified and may need adjustment based on business needs

-- Possible extensions:
-- 1. Add weights to different types of channels based on strategic importance
-- 2. Include provider specialty and geography for more nuanced scoring
-- 3. Trend analysis of score changes over time
-- 4. Correlation analysis with patient outcomes or value-based care performance
-- 5. Integration with other provider metrics for comprehensive assessment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:28:41.023025
    - Additional Notes: The scoring algorithm uses a 0-6 scale that may need calibration based on actual provider technology adoption patterns. Consider adjusting the engagement level thresholds (currently 5+ for High, 3+ for Medium) based on score distribution analysis. The recency score's 365-day threshold is arbitrary and may need adjustment for specific use cases.
    
    */