-- hospice_private_equity_detection.sql
-- Business Purpose: Identify potential private equity ownership and investment patterns in hospice facilities
-- This analysis helps understand market consolidation, financial backing structures, and PE involvement
-- in the hospice care sector, which has implications for quality of care and cost management

WITH pe_indicators AS (
    -- Identify owners with characteristics typical of PE ownership
    SELECT 
        enrollment_id,
        organization_name,
        associate_id_owner,
        organization_name_owner,
        CASE 
            WHEN investment_firm_owner = 'Y' THEN 1
            WHEN holding_company_owner = 'Y' THEN 1
            WHEN created_for_acquisition_owner = 'Y' THEN 1
            WHEN management_services_company_owner = 'Y' THEN 1
            ELSE 0
        END as pe_indicator_count,
        percentage_ownership,
        for_profit_owner
    FROM mimi_ws_1.datacmsgov.pc_hospice_owner
    WHERE type_owner = 'O' -- Focus on organizational owners
)

SELECT 
    -- Summarize PE-like ownership patterns
    COUNT(DISTINCT enrollment_id) as total_hospices,
    COUNT(DISTINCT CASE WHEN pe_indicator_count > 0 THEN enrollment_id END) as potential_pe_owned,
    AVG(CASE WHEN pe_indicator_count > 0 THEN percentage_ownership END) as avg_pe_ownership_stake,
    COUNT(DISTINCT organization_name_owner) as unique_owner_organizations,
    COUNT(DISTINCT CASE WHEN pe_indicator_count > 0 THEN organization_name_owner END) as unique_pe_owners
FROM pe_indicators

/*
How it works:
1. Creates a CTE to identify potential PE ownership based on multiple indicators
2. Aggregates the data to show the scope of PE involvement in the hospice sector
3. Provides key metrics about PE penetration in the market

Assumptions & Limitations:
- PE ownership is inferred from available indicators and may not capture all PE involvement
- Does not track ownership changes over time
- May include false positives due to similar ownership characteristics
- Relies on accurate self-reporting of ownership types

Possible Extensions:
1. Add geographic analysis to identify PE ownership concentration by state/region
2. Add time-based analysis using mimi_src_file_date to track ownership changes
3. Cross-reference with quality metrics to analyze PE impact on care
4. Analyze network relationships between PE firms and their portfolio hospices
5. Compare ownership stakes and patterns between PE and non-PE owners
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:46:00.407509
    - Additional Notes: Query identifies private equity involvement in hospice ownership through multiple indicator flags (investment firms, holding companies, etc). Results show aggregate statistics including total facilities, PE-owned count, and average ownership stakes. Best used for high-level market structure analysis but may not capture all PE relationships due to complex ownership structures and reporting limitations.
    
    */