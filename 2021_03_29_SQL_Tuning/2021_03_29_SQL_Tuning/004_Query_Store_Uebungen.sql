-- Query Store Übungen

-- welche Version haben wir?
select @@VERSION

-- Kompatibilitätsmodus überprüfen :
-- DB --> Properties --> Options --> Compatibility level


CREATE DATABASE Demo

USE Demo


SELECT Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.City, Customers.Country, Orders.OrderID, Orders.OrderDate, Orders.Freight, Orders.ShipCity, Orders.ShipCountry, Orders.EmployeeID, Orders.CustomerID AS Expr1, 
             [Order Details].OrderID AS Expr2, [Order Details].ProductID, [Order Details].UnitPrice, [Order Details].Quantity, [Order Details].Discount, Employees.EmployeeID AS Expr3, Employees.LastName, Employees.FirstName, Employees.Title, Employees.TitleOfCourtesy, 
             Employees.BirthDate, Employees.HireDate, Employees.City AS Expr4, Employees.Country AS Expr5, Products.ProductName, Products.SupplierID, Products.QuantityPerUnit
INTO Demo.dbo.KundenUmsatz
FROM   Northwind.dbo.Customers INNER JOIN
             Northwind.dbo.Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
             Northwind.dbo.[Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
             Northwind.dbo.Products ON [Order Details].ProductID = Products.ProductID INNER JOIN
             Northwind.dbo.Employees ON Orders.EmployeeID = Employees.EmployeeID



INSERT INTO KundenUmsatz
SELECT * FROM KundenUmsatz
GO 9



-- wie viele Zeilen sind in einer Tabelle drin?

SELECT DISTINCT t.name AS TableName
		, p.rows AS Zeilenanzahl
FROM sys.tables t
		INNER JOIN
			sys.partitions p
					ON t.object_id = p.object_id



-- Info zu Tabelle:

-- EXEC sp_help 'Customers'



-- Query Store settings für Übungen:

USE [master]
GO
ALTER DATABASE [Demo] SET QUERY_STORE = ON
GO
ALTER DATABASE [Demo] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, DATA_FLUSH_INTERVAL_SECONDS = 60, INTERVAL_LENGTH_MINUTES = 1, MAX_STORAGE_SIZE_MB = 500)
GO




SELECT *
INTO KU1
FROM KundenUmsatz


ALTER TABLE KU1
ADD ID int identity



dbcc showcontig('KU1')
-- KU1 61848 pages


SET STATISTICS IO, TIME ON


SELECT *
FROM KU1
WHERE ID = 100
-- logical reads 72596
-- 285ms



-- Statistik anschauen:
-- page-count: auf wie vielen pages ist die Tabelle abgespeichert?
-- record-count: wie viele Datensätze 
-- forwarded_record_count: ausgelagerte Informationen (neu hinzugefügte ID Spalte)
-- > forwarded record count in unserem Fall viel zu viel (10k Seiten für eine Spalte)

select    page_count
		, record_count
		, forwarded_record_count
from sys.dm_db_index_physical_stats(db_id(), object_id('ku1'), NULL, NULL, 'detailed')



-- zusammenführen mit Clustered Index


SELECT *
FROM KU1
WHERE ID < 2




SELECT *
FROM KU1
WHERE ID > 2
-- 35784ms
-- table scan - dauert ewig



SELECT TOP 1000 *
FROM KU1
WHERE ID < 1000000



CREATE UNIQUE NONCLUSTERED INDEX nix_id ON KU1 (id ASC)



SELECT *
FROM KU1
WHERE ID < 2



-- Tipping Point??

SELECT *
FROM KU1
WHERE ID < 800000



SELECT *
FROM KU1
WHERE ID < 300000



SELECT *
FROM KU1
WHERE ID < 50000


SELECT *
FROM KU1
WHERE ID < 16000

-- der Tipping Point für diese Abfrage liegt irgendwo zwischen <16000 und <17000
-- unter dem Tipping Point verwenden wir Seek
-- drüber scan
-- Tipping Point oft so ca. zwischen 25%-33%


SELECT *
FROM KU1
WHERE ID < 16000





-- Prozedur; Ausgabe: alle, wo die ID kleiner ist, als der übergebene Wert

CREATE PROCEDURE p_id @pid int
AS
SELECT *
FROM KU1
WHERE ID < @pid
GO


EXEC p_id 2
-- logical reads 4
-- index seek



EXEC p_id 100000
-- 101191 logical reads
-- index seek!!!


dbcc showcontig('KU1')
-- es gibt aber insgesamt nur 61848 pages!!


dbcc freeproccache -- Vorsicht: löscht Procedure Cache (alle)

alter database scoped configuration clear procedure_cache  -- lösche Proc cache nur für die aktuelle DB




EXEC p_id 1000000
-- table scan



-- kommen viele hohe oder viele niedrige Werte vor? Was wäre also für uns günstiger?
-- in diesem speziellen Fall wäre der table scan günstiger
-- Tipping Point hilft uns bei der Entscheidung
-- exakten Tipping Point brauchen wir nicht


-- RML Utilities zum Simulieren von Abfragen im Hintergrund
-- ostress -S. -Q"Select..." -dDemo -n5 -r5 -q

-- -S. ... Server
-- -Q ... Abfrage (Query)
-- -d ... Datenbankname
-- -n ... Anzahl User
-- -r ... Anzahl Wiederholungen der Abfrage
-- -q ... quiet (weniger Info)

-- alles ohne Abstände nach dem Buchstaben



