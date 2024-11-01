/* Competition Analysis Dashboard - Core Business Value Query
 * 
 * Business Purpose:
 * This query analyzes key performance metrics across healthcare facilities to:
 * - Identify high-performing facilities based on beneficiary counts and quality metrics
 * - Understand market penetration and service distribution
 * - Support strategic decision-making for network optimization
 * 
 * Author: Healthcare Analytics Expert
 * Created: 2024
 */

-- Main query focusing on core business metrics
SELECT 
    facility_name,
    pri_spec as primary_specialty,
    
    -- Beneficiary and service metrics
    tot_benes as total_beneficiaries,
    tot_srvcs as total_services,
    (tot_srvcs * 1.0 / NULLIF(tot_benes, 0)) as services_per_beneficiary,
    
    -- Quality and performance metrics
    prop_opted_into_mips as mips_participation_rate,
    avg_final_score as quality_score,
    
    -- Calculate market share within specialty
    tot_benes * 100.0 / SUM(tot_benes) OVER (PARTITION BY pri_spec) 
        as market_share_pct
        
FROM mimi_ws_1.umn_ihdc.competition_dataset_2025

-- Focus on facilities with meaningful beneficiary counts
WHERE tot_benes > 0

-- Order by impact metrics
ORDER BY 
    market_share_pct DESC,
    quality_score DESC;

/* How This Query Works:
 * 1. Selects key business metrics from the competition dataset
 * 2. Calculates service utilization rates and market share percentages
 * 3. Filters for active facilities with beneficiaries
 * 4. Prioritizes results by market impact and quality
 *
 * Assumptions & Limitations:
 * - Assumes tot_benes > 0 represents active facilities
 * - Market share calculation is based on specialty grouping
 * - Quality scores (avg_final_score) represent standardized performance metrics
 *
 * Possible Extensions:
 * 1. Add geographic analysis using zip_code
 * 2. Include cost efficiency metrics using medicare payment amounts
 * 3. Analyze gender distribution patterns
 * 4. Incorporate age demographic analysis
 * 5. Add rural vs urban performance comparison
 */

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:31:12.891765
    - Additional Notes: Query focuses on three key business metrics: market share by specialty, service utilization, and quality scores. The market_share_pct calculation assumes even distribution within specialties and may need adjustment for regional considerations. Performance metrics are most meaningful for facilities with larger beneficiary populations.
    
    */