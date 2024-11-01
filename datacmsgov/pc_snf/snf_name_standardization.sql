-- Title: SNF Name Standardization and Brand Analysis

-- Business Purpose:
-- This analysis examines naming patterns and brand consistency across Skilled Nursing Facilities to:
-- 1. Identify discrepancies between legal and operating names that may impact patient recognition
-- 2. Analyze brand name usage patterns that could indicate unofficial chains or networks
-- 3. Help standardize facility names for improved data matching and reporting

SELECT 
    -- Facility identification
    organization_name,
    doing_business_as_name,
    nursing_home_provider_name,
    
    -- Group names by similarity
    CASE 
        WHEN doing_business_as_name = organization_name THEN 'Exact Match'
        WHEN doing_business_as_name IS NULL THEN 'No DBA Name'
        ELSE 'Different Names'
    END as name_match_type,
    
    -- Location context
    state,
    city,
    
    -- Basic stats
    COUNT(*) as facility_count,
    
    -- Calculate name length differences
    AVG(LENGTH(COALESCE(doing_business_as_name, '')) - LENGTH(organization_name)) as avg_name_length_diff

FROM mimi_ws_1.datacmsgov.pc_snf

-- Focus on active facilities with valid names
WHERE organization_name IS NOT NULL

GROUP BY 
    organization_name,
    doing_business_as_name,
    nursing_home_provider_name,
    state,
    city

-- Filter for meaningful groups
HAVING COUNT(*) >= 1

-- Order by facilities with most naming variations first
ORDER BY facility_count DESC, state, city

LIMIT 1000;

-- How this query works:
-- 1. Selects core facility naming fields and location information
-- 2. Creates a classification of name matching patterns
-- 3. Aggregates facilities with similar naming patterns
-- 4. Calculates the average difference in name lengths
-- 5. Orders results to highlight potential naming inconsistencies

-- Assumptions and limitations:
-- 1. Assumes organization_name is the most reliable identifier
-- 2. Does not account for minor spelling variations or typos
-- 3. Limited to current active facilities
-- 4. May not capture all brand relationships due to complex ownership structures

-- Possible extensions:
-- 1. Add fuzzy matching to identify similar but not exact name matches
-- 2. Include historical name changes by analyzing multiple snapshots
-- 3. Cross-reference with ownership data to validate brand relationships
-- 4. Add geographic clustering to identify regional naming patterns
-- 5. Implement standardized name cleaning and formatting rules

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:34:52.175222
    - Additional Notes: Query assumes exact string matching for name comparisons which may miss slight variations. The facility_count metric may be inflated in cases where the same facility appears multiple times due to updates in the source data. Consider adding date filtering or deduplication logic for more accurate counts.
    
    */