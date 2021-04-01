-- Partition


-- partitioned View (partitionierte Sicht)


CREATE TABLE Orders(
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders PRIMARY KEY (OrderID, OrderYear)
					)


CREATE TABLE Orders_2020(
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders_2020 PRIMARY KEY (OrderID, OrderYear)
					)

					
CREATE TABLE Orders_2019(
						OrderID int NOT NULL,
						CountryCode char(3) NOT NULL,
						OrderDate date NULL,
						OrderYear int NOT NULL,
						CONSTRAINT PK_Orders_2019 PRIMARY KEY (OrderID, OrderYear)
					)


-- Testdaten einfügen

-- in Orders einfügen:
INSERT INTO Orders (OrderID, CountryCode, OrderDate, OrderYear)
VALUES  (202101, 'AUT', '2021-03-31', 2021), 
		(202102, 'AUT', '2021-04-01', 2021)




-- in Orders_2020 einfügen:
INSERT INTO Orders_2020 (OrderID, CountryCode, OrderDate, OrderYear)
VALUES  (202001, 'AUT', '2021-03-31', 2020), 
		(202002, 'AUT', '2021-04-01', 2020)


-- in Orders einfügen:
INSERT INTO Orders_2019(OrderID, CountryCode, OrderDate, OrderYear)
VALUES  (201901, 'AUT', '2021-03-31', 2019), 
		(201902, 'AUT', '2021-04-01', 2019)



SELECT * FROM Orders
SELECT * FROM Orders_2019
SELECT * FROM Orders_2020



CREATE VIEW v_OrdersTest
AS
SELECT OrderID, CountryCode, OrderDate, OrderYear FROM Orders
UNION ALL
SELECT OrderID, CountryCode, OrderDate, OrderYear FROM Orders_2019
UNION ALL
SELECT OrderID, CountryCode, OrderDate, OrderYear FROM Orders_2020
GO


SELECT *
FROM v_OrdersTest



SELECT *
FROM v_OrdersTest
WHERE OrderYear = 2019
-- Execution Plan: wir müssen alle drei Tabellen absuchen (Kontrolle, ob da irgendwo 2019 drin steht)



--> Lösung: CHECK CONSTRAINT für die partitionierte Sicht 
ALTER TABLE Orders 
ADD CONSTRAINT CK_Order CHECK (OrderYear >= 2021)
GO 

ALTER TABLE Orders_2020
ADD CONSTRAINT CK_Order_2020 CHECK (OrderYear = 2020)
GO

ALTER TABLE Orders_2019
ADD CONSTRAINT CK_Order_2019 CHECK (OrderYear = 2019)
GO



-- nochmal mit Execution-Plan ansehen:

SELECT *
FROM v_OrdersTest
WHERE OrderYear = 2019
-- wir müssen uns nur noch 1 Tabelle ansehen, nicht mehr alle 3






INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202103, 'AUT', GETDATE(), 2021)


INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (202003, 'AUT', GETDATE(), 2020)


INSERT INTO v_OrdersTest (OrderID, CountryCode, OrderDate, OrderYear)
VALUES (201903, 'AUT', GETDATE(), 2019)



SELECT *
FROM v_OrdersTest

SELECT * FROM Orders

SELECT * FROM Orders_2019

SELECT * FROM Orders_2020



-- Nachteile von partitioned view:
-- nächstes Jahr müssen wir eine neue Tabelle anlegen
-- > View anpassen! wenn eine neue Tabelle dazukommt



-- **************************************************************************************
-- **************************************************************************************

-- Partition   


-- Partitioning funktioniert auch ohne zusätzliche filegroups (Dateigruppen)
-- aber Wahrscheinlichkeit ist hoch, dass wir welche erstellen werden



-- feststellen, welche Filegroups für unsere DB zur Verfügung stehen:

SELECT Name FROM sys.filegroups


-- Daten einteilen

------------------ 1000] ------------------------- 5000] ----------------------------------------

--      1                           2                                          3


-- Partition Function und Partition Schema erstellen

-- Partition Function:

CREATE PARTITION FUNCTION f_xzahl(int)
AS
RANGE LEFT FOR VALUES(1000, 5000) -- wir könnten auch RIGHT verwenden



-- Test: abfragen, in welcher Partition # der Wert liegen würde:

SELECT $partition.f_xzahl(117) -- 1
SELECT $partition.f_xzahl(1000) -- 1
SELECT $partition.f_xzahl(3454) -- 2
SELECT $partition.f_xzahl(5000) -- 2
SELECT $partition.f_xzahl(11700) -- 3
SELECT $partition.f_xzahl(1000000) -- 3


