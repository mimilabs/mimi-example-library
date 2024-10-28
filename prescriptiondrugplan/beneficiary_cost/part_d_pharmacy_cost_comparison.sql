
/* 
Medicare Part D Plan Cost Sharing Analysis

Business Purpose:
Analyzes prescription drug plan cost sharing structures to identify variations 
in beneficiary out-of-pocket costs across different pharmacy types and coverage levels.
This helps stakeholders understand cost burdens on beneficiaries and compare plan offerings.

Created: 2024-02
*/

-- Main query examining cost sharing differences between pharmacy types
-- for the initial coverage period (most common coverage level)
SELECT 
    contract_id,
    plan_id,
    tier,
    -- Format preferred pharmacy costs
    CASE cost_type_pref 
        WHEN 1 THEN concat('$', cast(cost_amt_pref as string)) 
        WHEN 2 THEN concat(cast(cost_amt_pref * 100 as string), '%')
        ELSE 'Not Offered'
    END as preferred_pharmacy_cost,
    
    -- Format non-preferred pharmacy costs 
    CASE cost_type_nonpref
        WHEN 1 THEN concat('$', cast(cost_amt_nonpref as string))
        WHEN 2 THEN concat(cast(cost_amt_nonpref * 100 as string), '%') 
        ELSE 'Not Offered'
    END as nonpreferred_pharmacy_cost,
    
    -- Format mail order costs
    CASE cost_type_mail_pref
        WHEN 1 THEN concat('$', cast(cost_amt_mail_pref as string))
        WHEN 2 THEN concat(cast(cost_amt_mail_pref * 100 as string), '%')
        ELSE 'Not Offered'
    END as mail_order_cost,

    -- Flag specialty tiers and deductible application
    tier_specialty_yn as is_specialty_tier,
    ded_applies_yn as deductible_applies

FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
WHERE coverage_level = 1  -- Initial coverage period
    AND days_supply = 1   -- 30-day supply
ORDER BY contract_id, plan_id, tier

/* 
How It Works:
- Focuses on initial coverage period (coverage_level=1) and 30-day supply
- Formats cost sharing amounts into readable dollar or percentage values
- Shows costs across three pharmacy types: preferred, non-preferred, and mail order
- Includes flags for specialty tiers and deductible application

Assumptions & Limitations:
- Only looks at initial coverage period (excludes deductible, gap, catastrophic)
- Focused on 30-day supply costs
- Does not account for minimum/maximum cost limits
- Does not factor in actual drug prices

Possible Extensions:
1. Add cost sharing comparison across coverage levels (pre-deductible vs initial vs gap)
2. Include analysis of min/max cost amounts
3. Add temporal analysis using mimi_src_file_date
4. Compare cost sharing between basic and enhanced plans (requires join to plan_information)
5. Add geographic analysis by joining contract/plan data
6. Calculate average cost sharing by tier across all plans
7. Compare 30-day vs 90-day supply cost differences
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T13:53:56.899076
    - Additional Notes: Query compares Medicare Part D cost sharing across pharmacy types for initial coverage period. Best used for plan-to-plan comparisons and identifying cost differentials between pharmacy choices. Cost amounts displayed include both copay ($) and coinsurance (%) options, formatted for readability. Limited to 30-day supply analysis.
    
    */