SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT * INTO perf_issue FROM Person.person;

SELECT ROW_NUMBER() OVER (ORDER BY BusinessEntityID) AS RowNumber, * FROM perf_issue;

-----------------------------------------------

SELECT
	so.name,
	ps.*
FROM
	sys.dm_db_partition_stats ps
INNER JOIN
	sysobjects so 
ON
	ps.object_id = so.id
WHERE
	so.xtype = 'U'

------------------------------------------------

SELECT
	so.name,
	ps.used_page_count
FROM
	sys.dm_db_partition_stats ps
INNER JOIN
	sysobjects so 
ON
	ps.object_id = so.id
WHERE
	so.xtype = 'U'
ORDER BY ps.used_page_count DESC


----------------------------------------------------------------

DROP TABLE IF EXISTS dbo.SOH_Practice;
SELECT TOP (300000)
  SalesOrderID, CustomerID, OrderDate, SubTotal, TaxAmt, Freight, TotalDue
INTO dbo.SOH_Practice
FROM Sales.SalesOrderHeader
ORDER BY SalesOrderID;

-- Create a clustered index on SalesOrderID (common pattern)
-- This leaves our search columns (CustomerID, OrderDate) without a supporting index.
CREATE CLUSTERED INDEX CX_SOH_Practice_SalesOrderID
ON dbo.SOH_Practice(SalesOrderID);

DROP INDEX IF EXISTS CX_SOH_Practice_SalesOrderID ON dbo.SOH_Practice;

select * from Sales.SalesOrderHeader;