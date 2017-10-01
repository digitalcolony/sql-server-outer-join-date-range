# Outer Joins Against A Date Range

This article is written for SQL Server, which supports user-defined functions and OUTER JOINS.  All examples come from the Northwind database which is part of the default installation of SQL Server.

In SQL an OUTER JOIN is where you want to return all the elements in a table regardless of whether they exist in the second table.  The most common case for using an OUTER JOIN is when you need a COUNT or SUM value even when the aggregate function returns a zero.  Before we get to the heart of this article, let me use two queries to demonstrate the power of a basic OUTER JOIN.

## Customers and Order COUNT

There are 2 ways to tackle this request.  The first is with an INNER JOIN. It will only return Customers that have at least one order.  The second way is with an OUTER JOIN. It will return all Customers, even those with no Orders.

```sql
-- A: INNER JOIN (returns 89 customers, all of which have at least 1 order) 
SELECT C.CompanyName, COUNT(R.OrderID) AS OrderCount 

FROM Customers C
INNER JOIN Orders R ON C.customerID = R.customerID
GROUP BY C.CompanyName
ORDER BY COUNT(R.OrderID) DESC 

-- B: OUTER JOIN (returns all 91 customers, 2 of which have 0 orders) 
SELECT C.CompanyName, COUNT(R.OrderID) AS OrderCount
FROM Customers C
LEFT OUTER JOIN Orders R ON C.customerID = R.customerID 

GROUP BY C.CompanyName
ORDER BY COUNT(R.OrderID) DESC
Orders by Day of the Week for July 1996
```

The first OUTER JOIN was straight-forward. But what if the entity you need to perform an OUTER JOIN upon doesn’t exist in the database? One such entity that comes to mind is date. Let’s suppose the sales manager is trying to determine which day she is going to paint the office based upon the day of the week with historically the least amount of orders. The least amount could be zero, so we need to perform an OUTER JOIN. 

But how can you perform an OUTER JOIN against a range of dates? Three ways come to mind.

1. Create a TABLE of dates (or digits) using a SQL statement. This could be a temporary or permanent table.

2. Get verbose with your SQL and write long CASE statements.

3. Use the 2 user-defined functions I’m providing to you in this article.

The problem with #1 is now you’re executing multiple statements to handle one query. You are creating a TABLE, perform the INSERT and ultimately dropping the TABLE. At this point you’ll consider writing a stored procedure to accomplish the task. All for a single query. Too much work. 

The problem with #2 is your SQL can get very long and hard to read and the data is returned more like an Access PIVOT TABLE.

The slick way to handle this task is using a user-defined function.

```sql
-- C: Using multiple CASE and SUM statement (long, ugly, and tabular) 
SELECT SUM(CASE DATEPART(dw,OrderDate) WHEN 0 THEN 1 ELSE 0 END) AS MonSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 1 THEN 1 ELSE 0 END) AS TueSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 2 THEN 1 ELSE 0 END) AS WedSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 3 THEN 1 ELSE 0 END) AS ThuSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 4 THEN 1 ELSE 0 END) AS FriSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 5 THEN 1 ELSE 0 END) AS SatSales, 

SUM(CASE DATEPART(dw,OrderDate) WHEN 6 THEN 1 ELSE 0 END) AS SunSales 

FROM Orders
WHERE OrderDate BETWEEN '7/1/1996' AND '8/1/1996' 

-- D: Performing an OUTER JOIN against a user-defined function (dbo.udfNumbers) 
SELECT DATENAME(dw,N.number) AS DayName, COUNT(R.orderID) AS OrderCount 

FROM dbo.udfNumbers(0,6) N
LEFT OUTER JOIN Orders R ON N.number = DATEPART(dw,R.OrderDate)
AND R.OrderDate BETWEEN '7/1/1996' AND '8/1/1996' 

GROUP BY DATENAME(dw,N.number), N.Number
ORDER BY N.number
Using dbo.udfNumbers
```

The dbo.udfNumbers user-defined function returns a TABLE of numbers. It is available for download at the end of this article. The upper range limit is 999,999. If you need larger numbers, modifying the function should be fairly easy.

```sql
-- E: Usage dbo.udfNumbers(low range,high range) 
-- will return 6,7,8,9,10,11,12
SELECT number FROM dbo.udfNumbers(6,12)
Orders by Date for July 1996
```

I use dbo.udfNumbers for those quick queries where I just need a range of digits. 

For most date-based reporting I use the far more powerful dbo.udfDateTimes. This user-defined function uses the digit logic in dbo.udfNumbers along with SQL Server’s date and time function to return ranges of datetime. 

Query C was based upon Day of the Week, so there were only 7 possible values. What if the sales manager asked for a day by day breakdown of orders for July? That would turn into one long and ugly SQL statement. The dbo.udfDateTimes function creates the date range need for that OUTER JOIN without the long and ugly SQL.

```sql
-- F: dbo.udfDateTimes day interval for July 1996 
SELECT dtime AS OrderDate, COUNT(R.orderID) AS OrderCount
FROM dbo.udfDateTimes ('7/1/1996', '7/31/1996',1,'day') DT 

LEFT OUTER JOIN Orders R ON DT.dtime = R.OrderDate
GROUP BY dtime
Using dbo.udfDateTimes
```

Like dbo.udfNumbers, the user-defined function dbo.udfDateTimes returns a TABLE. 
1. The first parameter is start date. 
2. The second is end date. 
3. The third parameter is interval. In most cases this will be set to 1, but if you had a need to see one of the dateparts at an alternate interval, you would modify this parameter. 
4. The last parameter is datepart. Those supported are year, quarter, month, week, day, hour and minute. The upper range is 9,999,999, which (like udfNumbers) can easily be modified should need a function that returns more datetimes.


## Last Words

One last piece of advice is to get your datetime range correct first before attempting to OUTER JOIN with it. Only once you know the dbo.udfDateTimes is returning the datetimes you need for the query should you proceed with your OUTER JOIN.

Although the Northwind database deals with orders, another great use for these functions is when looking for missing data. In those cases where you need to seek out the datetimes where no data is present, add a HAVING clause set to zero.

```sql
-- G: Days in July 1996 with no orders 
SELECT dtime AS OrderDate, COUNT(R.orderID) AS OrderCount
FROM dbo.udfDateTimes ('7/1/1996', '7/31/1996',1,'day') DT 

LEFT OUTER JOIN Orders R ON DT.dtime = R.OrderDate
GROUP BY dtime
HAVING COUNT(R.orderID) = 0
```