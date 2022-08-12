/*============================================================================
  File:     01_Query_Plan_Viewer.sql
============================================================================*/

/*
    To enable preview features: 
        File | Preferences | Settings
        Workbench: Enable Preview Features (needs to be checked)

		want dark mode?
		File | Preferences | Color Theme
		or
		CTRL + K CTRL + T
*/

USE [WideWorldImporters];
GO

/*
	Estimated Plan
*/
SELECT [CustomerID], SUM([AmountExcludingTax])
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
GROUP BY [CustomerID];
GO


/*
	Actual plan
	(CTRL + M still works)
	of note:
		Top Operations tab
		Properties
		Options on right
			Save plan
			

*/
SELECT [CustomerID], SUM([AmountExcludingTax])
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 1092
GROUP BY [CustomerID];
GO


/*
	run both queries together
	scroll bars on right
	properties on right
*/
SELECT [CustomerID], SUM([AmountExcludingTax])
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 401
GROUP BY [CustomerID];
GO

SELECT [CustomerID], SUM([AmountExcludingTax])
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 1092
GROUP BY [CustomerID];
GO


/*
	Can still use for actual plan (without CTRL + M)
*/
SET STATISTICS XML ON;
GO

SELECT [CustomerID], SUM([AmountExcludingTax])
FROM [Sales].[CustomerTransactions]
WHERE [CustomerID] = 1092
GROUP BY [CustomerID];
GO

SET STATISTICS XML OFF;
GO

/*
	multiple missing indexes
	https://dba.stackexchange.com/questions/131383/execution-plan-with-multiple-missing-indexes
*/

USE tempdb;
GO

SET NOCOUNT ON;
GO

IF OBJECT_ID('dbo.t1') IS NOT NULL DROP TABLE dbo.t1
CREATE TABLE dbo.t1
(
    rowId INT IDENTITY
);
GO

IF OBJECT_ID('dbo.t2') IS NOT NULL DROP TABLE dbo.t2
CREATE TABLE dbo.t2
(
    rowId INT IDENTITY
);
GO

SET NOCOUNT ON
INSERT INTO dbo.t1 DEFAULT VALUES;
GO 100000

INSERT INTO dbo.t2 DEFAULT VALUES;
GO 100000
SET NOCOUNT OFF

USE tempdb;
GO
SELECT *
FROM dbo.t1 t1
INNER JOIN dbo.t2 t2 
	ON t1.rowId = t2.rowId
WHERE t2.rowId = 999;
GO


/*
	check object names
*/
USE [WideWorldImporters];
GO
SELECT TOP 10 *
FROM [Purchasing].[PurchaseOrders] po
JOIN [Purchasing].[PurchaseOrderLines] pl
	ON po.PurchaseOrderID = pl.PurchaseOrderID
JOIN [Purchasing].[Suppliers] s
	ON po.SupplierID = s.SupplierID
JOIN [Purchasing].[SupplierCategories] sc
	ON s.SupplierCategoryID = sc.SupplierCategoryID
JOIN [Purchasing].[SupplierTransactions] st
	ON s.SupplierID = st.SupplierID
	AND pl.PurchaseOrderID = st.PurchaseOrderID


SELECT *
INTO Purchasing.PurchasingOrders_Heap
FROM [Purchasing].[PurchaseOrders] 

SELECT *
FROM [Purchasing].PurchasingOrders_Heap po
JOIN [Purchasing].[PurchaseOrderLines] pl
	ON po.PurchaseOrderID = pl.PurchaseOrderID
JOIN [Purchasing].[Suppliers] s
	ON po.SupplierID = s.SupplierID
JOIN [Purchasing].[SupplierCategories] sc
	ON s.SupplierCategoryID = sc.SupplierCategoryID
JOIN [Purchasing].[SupplierTransactions] st
	ON s.SupplierID = st.SupplierID
	AND pl.PurchaseOrderID = st.PurchaseOrderID
OPTION (MAXDOP 2)


/*
	larger plan (get estimated)
	note cost numbers have 2 decimals
*/
SELECT * 
FROM sys.all_objects 
CROSS JOIN sys.databases 
CROSS JOIN sys.all_views


/*
	Plan comparison
*/
USE [WideWorldImporters];
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [Sales].[usp_GetFullProductInfo]
	@StockItemID INT
AS	

	SELECT 
		[o].[CustomerID], 
		[o].[OrderDate], 
		[ol].[StockItemID], 
		[ol].[Quantity],
		[ol].[UnitPrice]
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	ORDER BY [o].[OrderDate] DESC;

	SELECT
		[o].[CustomerID], 
		SUM([ol].[Quantity]*[ol].[UnitPrice])
	FROM [Sales].[Orders] [o]
	JOIN [Sales].[OrderLines] [ol] 
		ON [o].[OrderID] = [ol].[OrderID]
	WHERE [ol].[StockItemID] = @StockItemID
	GROUP BY [o].[CustomerID]
	ORDER BY [o].[CustomerID] ASC;
GO


/*
	Generate two different plans to compare
	(Save the first plan)
*/
EXEC [Sales].[usp_GetFullProductInfo] 220 WITH RECOMPILE;
GO

/*
	(right-click and compare plan after running
EXEC [Sales].[usp_GetFullProductInfo] 90  WITH RECOMPILE;
GO