-- Partition Scheme (Partitionsschema)

CREATE PARTITION SCHEME sch_xzahl
AS
PARTITION f_xzahl TO (x1000, x5000, xrest) -- Reihenfolge wichtig




-- Tabelle erstellen
-- Struktur der Tabelle muss genau gleich sein, wie die Daten, die da rein sollen...
-- CREATE TABLE Test (Spalte1 int, Spalte2 nvarchar(30)) ON sch_zahl

CREATE TABLE [dbo].PartitionTest(
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[City] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[Freight] [money] NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipCountry] [nvarchar](15) NULL,
	[EmployeeID] [int] NULL,
	[Expr1] [nchar](5) NULL,
	[Expr2] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[Expr3] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Expr4] [nvarchar](15) NULL,
	[Expr5] [nvarchar](15) NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[ID] [int] NOT NULL
) ON sch_xzahl(id)
GO



INSERT INTO PartitionTest
SELECT * FROM KU1



SET STATISTICS IO, TIME ON

SELECT *
into ku2
FROM ku1


SELECT *
FROM ku1
WHERE id = 117
-- 61760 logical reads


SELECT *
FROM PartitionTest
WHERE id = 117
-- 56 logical reads


SELECT *
FROM PartitionTest
WHERE id = 3456
-- 224 logical reads


-- zuerst neue Dateigruppe anlegen!

-- wir wollen eine neue Grenze eingeben bei 16000
-- wir müssen Partition scheme ändern

-- Partition scheme ändern:

ALTER PARTITION SCHEME sch_xzahl NEXT USED x16000

-- bisher keine Änderung; es sind immer noch drei Gruppen


SELECT    $partition.f_xzahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_xzahl(Id)


-- neue Grenze?


---- 1000] --------------- 5000] ------------------- 16000] -----------------------------

-- Daten verteilen mit Partition function (--> 16000)
ALTER PARTITION FUNCTION f_xzahl() SPLIT RANGE (16000)


SELECT    $partition.f_xzahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_xzahl(Id)



-- in welchem Bereich muss eine bestimmte Zahl vorkommen?

SELECT $partition.f_xzahl(117) -- 1
SELECT $partition.f_xzahl(1000) -- 1
SELECT $partition.f_xzahl(3454) -- 2
SELECT $partition.f_xzahl(5000) -- 2
SELECT $partition.f_xzahl(11700) -- 3
SELECT $partition.f_xzahl(1000000) -- 4





-- Grenze 1000 entfernen

-- Dateigruppe frei machen


------------- X1000X -------------- 5000 ---------------------- 16000 ---------------------------
--   x                     1                          2                      3


-- dafür brauchen wir nur die Funktion anzupassen!


ALTER PARTITION FUNCTION f_xzahl() MERGE RANGE(1000)

-- mehr brauchen wir nicht, um Grenze zu entfernen!

-- wieder testen: wo liegen jetzt die Daten?
SELECT    $partition.f_xzahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_xzahl(Id)




-- FileName, Daten in MB, Filegroupname ausgeben:
SELECT sdf.name AS [FileName],
size/128 AS [Size_in_MB],
fg.name AS [File_Group_Name]
FROM sys.database_files sdf
INNER JOIN
sys.filegroups fg
ON sdf.data_space_id=fg.data_space_id

-- wo finde ich partition function und schemes?
-- DB -> Storage --> Partition Functions/Schemes --> Script to... in Query Window anzeigen lassen (aktuelle Version)



