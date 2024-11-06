
-- drug_overdose_national_quarterly_trend_analysis.sql
/*
Business Purpose:
- Analyze quarterly drug overdose death trends at the national level
- Provide insights into overall drug overdose mortality patterns
- Support strategic public health resource allocation and policy planning
- Enable comparative analysis across different measurement periods
*/

WITH quarterly_national_trends AS (
    -- Aggregate national drug overdose death counts by quarter
    SELECT 
        year,
        -- Map months to quarters for consistent grouping
        CASE 
            WHEN month IN ('January', 'February', 'March') THEN 'Q1'
            WHEN month IN ('April', 'May', 'June') THEN 'Q2'
            WHEN month IN ('July', 'August', 'September') THEN 'Q3'
            WHEN month IN ('October', 'November', 'December') THEN 'Q4'
        END AS quarter,
        indicator,
        
        -- Sum total deaths across all states for national perspective
        SUM(data_value) AS total_overdose_deaths,
        
        -- Weighted average of data completeness 
        AVG(CAST(REPLACE(percent_complete, '+', '') AS NUMERIC)) AS avg_data_completeness,
        
        -- Most recent report date for data context
        MAX(report_date) AS latest_report_date
    
    FROM mimi_ws_1.cdc.vsrr_drugoverdose
    
    -- Focus on national aggregation, exclude specific state analysis
    WHERE state = 'US' 
      AND period = '12 month-ending'
    
    GROUP BY year, quarter, indicator
),

quarterly_trend_analysis AS (
    -- Calculate quarterly trend metrics and percent changes
    SELECT 
        year,
        quarter,
        indicator,
        total_overdose_deaths,
        avg_data_completeness,
        latest_report_date,
        
        -- Calculate percent change from previous quarter
        LAG(total_overdose_deaths) OVER (
            PARTITION BY indicator 
            ORDER BY year, 
            CASE quarter 
                WHEN 'Q1' THEN 1 
                WHEN 'Q2' THEN 2 
                WHEN 'Q3' THEN 3 
                WHEN 'Q4' THEN 4 
            END
        ) AS previous_quarter_deaths,
        
        -- Percent change calculation with null handling
        CASE 
            WHEN LAG(total_overdose_deaths) OVER (
                PARTITION BY indicator 
                ORDER BY year, 
                CASE quarter 
                    WHEN 'Q1' THEN 1 
                    WHEN 'Q2' THEN 2 
                    WHEN 'Q3' THEN 3 
                    WHEN 'Q4' THEN 4 
                END
            ) = 0 THEN NULL
            ELSE 
                ROUND(
                    (total_overdose_deaths - 
                     LAG(total_overdose_deaths) OVER (
                         PARTITION BY indicator 
                         ORDER BY year, 
                         CASE quarter 
                             WHEN 'Q1' THEN 1 
                             WHEN 'Q2' THEN 2 
                             WHEN 'Q3' THEN 3 
                             WHEN 'Q4' THEN 4 
                         END
                     )) * 100.0 / 
                     LAG(total_overdose_deaths) OVER (
                         PARTITION BY indicator 
                         ORDER BY year, 
                         CASE quarter 
                             WHEN 'Q1' THEN 1 
                             WHEN 'Q2' THEN 2 
                             WHEN 'Q3' THEN 3 
                             WHEN 'Q4' THEN 4 
                         END
                     ),
                2)
        END AS percent_change
    
    FROM quarterly_national_trends
)

-- Final output with interpretable quarterly trends
SELECT 
    year,
    quarter,
    indicator,
    total_overdose_deaths,
    previous_quarter_deaths,
    percent_change,
    avg_data_completeness,
    latest_report_date
FROM quarterly_trend_analysis
ORDER BY year, 
    CASE quarter 
        WHEN 'Q1' THEN 1 
        WHEN 'Q2' THEN 2 
        WHEN 'Q3' THEN 3 
        WHEN 'Q4' THEN 4 
    END, 
    indicator;

/*
Query Mechanics:
- Aggregates national drug overdose death data by quarter
- Calculates quarter-over-quarter percent changes
- Provides comprehensive view of national overdose trends

Assumptions and Limitations:
- Relies on 'US' state code for national aggregation
- Uses 12-month ending period for consistent comparison
- Percent change may be volatile due to provisional data nature

Potential Extensions:
1. Add rolling 3-quarter moving average
2. Incorporate more granular indicator breakdowns
3. Create predictive models using predicted_value column
4. Develop interactive dashboard with quarterly trend visualizations
*/


/*

    - Author: claude-3-5-haiku-20241022
    - Created At: 2024-11-05T21:39:31.604146
    - Additional Notes: Query provides comprehensive national-level drug overdose trend analysis with quarterly percent change calculations. Leverages CDC provisional data with careful handling of data completeness and temporal aggregation.
    
    */