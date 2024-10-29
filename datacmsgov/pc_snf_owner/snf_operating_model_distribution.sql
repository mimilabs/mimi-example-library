-- snf_operating_model_insights.sql
-- Analyzes the operating models of Skilled Nursing Facilities (SNFs) by examining 
-- the distribution of management companies, staffing providers, and consulting firms
-- 
-- Business Purpose:
-- - Help healthcare executives understand the prevalence of different SNF operating models
-- - Identify opportunities for operational partnerships and service contracts
-- - Support due diligence for M&A and market entry decisions

WITH operating_partners AS (
    -- Aggregate key operational service providers by SNF
    SELECT 
        organization_name,
        COUNT(DISTINCT CASE WHEN management_services_company_owner = 'Y' THEN associate_id_owner END) as mgmt_company_count,
        COUNT(DISTINCT CASE WHEN medical_staffing_company_owner = 'Y' THEN associate_id_owner END) as staffing_company_count,
        COUNT(DISTINCT CASE WHEN consulting_firm_owner = 'Y' THEN associate_id_owner END) as consulting_firm_count,
        COUNT(DISTINCT associate_id_owner) as total_owners
    FROM mimi_ws_1.datacmsgov.pc_snf_owner
    GROUP BY organization_name
)

SELECT
    -- Categorize SNFs by their operating model
    CASE 
        WHEN mgmt_company_count > 0 THEN 'Management Company Operated'
        WHEN staffing_company_count > 0 THEN 'Staffing Company Supported'
        WHEN consulting_firm_count > 0 THEN 'Consulting Firm Advised'
        ELSE 'Self-Operated'
    END as operating_model,
    
    -- Calculate key metrics
    COUNT(*) as facility_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_of_facilities,
    ROUND(AVG(total_owners), 1) as avg_owners_per_facility,
    
    -- Identify concentration of service providers
    SUM(mgmt_company_count) as total_mgmt_companies,
    SUM(staffing_company_count) as total_staffing_companies,
    SUM(consulting_firm_count) as total_consulting_firms
    
FROM operating_partners
GROUP BY 1
ORDER BY facility_count DESC;

/* How this query works:
1. Creates a CTE to aggregate operational service providers by SNF
2. Categorizes SNFs into operating models based on presence of key partners
3. Calculates summary statistics for each operating model
4. Returns insights about operational dependencies and partner relationships

Assumptions & Limitations:
- Assumes management/staffing/consulting relationships are accurately captured
- May undercount relationships if not formally documented in ownership structure
- Cannot determine depth/scope of operational involvement
- Point-in-time snapshot may miss seasonal or historical patterns

Possible Extensions:
1. Add geographic analysis to identify regional operating model preferences
2. Track changes in operating models over time using mimi_src_file_date
3. Analyze correlation between operating models and ownership percentages
4. Include additional partner types (e.g., medical providers, financial institutions)
5. Break out results by facility size or chain status
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:41:20.392716
    - Additional Notes: Query segments SNFs by operational partnership types and may need adjustment for facilities with multiple operating models. Consider adding filters for specific time periods using mimi_src_file_date if analyzing trends over time.
    
    */