-- Analysen "ausborgen" und an eigene Bedürfnisse anpassen:
SELECT
    so.name as [Tabelle],
    stat.row_count AS [Rows],
    p.partition_number AS [Partition #],
    pf.name as [Partition Function],
    CASE pf.boundary_value_on_right
        WHEN 1 then 'Right / Lower'
        ELSE 'Left / Upper'
    END as [Boundary Type],
    prv.value as [Boundary Point],
    fg.name as [Filegroup]
FROM sys.partition_functions AS pf
JOIN sys.partition_schemes as ps on ps.function_id=pf.function_id
JOIN sys.indexes as si on si.data_space_id=ps.data_space_id
JOIN sys.objects as so on si.object_id = so.object_id
JOIN sys.schemas as sc on so.schema_id = sc.schema_id
JOIN sys.partitions as p on 
    si.object_id=p.object_id 
    and si.index_id=p.index_id
LEFT JOIN sys.partition_range_values as prv on prv.function_id=pf.function_id
    and p.partition_number= 
        CASE pf.boundary_value_on_right WHEN 1
            THEN prv.boundary_id + 1
        ELSE prv.boundary_id
        END
        /* For left-based functions, partition_number = boundary_id, 
           for right-based functions we need to add 1 */
JOIN sys.dm_db_partition_stats as stat on stat.object_id=p.object_id
    and stat.index_id=p.index_id
    and stat.index_id=p.index_id and stat.partition_id=p.partition_id
    and stat.partition_number=p.partition_number
JOIN sys.allocation_units as au on au.container_id = p.hobt_id
    and au.type_desc ='IN_ROW_DATA' 
        /* Avoiding double rows for columnstore indexes. */
        /* We can pick up LOB page count from partition_stats */
JOIN sys.filegroups as fg on fg.data_space_id = au.data_space_id
ORDER BY [Tabelle], [Partition Function], [Partition #];
GO




-- Archivieren:  --> Partition in Archivtabelle verschieben:
-- Vorteil: jeder Scan braucht wieder weniger pages


-- Daten ins Archiv verschieben:


CREATE TABLE [dbo].ArchivTest(
	[CustomerID] [nchar](5) NOT NULL,
	[CompanyName] [nvarchar](40) NOT NULL,
	[ContactName] [nvarchar](30) NULL,
	[ContactTitle] [nvarchar](30) NULL,
	[City] [nvarchar](15) NULL,
	[Country] [nvarchar](15) NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [datetime] NULL,
	[Freight] [money] NULL,
	[ShipCity] [nvarchar](15) NULL,
	[ShipCountry] [nvarchar](15) NULL,
	[EmployeeID] [int] NULL,
	[Expr1] [nchar](5) NULL,
	[Expr2] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[Quantity] [smallint] NOT NULL,
	[Discount] [real] NOT NULL,
	[Expr3] [int] NOT NULL,
	[LastName] [nvarchar](20) NOT NULL,
	[FirstName] [nvarchar](10) NOT NULL,
	[Title] [nvarchar](30) NULL,
	[TitleOfCourtesy] [nvarchar](25) NULL,
	[BirthDate] [datetime] NULL,
	[HireDate] [datetime] NULL,
	[Expr4] [nvarchar](15) NULL,
	[Expr5] [nvarchar](15) NULL,
	[ProductName] [nvarchar](40) NOT NULL,
	[SupplierID] [int] NULL,
	[QuantityPerUnit] [nvarchar](20) NULL,
	[ID] [int] NOT NULL
) ON x5000
GO

-- Archivtabelle muss das gleiche Schema verwenden wie Originaltabelle  (kein identity)


ALTER TABLE PartitionTest SWITCH PARTITION 1 TO ArchivTest



SELECT *
FROM ArchivTest




SELECT * FROM PartitionTest WHERE ID = 1500

--> das ist jetzt im Archiv drin!!
SELECT * FROM ArchivTest WHERE ID = 1500



-- wieder testen: wo liegen jetzt die Daten?
SELECT    $partition.f_xzahl(id) AS [Partition]
		, MIN(id) AS von
		, MAX(id) AS bis
		, COUNT(*) AS Anzahl
FROM PartitionTest
GROUP BY $partition.f_xzahl(Id)




-- FileName, Daten in MB, Filegroupname ausgeben:
SELECT sdf.name AS [FileName],
size/128 AS [Size_in_MB],
fg.name AS [File_Group_Name]
FROM sys.database_files sdf
INNER JOIN
sys.filegroups fg
ON sdf.data_space_id=fg.data_space_id





INSERT INTO PartitionTest (id, CustomerID, CompanyName, OrderID, Expr2, ProductID, UnitPrice, Quantity, Discount, Expr3, LastName, FirstName, ProductName)
VALUES (3, 'Test1', 'Test1', 3, 3, 3, 3.33, 3, 0, 3, 'Mustermann', 'Max', 'Test')




-- Jahresweise aufteilen?

CREATE Partition FUNCTION f_year(datetime)
AS
RANGE LEFT FOR VALUES('31.12.2019 23.59:59.996')
-- Vorsicht mit Datum




--A----------------------M/N-------------------------------R-------------------------------Z

-- von AbisM und NbisR und SbisZ  -- Achtung!
CREATE Partition FUNCTION f_alphabet(nvarchar(50)) -- wo ist die Grenze? Gabi > G
AS
RANGE LEFT FOR VALUES('N', 'S')
-- Vorsicht mit Datum



-- ALFKI .........  .............. <P PARIS>..........
-- PARIS  P  -->
