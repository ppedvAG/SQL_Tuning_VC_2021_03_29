-- ohne Index: Speicherung im HEAP

-- clustered Index (gruppierter Index)

-- nonclustered Index (nicht gruppierter Index)

		-- unique index (eindeutiger Index)
		-- multicolumn index (zusammengesetzter Index)
		-- index with included columns (Index mit eingeschlossenen Spalten)
		-- covering index (abdeckender Index)
		-- filtered index (gefilterter Index)  -- beinhaltet eine WHERE-Clause

		-- hypothetisch realer Index


-- Columnstore Index --> Big Data; Data Warehouse; Archivdaten
-- CI wartet mit Update/Komprimierung bis 1 Mio Datensätze erreicht werden (oder bis 140000 am Stück hereinkommen)
-- somit werden Abfragen immer langsamer, weil ausgelagerte Daten gesucht werden müssen









-- create table orders2 (id int primary key, orderdate date)


select *
into orders1
from Northwind.dbo.Orders


set statistics io, time on

SELECT *
FROM orders1
WHERE OrderID = 11000
-- table scan (alles gelesen)
-- logical reads 20
-- 62ms

ALTER TABLE orders1
ADD CONSTRAINT PK_orders1 PRIMARY KEY (OrderID)  -- wenn wir Primary Key vergeben, wird automatisch ein Clustered Index erstellt!

-- ... es sei denn, wir verhindern das :

ALTER TABLE orders1
ADD CONSTRAINT PK_orders1 PRIMARY KEY NONCLUSTERED (OrderID)




-- gleiche Abfrage mit Clustered Index
SELECT *
FROM orders1
WHERE OrderID = 11000
-- Clustered Index Seek
-- logical reads 2
-- 118 ms, 52ms




-- ohne Index

--neue Abfrage:

select AVG(Freight) FROM Orders1 -- 78,2442

SELECT * FROM orders1 WHERE Freight < 1 -- 50% -- 24 Zeilen
SELECT * FROM orders1 WHERE Freight > 100 -- 50% -- 187 Zeilen

-- ein Batch (= alles, was markiert war, bevor wir execute geklickt haben) "kostet" immer 100%
-- 100% verteilt auf alle Abfragen im Batch und deren einzelne Aktionen 


SELECT * FROM Orders1 WHERE Freight < 1  -- 78%
SELECT TOP 24 * FROM Orders1 WHERE Freight > 100 -- 22%  -- wenn ich keinen Index habe, "gewinnt" der TOP-Befehl


-- Index erstellen 
-- ix nc freight including all


SELECT * FROM orders1 WHERE Freight < 1 -- 34% -- 24 Zeilen
SELECT * FROM orders1 WHERE Freight > 100 -- 66% -- 187 Zeilen


SELECT * FROM Orders1 WHERE Freight < 1  -- 47%
SELECT TOP 24 * FROM Orders1 WHERE Freight > 100 -- 53% 



SELECT *
Into ku3
From ku1
-- table scan


SELECT * FROM ku3 WHERE Freight < 1


-- Vorschlag vom Optimizer (im Execution Plan oben in Grün --> Rechtsklick --> Missing Index Details...)
CREATE NONCLUSTERED INDEX nix_freight_incl_cols
ON [dbo].[ku3] ([Freight])
INCLUDE ([CustomerID],[CompanyName],[ContactName],[ContactTitle],[City],[Country],[OrderID],[OrderDate],[ShipCity],[ShipCountry],[EmployeeID],[Expr1],[Expr2],[ProductID],[UnitPrice],[Quantity],[Discount],[Expr3],[LastName],[FirstName],[Title],[TitleOfCourtesy],[BirthDate],[HireDate],[Expr4],[Expr5],[ProductName],[SupplierID],[QuantityPerUnit],[ID])



SELECT * FROM ku3 WHERE Freight < 1

-- logical reads 61760
-- 1222 ms
-- table scan


-- columnstore ix

SELECT * FROM ku3 WHERE Freight < 1
-- 1743 ms
-- 1560 ms



dbcc showcontig('ku2')



-- MAXDOP

-- Maximum Degree of Parallelism

SELECT COUNT(*) FROM KundenUmsatz




-- Indizes anschauen:
select    iu.object_id
		, type_desc
		, name
		, iu.index_id
		, user_seeks
		, user_scans
		, last_user_scan
		, last_user_seek		
from sys.indexes si Inner join sys.dm_db_index_usage_stats iu on si.index_id = iu.index_id
where name like '%ix%'