WITH Monthly AS (
    SELECT DATEFROMPARTS(YEAR(Sale_Date), MONTH(Sale_Date), 1) AS Month_Start,
           SUM(Total_Amount) AS Revenue
    FROM Sales
    GROUP BY DATEFROMPARTS(YEAR(Sale_Date), MONTH(Sale_Date), 1)
)
SELECT Month_Start,
       CAST(Revenue AS DECIMAL(12,2)) AS Revenue,
       CAST(SUM(Revenue) OVER (ORDER BY Month_Start) AS DECIMAL(14,2)) AS Running_Total,
       CAST(100.0 * (Revenue - LAG(Revenue) OVER (ORDER BY Month_Start))
            / NULLIF(LAG(Revenue) OVER (ORDER BY Month_Start), 0) AS DECIMAL(6,2)) AS Growth_Pct
FROM Monthly
ORDER BY Month_Start;
