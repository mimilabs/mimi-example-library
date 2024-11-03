-- Title: Medicare Physician Fee Schedule Service Status and Payment Analysis
-- Business Purpose: Analyze active vs. bundled/excluded services and their associated 
-- payment implications to support strategic contracting and revenue cycle management decisions

-- Examine distribution of service status codes and average payments to identify:
-- 1. Separately billable vs bundled services
-- 2. Payment variations between facility and non-facility settings
-- 3. Services requiring special pricing considerations

SELECT 
    -- Group by year and status code
    year,
    status_code,
    
    -- Status code descriptions for key categories
    CASE status_code
        WHEN 'A' THEN 'Active - Separately Payable'
        WHEN 'B' THEN 'Bundled into Other Services'
        WHEN 'C' THEN 'Carrier Priced'
        WHEN 'E' THEN 'Excluded from Fee Schedule'
        WHEN 'N' THEN 'Non-covered'
        WHEN 'P' THEN 'Bundled/Excluded'
        ELSE 'Other Status'
    END AS status_description,
    
    -- Service volume and payment metrics
    COUNT(DISTINCT hcpcs_code) as unique_services,
    
    -- Average payments when applicable
    ROUND(AVG(non_facility_fee_schedule_amount), 2) as avg_non_facility_payment,
    ROUND(AVG(facility_fee_schedule_amount), 2) as avg_facility_payment,
    
    -- Payment differential between settings
    ROUND(AVG(non_facility_fee_schedule_amount - facility_fee_schedule_amount), 2) 
        as avg_setting_payment_diff

FROM mimi_ws_1.cmspayment.physicianfeeschedule

-- Focus on recent years
WHERE year >= 2020

GROUP BY 1,2,3

-- Order by year and frequency of status codes
ORDER BY year DESC, unique_services DESC

/* How this works:
- Groups services by year and status code
- Calculates average payments for facility vs non-facility settings
- Identifies payment differentials between settings
- Provides counts of services in each status category

Assumptions and Limitations:
- Focuses on status code distributions and associated payments
- Does not account for service volume/utilization
- Averages may mask significant variations within status categories
- Recent years only (2020+)

Possible Extensions:
1. Add specialty-specific analysis by joining with specialty/provider data
2. Include geographic variation analysis by locality
3. Trend analysis over longer time periods
4. Add service category groupings based on HCPCS code ranges
5. Enhanced filtering for specific high-value services
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:00:27.892968
    - Additional Notes: Query focuses on active vs. bundled service categorization and associated payment implications across care settings. Note that status code distributions may change significantly with CMS policy updates, and payment averages should be interpreted within the context of specific service categories.
    
    */