-- Title: Medicare Service Delivery Location Analysis

-- Business Purpose:
-- This query analyzes place of service patterns in Medicare carrier claims to:
-- - Understand where beneficiaries are receiving care (office, home, telehealth, etc.)
-- - Identify shifts in care delivery locations
-- - Support facility planning and resource allocation
-- - Guide patient access improvements

SELECT 
    -- Standardize place of service categories
    line_place_of_srvc_cd as service_location,
    
    -- Basic metrics
    COUNT(DISTINCT bene_id) as unique_patients,
    COUNT(DISTINCT clm_id) as total_claims,
    COUNT(*) as total_line_items,
    
    -- Service patterns
    SUM(line_srvc_cnt) as total_services,
    AVG(line_srvc_cnt) as avg_services_per_line,
    
    -- Financial metrics
    ROUND(SUM(line_sbmtd_chrg_amt), 2) as total_submitted_charges,
    ROUND(SUM(line_alowd_chrg_amt), 2) as total_allowed_charges,
    ROUND(AVG(line_alowd_chrg_amt), 2) as avg_allowed_per_line,
    
    -- Calculate relative proportions
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as pct_of_total_lines

FROM mimi_ws_1.synmedpuf.carrier

-- Focus on most recent year of data
WHERE YEAR(clm_from_dt) = (
    SELECT MAX(YEAR(clm_from_dt)) 
    FROM mimi_ws_1.synmedpuf.carrier
)

GROUP BY line_place_of_srvc_cd
ORDER BY total_line_items DESC;

-- How this query works:
-- 1. Groups all carrier claims by place of service code
-- 2. Calculates key volume metrics (patients, claims, services)
-- 3. Computes financial measures per location
-- 4. Shows relative distribution across locations
-- 5. Filters to most recent year for current patterns

-- Assumptions and Limitations:
-- - Place of service codes are accurately recorded
-- - Most recent year is representative of current patterns
-- - Synthetic data maintains realistic location distributions
-- - Some locations may be combined or missing
-- - Does not account for seasonal variations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break down by provider specialty
-- 3. Analyze geographic variations in service locations
-- 4. Compare urban vs rural location patterns
-- 5. Examine telehealth adoption rates
-- 6. Link to quality metrics by location
-- 7. Study impact of location on reimbursement rates

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:11:12.492581
    - Additional Notes: The query only includes metrics for currently active places of service and may need adjustment if analyzing historical location trends prior to telehealth expansion. Location codes should be validated against current CMS place of service definitions for accurate interpretation.
    
    */