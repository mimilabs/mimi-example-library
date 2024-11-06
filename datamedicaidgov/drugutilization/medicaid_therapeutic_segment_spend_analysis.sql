
-- File: medicaid_drug_therapeutic_concentration_analysis.sql
-- Business Purpose: Identify drug therapeutic areas with highest Medicaid concentration 
-- to support strategic pharmaceutical and policy planning

WITH drug_therapeutic_aggregation AS (
    -- Aggregate drug utilization by therapeutic class and state
    SELECT 
        SUBSTRING(product_name, 1, 3) AS therapeutic_segment,
        state,
        SUM(number_of_prescriptions) AS total_prescriptions,
        SUM(total_amount_reimbursed) AS total_drug_spend,
        SUM(medicaid_amount_reimbursed) AS medicaid_drug_spend,
        COUNT(DISTINCT ndc) AS unique_drug_count
    FROM mimi_ws_1.datamedicaidgov.drugutilization
    WHERE 
        state != 'XX' AND 
        utilization_type IN ('FFSU', 'MCOU')
    GROUP BY 
        SUBSTRING(product_name, 1, 3),
        state
), ranked_therapeutic_concentrations AS (
    -- Rank therapeutic segments by total drug spend and prescriptions
    SELECT 
        therapeutic_segment,
        state,
        total_prescriptions,
        total_drug_spend,
        medicaid_drug_spend,
        unique_drug_count,
        RANK() OVER (PARTITION BY state ORDER BY total_drug_spend DESC) AS state_therapeutic_rank,
        RANK() OVER (PARTITION BY therapeutic_segment ORDER BY total_drug_spend DESC) AS national_therapeutic_rank
    FROM drug_therapeutic_aggregation
)

-- Final query to highlight top therapeutic concentrations
SELECT 
    therapeutic_segment,
    state,
    total_prescriptions,
    ROUND(total_drug_spend, 2) AS total_drug_spend,
    ROUND(medicaid_drug_spend, 2) AS medicaid_drug_spend,
    unique_drug_count,
    state_therapeutic_rank,
    national_therapeutic_rank
FROM ranked_therapeutic_concentrations
WHERE 
    state_therapeutic_rank <= 5 AND 
    national_therapeutic_rank <= 10
ORDER BY 
    total_drug_spend DESC
LIMIT 100;

-- How the Query Works:
-- 1. Aggregates drug utilization data by first 3 characters of product name (proxy for therapeutic class)
-- 2. Calculates prescription volumes, total spend, and unique drug counts
-- 3. Ranks therapeutic segments within each state and nationally
-- 4. Returns top therapeutic segments by spend

-- Assumptions and Limitations:
-- - Uses first 3 characters of product name as a rough therapeutic class proxy
-- - Excludes aggregated/national data (state = 'XX')
-- - Does not account for drug price variations or rebates
-- - Limited by data suppression rules

-- Potential Query Extensions:
-- 1. Add time-based trends by including year/quarter
-- 2. Incorporate more granular therapeutic classification
-- 3. Compare Fee-for-Service vs Managed Care utilization
-- 4. Analyze specific high-cost drug segments


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:29:37.280131
    - Additional Notes: Uses first 3 characters of product name as therapeutic class proxy, which is an approximate method. Query assumes data completeness and does not fully account for data suppression complexities. Recommended for high-level strategic insights into Medicaid drug spending patterns.
    
    */