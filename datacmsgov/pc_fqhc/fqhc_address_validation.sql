-- TITLE: FQHC Service Area and Address Validation Analysis

-- BUSINESS PURPOSE:
-- This analysis examines the quality and completeness of FQHC location data to:
-- - Identify potential gaps in service coverage based on address information
-- - Validate address data quality for regulatory compliance
-- - Support facility outreach and communication initiatives
-- - Enable accurate provider directory maintenance

SELECT 
    -- Identify unique facilities
    organization_name,
    doing_business_as_name,
    enrollment_id,
    
    -- Concatenate address components for validation
    CONCAT_WS(', ', 
        NULLIF(TRIM(address_line_1), ''),
        NULLIF(TRIM(address_line_2), ''),
        NULLIF(TRIM(city), ''),
        NULLIF(TRIM(state), ''),
        NULLIF(TRIM(zip_code), '')
    ) as full_address,
    
    -- Flag address quality issues
    CASE 
        WHEN address_line_1 IS NULL OR TRIM(address_line_1) = '' THEN 'Missing'
        WHEN address_line_1 LIKE '%PO Box%' OR address_line_1 LIKE '%P.O.%' THEN 'PO Box'
        ELSE 'Valid'
    END as address_status,
    
    -- Additional facility identifiers for cross-reference
    npi,
    ccn,
    
    -- Latest data refresh information
    mimi_src_file_date

FROM mimi_ws_1.datacmsgov.pc_fqhc

-- Focus on most recent data
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.datacmsgov.pc_fqhc
)

-- Order by address quality issues first
ORDER BY 
    CASE address_status 
        WHEN 'Missing' THEN 1
        WHEN 'PO Box' THEN 2
        ELSE 3
    END,
    state,
    city;

-- HOW IT WORKS:
-- 1. Identifies each unique FQHC facility using organization name and enrollment ID
-- 2. Constructs a standardized full address string for validation
-- 3. Flags potential address quality issues (missing or PO Box addresses)
-- 4. Includes key identifiers (NPI, CCN) for cross-referencing
-- 5. Filters to most recent data snapshot
-- 6. Prioritizes facilities with address issues in the results

-- ASSUMPTIONS AND LIMITATIONS:
-- - Assumes address_line_1 is the primary indicator of address quality
-- - Simple PO Box detection may miss some variations
-- - Does not validate ZIP code format or state/ZIP consistency
-- - Address components are assumed to be in standard format

-- POSSIBLE EXTENSIONS:
-- 1. Add geocoding validation using latitude/longitude coordinates
-- 2. Implement more sophisticated address standardization rules
-- 3. Cross-reference with USPS address validation services
-- 4. Add distance calculations to nearest other FQHC
-- 5. Compare provider directory addresses with claims addresses
-- 6. Analyze address changes over time using historical snapshots

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:11:01.247732
    - Additional Notes: Query identifies address quality issues across FQHCs using basic validation rules. Best used for initial data quality assessment and maintaining accurate provider directories. Consider implementing address standardization logic before using for official communications or regulatory reporting.
    
    */