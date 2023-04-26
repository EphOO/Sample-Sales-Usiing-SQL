--Checking all data

SELECT *
FROM Sales_Data


--Checking unique values
SELECT DISTINCT(STATUS)
FROM Sales_Data

SELECT DISTINCT(YEAR_ID)
FROM Sales_Data

SELECT DISTINCT(PRODUCTLINE)
FROM Sales_Data

SELECT DISTINCT(COUNTRY)
FROM Sales_Data

SELECT DISTINCT(DEALSIZE)
FROM Sales_Data

SELECT DISTINCT(TERRITORY)
FROM Sales_Data

SELECT DISTINCT(Month_ID)
FROM Sales_Data
WHERE Year_ID = 2005

--Grouping sales by productline to 2 df
SELECT Productline, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
GROUP BY Productline
ORDER BY Revenue DESC

--Grouping sales by year to 2 df
SELECT Year_ID, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
GROUP BY Year_ID
ORDER BY Revenue DESC

--Grouping sales by dealsize to 2 df
SELECT DealSize, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
GROUP BY DealSize
ORDER BY Revenue DESC

--Grouping sales by dealsize to 2 df
SELECT DealSize, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
GROUP BY DealSize
ORDER BY Revenue DESC

--Best month for sales in each year and how much was earned
SELECT Month_ID, SUM(Sales) Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE Year_ID = 2003
GROUP BY Month_ID
ORDER BY Revenue DESC

SELECT Month_ID, SUM(Sales) Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE Year_ID = 2004
GROUP BY Month_ID
ORDER BY Revenue DESC


