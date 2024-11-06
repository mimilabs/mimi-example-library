-- Medicare Advantage Benefits JSON Field Analysis
-- 
-- Business Purpose:
-- This query analyzes the JSON-formatted questions and field descriptions in the Medicare Advantage
-- benefits metadata to:
-- 1. Identify key business questions that the data can answer
-- 2. Map which benefit fields have structured question formats
-- 3. Help analysts understand the queryable business content
-- 4. Support development of natural language interfaces

WITH json_fields AS (
    -- Filter to only rows with valid JSON questions and remove duplicates
    SELECT DISTINCT
        name,
        field_title,
        json_question,
        service_category
    FROM mimi_ws_1.partcd.pbp_metadata
    WHERE json_question IS NOT NULL
        AND json_question != ''
),

parsed_fields AS (
    -- Analyze the structure of JSON questions
    SELECT 
        service_category,
        COUNT(DISTINCT name) as field_count,
        COUNT(DISTINCT CASE 
            WHEN json_question LIKE '%?%' THEN name 
            END) as question_fields,
        COUNT(DISTINCT CASE 
            WHEN json_question LIKE '%{"question"%' THEN name
            END) as structured_fields
    FROM json_fields
    GROUP BY service_category
)

SELECT
    service_category,
    field_count as total_fields,
    question_fields as fields_with_questions,
    structured_fields as structured_json_fields,
    ROUND(100.0 * question_fields / field_count, 1) as pct_queryable,
    ROUND(100.0 * structured_fields / field_count, 1) as pct_structured
FROM parsed_fields
WHERE field_count > 0
ORDER BY field_count DESC, service_category;

-- How this works:
-- 1. First CTE filters to rows with JSON question content
-- 2. Second CTE analyzes the JSON structure patterns
-- 3. Final query calculates coverage metrics by service category
--
-- Assumptions & Limitations:
-- - Assumes JSON questions follow consistent format
-- - Simple pattern matching may miss some variations
-- - Does not parse actual JSON structure
-- - Limited to fields with explicit questions
--
-- Possible Extensions:
-- 1. Add JSON parsing to extract actual question text
-- 2. Analyze question complexity and types
-- 3. Build question taxonomy/classification
-- 4. Map questions to common business use cases
-- 5. Generate sample natural language queries

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:04:46.225238
    - Additional Notes: Query focuses on analyzing the metadata table's JSON question fields to assess data queryability and structure across service categories. Best used for understanding which Medicare benefit areas have well-structured data documentation and identifying gaps in metadata coverage. May need adjustment if JSON formatting in source data varies significantly.
    
    */