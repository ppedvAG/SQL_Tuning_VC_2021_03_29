-- Procedure
-- drop proc p_demo01
-- GO ist hilfreich und wichtig:

CREATE PROC p_demo01
AS 
SELECT GETDATE()
GO

EXEC p_demo01



-- GO kann Probleme verursachen:

declare @var1 int = 1

SELECT @var1
GO

SELECT @var1
GO

-- Variable gibt es nur innerhalb des Batches, in dem sie erstellt wurde;
-- zweites Select kennt @var1 nicht mehr wegen GO!







--CREATE PROC p_CustomerCity @City nvarchar(30)
--AS
--SELECT *
--FROM Customers
--WHERE City = @City


--EXEC p_CustomerCity 'Berlin'




-- Erstellen einer Prozedur:

-- Customers-Tabelle: CustomerID nchar(5)
-- Kunde finden mittels Suchkriteriums: 

/*
	
	EXEC CustomerSearch 'ALFKI'     --> findet Kunde mit ID 'ALFKI'
	EXEC CustomerSearch 'A'         --> findet alle Kunden, deren ID mit 'A' beginnt
	EXEC CustomerSearch '%'         --> findet alle
	EXEC CustomerSearch             --> findet alle

	-- testen!

*/




-- erste Idee....:


CREATE PROCEDURE p_TestSearch @cid nchar(5)
AS
SELECT *
FROM Customers
WHERE CustomerID = @cid
GO


-- mehrere Probleme: A funktioniert nicht, % funktioniert nicht


ALTER PROCEDURE p_TestSearch @cid nchar(5)
AS
SELECT *
FROM Customers
WHERE CustomerID LIKE @cid
GO


-- neue Idee: neuer Datentyp!
ALTER PROCEDURE p_TestSearch @cid nvarchar(10)  -- ein bisschen mehr Platz einplanen, als notwendig
AS
SELECT *
FROM Customers
WHERE CustomerID LIKE @cid
GO


-- neue Idee: 
ALTER PROCEDURE p_TestSearch @cid nvarchar(10) = '%'
AS
SELECT *
FROM Customers
WHERE CustomerID LIKE @cid + '%'
GO



	EXEC p_TestSearch 'ALFKI'     
	EXEC p_TestSearch 'A'        
	EXEC p_TestSearch '%'         
	EXEC p_TestSearch 
--	EXEC p_TestSearch 'ALFKIXY'