--What products are sold in november?
SELECT Month_ID, ProductLine, SUM(Sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE Year_ID = 2003 AND Month_ID = 11
GROUP BY Month_ID, ProductLine
ORDER BY Revenue DESC

SELECT Month_ID, ProductLine, SUM(Sales) AS Revenue, COUNT(OrderNumber) AS Frequency
FROM Sales_Data
WHERE Year_ID = 2004 AND Month_ID = 11
GROUP BY Month_ID, ProductLine
ORDER BY Revenue DESC

--Best Customer in the organisation using RFM

SELECT
   CustomerName,
   SUM(Sales) AS MonetaryValues,
   AVG(Sales) AS AvgMonetaryValues,
   COUNT(OrderNumber) AS Frequency,
   MAX(OrderDate) AS LastOrderDate,
(SELECT MAX(OrderDate) FROM Sales_Data) AS MaxOrderDate,
DATEDIFF(DD, MAX(OrderDate), (SELECT MAX(OrderDate) FROM Sales_Data)) AS Recency
FROM Sales_Data
GROUP BY CustomerName

;with rfm as
(
SELECT
   CustomerName,
   SUM(Sales) AS MonetaryValues,
   AVG(Sales) AS AvgMonetaryValues,
   COUNT(OrderNumber) AS Frequency,
   MAX(OrderDate) AS LastOrderDate,
(SELECT MAX(OrderDate) FROM Sales_Data) AS MaxOrderDate,
DATEDIFF(DD, MAX(OrderDate), (SELECT MAX(OrderDate) FROM Sales_Data)) AS Recency
FROM Sales_Data
GROUP BY CustomerName
),
rfm_calc as
(
    SELECT r.*,
	         NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency,
			 NTILE(4) OVER (ORDER BY Frequency) rfm_Frequency,
			 NTILE(4) OVER (ORDER BY AvgMonetaryValues) rfm_MonetaryValues
FROM rfm r

)
SELECT c.*, rfm_recency + rfm_Frequency + rfm_MonetaryValues AS rfm_Sales,
CAST(rfm_recency AS VARCHAR) + CAST(rfm_Frequency AS VARCHAR) + CAST(rfm_MonetaryValues AS VARCHAR)  AS rfm_cell_string
FROM rfm_calc c

--To reduce running large codes for the rfm using # as timetable

;with rfm as
(
SELECT
   CustomerName,
   SUM(Sales) AS MonetaryValues,
   AVG(Sales) AS AvgMonetaryValues,
   COUNT(OrderNumber) AS Frequency,
   MAX(OrderDate) AS LastOrderDate,
(SELECT MAX(OrderDate) FROM Sales_Data) AS MaxOrderDate,
DATEDIFF(DD, MAX(OrderDate), (SELECT MAX(OrderDate) FROM Sales_Data)) AS Recency
FROM Sales_Data
GROUP BY CustomerName
),
rfm_calc as
(
    SELECT r.*,
	         NTILE(4) OVER (ORDER BY Recency DESC) rfm_recency,
			 NTILE(4) OVER (ORDER BY Frequency) rfm_Frequency,
			 NTILE(4) OVER (ORDER BY MonetaryValues) rfm_MonetaryValues
FROM rfm r

)
SELECT c.*, rfm_recency + rfm_Frequency + rfm_MonetaryValues AS rfm_Sales,
CAST(rfm_recency AS VARCHAR) + CAST(rfm_Frequency AS VARCHAR) + CAST(rfm_MonetaryValues AS VARCHAR)  AS rfm_sales_string
INTO #rfm
FROM rfm_calc c

SELECT *
FROM #rfm

SELECT CustomerName, rfm_recency, rfm_Frequency, rfm_MonetaryValues,
      CASE
	      WHEN rfm_sales_string IN (111, 112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'Lost_Customers'
		  WHEN rfm_sales_string IN (133, 134, 143, 244, 334, 343, 344, 144) THEN 'Slipping Away, Cannot lose'
		  WHEN rfm_sales_string IN (311, 411, 331) THEN 'New Customers'
		  WHEN rfm_sales_string IN (222, 223, 233, 322) THEN 'Potential Customers'
		  WHEN rfm_sales_string IN (323, 333, 321, 422, 332, 432) THEN 'Active Customers'
		  WHEN rfm_sales_string IN (433, 434, 443, 444) THEN 'Loyal Customers'
	  END rfm_segment
FROM #rfm

--What 2 Products combo are sold most

SELECT DISTINCT OrderNumber, STUFF(

(SELECT ',' + ProductCode
FROM Sales_Data AS a
WHERE OrderNumber IN
(
SELECT OrderNumber
FROM
(
    SELECT OrderNumber, COUNT(*) AS Count_Order
    FROM Sales_Data
    WHERE Status = 'Shipped'
    GROUP BY OrderNumber
)m
WHERE Count_Order = 2
)
   AND a.OrderNumber = b.OrderNumber
FOR xml PATH (''))
, 1, 2, '') AS Product_Code

FROM Sales_Data AS b
ORDER BY 2 DESC

--What 3 Products combo are sold most


SELECT DISTINCT OrderNumber, STUFF(

(SELECT ',' + ProductCode
FROM Sales_Data AS a
WHERE OrderNumber IN
(
SELECT OrderNumber
FROM
(
    SELECT OrderNumber, COUNT(*) AS Count_Order
    FROM Sales_Data
    WHERE Status = 'Shipped'
    GROUP BY OrderNumber
)m
WHERE Count_Order = 3
)
   AND a.OrderNumber = b.OrderNumber
FOR xml PATH (''))
, 1, 2, '') AS Product_Code

FROM Sales_Data AS b
ORDER BY 2 DESC

--What 4 Products combo are sold most


SELECT DISTINCT OrderNumber, STUFF(

(SELECT ',' + ProductCode
FROM Sales_Data AS a
WHERE OrderNumber IN
(
SELECT OrderNumber
FROM
(
    SELECT OrderNumber, COUNT(*) AS Count_Order
    FROM Sales_Data
    WHERE Status = 'Shipped'
    GROUP BY OrderNumber
)m
WHERE Count_Order = 4
)
   AND a.OrderNumber = b.OrderNumber
FOR xml PATH (''))
, 1, 2, '') AS Product_Code

FROM Sales_Data AS b
ORDER BY 2 DESC

--What is the best product in Canada
SELECT Country, Year_ID, ProductLine, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
WHERE Country = 'Canada'
GROUP BY  Country, Year_ID, ProductLine
ORDER BY Revenue DESC

--What city has the highest numbere of sales in Canada

SELECT City, Round(SUM(Sales), 2) AS Revenue
FROM Sales_Data
WHERE Country = 'Canada'
GROUP BY City
ORDER BY Revenue DESC


