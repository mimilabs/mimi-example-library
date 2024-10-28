
/*************************************************************************
Title: Medicare Hospital Enrollment Analysis - Core Distribution and Types
 
Business Purpose:
- Analyze the geographic distribution and types of Medicare-enrolled hospitals
- Understand the mix of for-profit vs non-profit hospitals by state
- Identify patterns in hospital specializations and services
- Provide foundational insights for healthcare access and planning
**************************************************************************/

-- Main analysis of hospital distribution, types and ownership
SELECT 
    state,
    COUNT(DISTINCT enrollment_id) as total_hospitals,
    
    -- Ownership type breakdown
    COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) as for_profit_count,
    COUNT(CASE WHEN proprietary_nonprofit = 'N' THEN 1 END) as non_profit_count,
    
    -- Key hospital type counts
    SUM(CASE WHEN subgroup_acute_care = 'Y' THEN 1 ELSE 0 END) as acute_care_count,
    SUM(CASE WHEN subgroup_psychiatric = 'Y' THEN 1 ELSE 0 END) as psychiatric_count,
    SUM(CASE WHEN subgroup_rehabilitation = 'Y' THEN 1 ELSE 0 END) as rehab_count,
    
    -- Calculate percentages
    ROUND(COUNT(CASE WHEN proprietary_nonprofit = 'P' THEN 1 END) * 100.0 / 
          COUNT(DISTINCT enrollment_id), 1) as pct_for_profit,
          
    -- Average incorporation age (in years)
    ROUND(AVG(DATEDIFF(CURRENT_DATE, incorporation_date)/365.25), 1) as avg_years_since_incorporation

FROM mimi_ws_1.datacmsgov.pc_hospital
WHERE state IS NOT NULL  -- Exclude records with missing state
GROUP BY state
HAVING total_hospitals >= 5  -- Focus on states with meaningful hospital counts
ORDER BY total_hospitals DESC;

/*
How this query works:
1. Groups hospitals by state to show geographic distribution
2. Counts distinct hospitals using enrollment_id
3. Breaks down hospitals by ownership type (for-profit vs non-profit)
4. Counts hospitals offering key medical services
5. Calculates percentage of for-profit institutions
6. Computes average hospital age based on incorporation date

Assumptions and Limitations:
- Assumes enrollment_id uniquely identifies hospitals
- Limited to currently enrolled Medicare hospitals
- Does not account for hospital size or capacity
- Some hospitals may have multiple specialties
- Incorporation date may not reflect actual operating history

Possible Extensions:
1. Add geographic regions/divisions for regional analysis
2. Include hospital size metrics (if available)
3. Analyze trends in specialty combinations
4. Compare urban vs rural distributions
5. Add time-based analysis using incorporation dates
6. Include analysis of specialty hospital distributions
7. Add filters for specific hospital types or ownership structures
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:33:59.942842
    - Additional Notes: Query provides state-level metrics but excludes states with fewer than 5 hospitals. The avg_years_since_incorporation calculation assumes incorporation_date is populated and valid. Results should be validated against total US hospital counts from other sources for completeness check.
    
    */