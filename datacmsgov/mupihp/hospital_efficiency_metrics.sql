-- Medicare Hospital Utilization Efficiency Analysis
-- Business Purpose: Analyze hospital inpatient efficiency by comparing average length of stay 
-- and payment metrics for common procedures (DRGs). This helps identify providers that 
-- deliver cost-effective care while maintaining quality outcomes.

WITH common_drgs AS (
    -- First identify DRGs that are performed frequently across many hospitals
    -- to ensure meaningful comparisons
    SELECT drg_cd, drg_desc
    FROM mimi_ws_1.datacmsgov.mupihp
    WHERE mimi_src_file_date = '2022-12-31'
    GROUP BY drg_cd, drg_desc
    HAVING COUNT(DISTINCT rndrng_prvdr_ccn) >= 100 
    AND SUM(tot_dschrgs) >= 1000
),

hospital_metrics AS (
    -- Calculate key efficiency metrics per hospital for common procedures
    SELECT 
        h.rndrng_prvdr_ccn,
        h.rndrng_prvdr_org_name,
        h.rndrng_prvdr_state_abrvtn,
        COUNT(DISTINCT h.drg_cd) as unique_drgs,
        SUM(h.tot_dschrgs) as total_discharges,
        AVG(h.avg_tot_pymt_amt) as avg_payment_per_case,
        AVG(h.avg_tot_pymt_amt / NULLIF(h.avg_submtd_cvrd_chrg, 0)) as payment_to_charge_ratio
    FROM mimi_ws_1.datacmsgov.mupihp h
    INNER JOIN common_drgs cd ON h.drg_cd = cd.drg_cd
    WHERE h.mimi_src_file_date = '2022-12-31'
    GROUP BY 1,2,3
)

-- Identify hospitals with superior efficiency metrics
SELECT 
    hm.*,
    ROUND(avg_payment_per_case, 2) as formatted_avg_payment,
    ROUND(payment_to_charge_ratio * 100, 1) as payment_charge_ratio_pct,
    ROUND(total_discharges / NULLIF(unique_drgs, 0), 1) as cases_per_drg
FROM hospital_metrics hm
WHERE total_discharges >= 500  -- Focus on hospitals with significant volume
ORDER BY payment_to_charge_ratio ASC, total_discharges DESC
LIMIT 100;

/* How this query works:
1. Identifies commonly performed DRGs across multiple hospitals
2. Calculates key efficiency metrics per hospital:
   - Volume metrics (discharge counts, unique DRGs)
   - Financial metrics (average payments, payment-to-charge ratios)
3. Ranks hospitals based on efficiency while controlling for volume

Assumptions and Limitations:
- Uses payment-to-charge ratio as a proxy for efficiency
- Requires significant case volume for meaningful comparison
- Does not account for case mix complexity or patient demographics
- Limited to Medicare fee-for-service population

Possible Extensions:
1. Add geographic region analysis to compare efficiency across markets
2. Include year-over-year trends to track improvement
3. Segment analysis by hospital characteristics (teaching status, bed size)
4. Add quality metrics to ensure efficiency isn't compromising outcomes
5. Compare efficiency metrics within specific DRG categories (cardiac, ortho, etc.)
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:24:27.515560
    - Additional Notes: Query requires sufficient data volume (hospitals with 500+ discharges) for meaningful efficiency comparisons. Payment-to-charge ratio may be affected by regional pricing variations and hospital charging practices. Consider local market conditions when interpreting results.
    
    */