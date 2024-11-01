-- Title: Rental Market Analysis - Average Monthly Rent Trends by Metropolitan Area

/*
Business Purpose:
This analysis provides strategic insights into rental market dynamics across major metropolitan areas.
Key business applications include:
- Market entry/expansion decisions for property management companies
- Investment opportunity identification for real estate investors
- Competitive benchmarking for property developers
- Risk assessment for mortgage lenders
*/

WITH recent_rents AS (
    -- Get the most recent 12 months of data for trend analysis
    SELECT 
        metro,
        date,
        ROUND(AVG(value), 2) as avg_rent,
        COUNT(DISTINCT zip) as zip_count
    FROM mimi_ws_1.zillow.rent_zip
    WHERE date >= DATE_SUB(CURRENT_DATE(), 365)
    GROUP BY metro, date
),

metro_stats AS (
    -- Calculate key metrics by metro area
    SELECT 
        metro,
        ROUND(AVG(avg_rent), 2) as avg_annual_rent,
        ROUND(MAX(avg_rent) - MIN(avg_rent), 2) as rent_fluctuation,
        ROUND(((MAX(avg_rent) - MIN(avg_rent)) / MIN(avg_rent) * 100), 1) as pct_change,
        MAX(zip_count) as coverage_zips
    FROM recent_rents
    WHERE metro IS NOT NULL
    GROUP BY metro
)

-- Final output with ranked results
SELECT 
    metro,
    avg_annual_rent as avg_monthly_rent_USD,
    rent_fluctuation as yearly_rent_change_USD,
    pct_change as yearly_change_pct,
    coverage_zips as zip_codes_covered,
    RANK() OVER (ORDER BY avg_annual_rent DESC) as rent_rank
FROM metro_stats
WHERE coverage_zips >= 10  -- Focus on metros with significant coverage
ORDER BY avg_annual_rent DESC
LIMIT 20;

/*
How this query works:
1. First CTE (recent_rents) aggregates rental values by metro area and date
2. Second CTE (metro_stats) calculates annual statistics for each metro
3. Final query ranks metros by average rent and applies coverage filter

Assumptions and Limitations:
- Assumes current data is available in the source table
- Limited to metros with at least 10 ZIP codes for statistical significance
- Averages may mask neighborhood-level variations
- Does not account for rental unit size or type

Possible Extensions:
1. Add year-over-year comparison:
   - Include previous year's data for growth analysis
   - Calculate compound annual growth rate (CAGR)

2. Enhance geographical analysis:
   - Add state-level aggregation
   - Include city-level breakdowns within metros
   - Compare urban vs suburban trends

3. Add market segmentation:
   - Split analysis by property type
   - Include demographic overlay
   - Add price tier analysis

4. Improve statistical robustness:
   - Add confidence intervals
   - Include seasonal adjustments
   - Add outlier detection
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:48:38.192571
    - Additional Notes: Query requires at least 12 months of historical data to function properly. Performance may be impacted for large datasets due to the 365-day lookback window. Consider adding date range parameters for flexibility in historical analysis periods.
    
    */